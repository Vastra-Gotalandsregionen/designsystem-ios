import SwiftUI

public extension NotificationManager {

    /// Preview/test factory wiring in-memory implementations — nothing hits
    /// `UNUserNotificationCenter`, `UserDefaults`, or `BGTaskScheduler`.
    ///
    /// Hold the returned manager if you want to inspect the scheduled requests
    /// or stored settings after exercising the view:
    ///
    ///     let manager = NotificationManager.preview()
    ///     MyView().environment(\.notifications, manager)
    ///
    /// > `manager.notificationSettings()` traps on this instance because
    /// > `UNNotificationSettings` has no public initializer. Previews should
    /// > only read `authorizationStatus()`.
    static func preview(
        granted: Bool = true,
        settings: [String: NotificationSettings] = [:],
        configuration: Configuration = .init()
    ) -> NotificationManager {
        NotificationManager(
            scheduler: RecordingNotificationScheduler(),
            store: InMemoryNotificationStore(initial: settings),
            authorizer: PreviewNotificationAuthorizer(granted: granted),
            configuration: configuration
        )
    }
}

public extension View {

    /// Injects an in-memory `NotificationManager` into the environment, so any
    /// view reading `@Environment(\.notifications)` resolves to a working
    /// instance in `#Preview` blocks.
    ///
    ///     #Preview {
    ///         RemindersSettingsView()
    ///             .previewNotifications()
    ///     }
    ///
    /// To observe what the view schedules, construct the manager yourself and
    /// inject it via `.environment(\.notifications, ...)` instead.
    func previewNotifications(
        granted: Bool = true,
        settings: [String: NotificationSettings] = [:]
    ) -> some View {
        environment(\.notifications, .preview(granted: granted, settings: settings))
    }
}

public extension NotificationSettings {

    /// Minimal sample — daily at 08:00 — handy when a preview needs pre-seeded
    /// state without building a full `NotificationSettings` at the call site.
    static var preview: NotificationSettings {
        let calendar = Calendar.current
        let time = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        return NotificationSettings(
            content: .init(title: "Preview reminder", body: "This is a preview"),
            timeOfDay: time,
            recurrence: Recurrence(frequency: 1, period: .day)
        )
    }
}
