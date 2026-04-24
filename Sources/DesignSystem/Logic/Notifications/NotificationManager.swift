import Foundation
import OSLog
@preconcurrency import UserNotifications

/// Unified local-notification coordinator.
///
/// Apps hold an instance (usually one per app, but not a singleton) and call
/// into it for all scheduling. The manager keeps a rolling window of
/// individually-scheduled occurrences for complex recurrences, and falls back
/// to a single OS-repeating trigger when the schedule is simple enough that
/// no rescheduling is needed.
public actor NotificationManager {

    public struct Configuration: Sendable, Equatable {
        /// How far ahead to materialize individual requests for complex recurrences.
        public var windowDays: Int
        /// Per-context cap on individual requests. iOS's system-wide cap is 64.
        public var maxIndividualRequests: Int
        /// Background refresh re-extends the window when fewer than this many
        /// seconds of schedule remain.
        public var backgroundLeadTime: TimeInterval

        public init(
            windowDays: Int = 60,
            maxIndividualRequests: Int = 60,
            backgroundLeadTime: TimeInterval = 3 * 24 * 3600
        ) {
            self.windowDays = windowDays
            self.maxIndividualRequests = maxIndividualRequests
            self.backgroundLeadTime = backgroundLeadTime
        }
    }

    public enum Error: Swift.Error, Sendable, Equatable {
        case settingsNotFound(contextId: String)
    }

    private let scheduler: NotificationScheduling
    private let store: NotificationStoring
    private let authorizer: NotificationAuthorizing
    private let configuration: Configuration
    private let logger = Logger(subsystem: "DesignSystem.Notifications", category: "Manager")

    public init(
        scheduler: NotificationScheduling,
        store: NotificationStoring,
        authorizer: NotificationAuthorizing,
        configuration: Configuration = .init()
    ) {
        self.scheduler = scheduler
        self.store = store
        self.authorizer = authorizer
        self.configuration = configuration
    }

    /// Production factory wiring the system implementations.
    public static func live(
        suite: sending UserDefaults = .standard,
        storeKey: String = "designsystem.notifications.v1",
        configuration: Configuration = .init()
    ) -> NotificationManager {
        NotificationManager(
            scheduler: SystemNotificationScheduler(),
            store: UserDefaultsNotificationStore(suite: suite, key: storeKey),
            authorizer: SystemNotificationAuthorizer(),
            configuration: configuration
        )
    }

    // MARK: - Authorization

    public func requestAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound]) async throws -> Bool {
        try await authorizer.requestAuthorization(options: options)
    }

    public func authorizationStatus() async -> UNAuthorizationStatus {
        await authorizer.authorizationStatus()
    }

    public func notificationSettings() async -> UNNotificationSettings {
        await authorizer.notificationSettings()
    }

    // MARK: - Settings read

    public func settings(for contextId: String) async -> NotificationSettings? {
        await store.get(contextId: contextId)
    }

    public func allSettings() async -> [String: NotificationSettings] {
        await store.all()
    }

    public func hasSettings(for contextId: String) async -> Bool {
        await store.get(contextId: contextId) != nil
    }

    // MARK: - Settings write

    /// Replaces the stored settings for `contextId` and re-materializes the
    /// schedule. Safe to call on an unknown `contextId` — creates it.
    ///
    /// When the global switch is off (`isGlobalEnabled() == false`), the new
    /// settings are still persisted, but no requests are scheduled — so
    /// flipping the switch back on re-schedules them automatically.
    public func update(_ contextId: String, settings: NotificationSettings) async throws {
        await scheduler.removeAll(withPrefix: contextPrefix(contextId))

        var newSettings = settings
        let globalEnabled = await store.isGlobalEnabled()

        if newSettings.enabled, globalEnabled {
            let (requests, scheduledUntil) = buildRequests(contextId: contextId, settings: newSettings, from: Date())
            if !requests.isEmpty {
                try await scheduler.schedule(requests, contextId: contextId)
            }
            newSettings.scheduledUntil = scheduledUntil
        }

        await store.set(newSettings, for: contextId)
    }

    /// Flips `enabled = true` on existing settings and schedules.
    public func activate(_ contextId: String) async throws {
        guard var settings = await store.get(contextId: contextId) else {
            throw Error.settingsNotFound(contextId: contextId)
        }
        settings.enabled = true
        try await update(contextId, settings: settings)
    }

    /// Flips `enabled = false` on existing settings and removes pending requests.
    public func deactivate(_ contextId: String) async throws {
        guard var settings = await store.get(contextId: contextId) else {
            throw Error.settingsNotFound(contextId: contextId)
        }
        settings.enabled = false
        try await update(contextId, settings: settings)
    }

    /// Removes the settings AND any pending requests for this context.
    public func delete(_ contextId: String) async {
        await scheduler.removeAll(withPrefix: contextPrefix(contextId))
        await store.remove(contextId: contextId)
    }

    /// Bulk removal by raw `contextId` prefix — e.g. `"medication.schema.<uuid>."`
    /// clears all slot-level contexts for one schema.
    public func cleanup(contextIdPrefix prefix: String) async {
        await scheduler.removeAll(withPrefix: prefix)
        _ = await store.remove(contextIdsWithPrefix: prefix)
    }

    // MARK: - Global switch

    /// App-level master switch. Defaults to `true`.
    ///
    /// Independent of the OS-level permission status from
    /// `authorizationStatus()` — this is an app-settings toggle, not the
    /// iOS Settings toggle.
    public func isGlobalEnabled() async -> Bool {
        await store.isGlobalEnabled()
    }

    /// Flips the master switch.
    ///
    /// - When switching to `false`: every pending request managed by this
    ///   manager is removed, but stored settings are kept as-is so the state
    ///   can be restored.
    /// - When switching to `true`: every stored context with `enabled == true`
    ///   is re-materialized, same as if `update(_:settings:)` had been called
    ///   for each one.
    public func setGlobalEnabled(_ enabled: Bool) async throws {
        let wasEnabled = await store.isGlobalEnabled()
        guard wasEnabled != enabled else { return }

        await store.setGlobalEnabled(enabled)
        let all = await store.all()
        let now = Date()

        if enabled {
            for (contextId, settings) in all where settings.enabled {
                let (requests, scheduledUntil) = buildRequests(contextId: contextId, settings: settings, from: now)
                if !requests.isEmpty {
                    try await scheduler.schedule(requests, contextId: contextId)
                }
                var updated = settings
                updated.scheduledUntil = scheduledUntil
                await store.set(updated, for: contextId)
            }
        } else {
            for contextId in all.keys {
                await scheduler.removeAll(withPrefix: contextPrefix(contextId))
            }
        }
    }

    // MARK: - Categories

    public func register(categories: sending Set<UNNotificationCategory>) async {
        await scheduler.setCategories(categories)
    }

    // MARK: - Background refresh

    /// Re-extends the rolling window for every perpetual, complex-recurrence
    /// context whose window has nearly drained. Apps call this from their
    /// `BGAppRefreshTask` handler and from the background scene-phase transition.
    ///
    /// No-op when the global switch is off.
    public func refreshSchedules() async throws {
        guard await store.isGlobalEnabled() else { return }

        let now = Date()
        let all = await store.all()

        for (contextId, settings) in all {
            guard settings.enabled else { continue }
            guard settings.needsRescheduling(asOf: now, leadTime: configuration.backgroundLeadTime) else { continue }

            await scheduler.removeAll(withPrefix: contextPrefix(contextId))
            let (requests, scheduledUntil) = buildIndividualRequests(contextId: contextId, settings: settings, from: now)
            if !requests.isEmpty {
                try await scheduler.schedule(requests, contextId: contextId)
            }

            var updated = settings
            updated.scheduledUntil = scheduledUntil
            await store.set(updated, for: contextId)
        }
    }

    // MARK: - Request building

    /// Identifiers are `"<contextId>_<n>"` or `"<contextId>_repeat"`. The
    /// trailing underscore lets us prefix-match a specific context without
    /// catching siblings like `foo.1` and `foo.10`.
    private func contextPrefix(_ contextId: String) -> String { "\(contextId)_" }

    private func buildRequests(
        contextId: String,
        settings: NotificationSettings,
        from: Date
    ) -> (requests: [NotificationRequest], scheduledUntil: Date) {
        if settings.canUseNativeRepeatingTrigger {
            return buildRepeatingRequest(contextId: contextId, settings: settings)
        }
        return buildIndividualRequests(contextId: contextId, settings: settings, from: from)
    }

    private func buildRepeatingRequest(
        contextId: String,
        settings: NotificationSettings
    ) -> (requests: [NotificationRequest], scheduledUntil: Date) {
        guard let recurrence = settings.recurrence else { return ([], settings.scheduledUntil) }

        let calendar = Calendar.current
        let hm = calendar.dateComponents([.hour, .minute], from: settings.timeOfDay)
        var components = DateComponents()
        components.hour = hm.hour
        components.minute = hm.minute

        switch recurrence.period {
        case .day:
            break
        case .week:
            if let weekday = recurrence.weekdays?.sorted().first {
                components.weekday = weekday.rawValue
            }
        case .month:
            components.day = calendar.component(.day, from: settings.startDate)
        }

        let request = NotificationRequest(
            identifier: "\(contextId)_repeat",
            content: settings.content,
            trigger: .calendar(components, repeats: true),
            scheduledAt: settings.startDate
        )
        return ([request], .distantFuture)
    }

    private func buildIndividualRequests(
        contextId: String,
        settings: NotificationSettings,
        from: Date
    ) -> (requests: [NotificationRequest], scheduledUntil: Date) {
        let calendar = Calendar.current
        let hm = calendar.dateComponents([.hour, .minute], from: settings.timeOfDay)
        let hour = hm.hour ?? 0
        let minute = hm.minute ?? 0

        /// Single request, no recurrence
        guard let recurrence = settings.recurrence else {
            guard let fireDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: settings.startDate),
                  fireDate > from
            else { return ([], from) }

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let request = NotificationRequest(
                identifier: "\(contextId)_0",
                content: settings.content,
                trigger: .calendar(components, repeats: false),
                scheduledAt: fireDate
            )
            return ([request], fireDate)
        }

        let windowStart = max(from, settings.startDate)
        guard let windowCap = calendar.date(byAdding: .day, value: configuration.windowDays, to: from) else {
            return ([], from)
        }
        let windowEnd = min(windowCap, settings.endDate ?? .distantFuture)
        guard windowStart <= windowEnd else { return ([], from) }

        let interval = DateInterval(start: windowStart, end: windowEnd)
        let dayDates = recurrence.getRecurringDates(for: interval, deviations: settings.deviations)

        let fireDates = dayDates
            .compactMap { calendar.date(bySettingHour: hour, minute: minute, second: 0, of: $0) }
            .filter { $0 > from }
            .sorted()
        let capped = Array(fireDates.prefix(configuration.maxIndividualRequests))

        let requests = capped.enumerated().map { index, date -> NotificationRequest in
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            return NotificationRequest(
                identifier: "\(contextId)_\(index)",
                content: settings.content,
                trigger: .calendar(components, repeats: false),
                scheduledAt: date
            )
        }
        let scheduledUntil = capped.last ?? from
        return (requests, scheduledUntil)
    }
}
