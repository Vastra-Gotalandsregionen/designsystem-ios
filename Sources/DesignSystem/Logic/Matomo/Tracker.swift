import Foundation
import MatomoTracker
import OSLog

/// How often a throttled event (see `Tracker.trackEvent(_:on:once:)`) may be reported.
///
/// The throttle applies per event *identity* — category, action and name — so two warnings with
/// different names are throttled independently, while the event value is ignored.
public enum TrackingThrottle {
    /// At most once per app process. Nothing is persisted; the next launch may report it again.
    case session
    /// At most once per calendar day (`Calendar.current`), persisted across launches. Use for
    /// elements whose visibility is recomputed from data, e.g. a warning that shows when a
    /// threshold is crossed.
    case day
    /// At most once per install, persisted across launches. Use for things meant to be seen once,
    /// e.g. a guide tip or a what's-new sheet.
    case ever
}

/// Tracker is used to pass events to the underlying/wrapped analytics solution, which in our case is Matomo.
public class Tracker {
    @MainActor public static let shared = Tracker()

    private let logger = Logger(subsystem: "Tracker", category: "Analytics")

    /// matomoTracker is kept private, we do not want to expose its interface to the rest of the app
    private var matomoTracker: MatomoTracker?

    /// Where `.day` and `.ever` throttle state is persisted. Injectable so tests can use an isolated suite.
    let throttleDefaults: UserDefaults

    /// Clock used by the `.day` throttle. Injectable so tests can step across a day boundary.
    let now: () -> Date

    /// Keys of events already reported with the `.session` throttle during this app process.
    private var sessionTrackedEventKeys = Set<String>()

    init(throttleDefaults: UserDefaults = .standard, now: @escaping () -> Date = { Date() }) {
        self.throttleDefaults = throttleDefaults
        self.now = now

        let matomoSiteId = Bundle.main.object(forInfoDictionaryKey:"MATOMO_SITE_ID") as? String ?? ""
        let matomoURL = Bundle.main.object(forInfoDictionaryKey:"MATOMO_URL") as? String ?? ""
        let appVersionDimensionIndex = Int(Bundle.main.object(forInfoDictionaryKey:"MATOMO_APPVERSION_DIMENSION") as? String ?? "") ?? -1
        let appVersion = Bundle.main.appVersionLong

#if targetEnvironment(simulator)
        /// Surface the configuration the tracker *would* have used. These values are never validated here,
        /// so an empty one is only discovered on device, where it trips the `fatalError` below.
        let siteIdDescription = matomoSiteId.isEmpty ? "⚠️ missing" : matomoSiteId
        let urlDescription = matomoURL.isEmpty ? "⚠️ missing" : matomoURL
        print("📱 Tracker is running in simulated environment — MATOMO_SITE_ID: \(siteIdDescription), MATOMO_URL: \(urlDescription)")
        matomoTracker = nil
#else
        if matomoURL.isEmpty || matomoSiteId.isEmpty {
            fatalError("invalid configuration for analytics")
        }


        let url = URL(string: matomoURL)
        if let baseURL = url {
            let newTracker = MatomoTracker(siteId: matomoSiteId, baseURL: baseURL)
            newTracker.logger = DefaultLogger(minLevel: .info)

            if appVersionDimensionIndex != -1 {
                newTracker.setDimension(appVersion, forIndex: appVersionDimensionIndex)
            } else {
                logger.warning("no app version dimension set")
            }

            matomoTracker = newTracker
        } else {
            fatalError("failed initializing tracker, invalid URL")
        }
#endif

        initTracker()
    }

    // MARK: - tracking methods

    /// Tracks a screen view in the analytics system.
    ///
    /// This method records when a user views a specific screen in the application.
    /// The tracking only occurs if the user has opted in to analytics.
    ///
    /// - Parameters:
    ///   - screen: The screen to track, conforming to `TrackableScreen` protocol.
    ///   - note: An optional additional note to include with the screen tracking.
    public func trackScreen(_ screen: TrackableScreen, note: String? = nil) {
        // TODO: (ea) - Find a way to include voiceOver state in tracking
        // let isVoiceOverActive = UIAccessibility.isVoiceOverRunning

        guard getOptInSetting() else {
#if targetEnvironment(simulator)
            /// Report the suppression so a silent console distinguishes "the user is opted out" from "the call never happened".
            let noteSuffix = note.map { ", 🗒️ \"\($0)\"" } ?? ""
            print("🚫 Tracker: opted out, skipping \(screen.identifier)\(noteSuffix)")
#endif
            return
        }

#if targetEnvironment(simulator)
        /// When we're in a simulator environment (iOS Simulator & xcode preview), we do not actually call the tracker - just log it.
        let noteSuffix = note.map { ", 🗒️ \"\($0)\"" } ?? ""
        print("👀 Tracker: \(screen.identifier)\(noteSuffix)")
#else
        guard let tracker = matomoTracker else { return }
        
        if let note {
            tracker.track(view: [screen.identifier, note])
        } else {
            tracker.track(view: [screen.identifier])
        }
#endif
    }

    /// Tracks a user interaction that occurs within a screen.
    ///
    /// Unlike `trackScreen`, which records that a screen was viewed, this method records a
    /// discrete interaction the user performed *while on* that screen — for example adding a
    /// symptom or choosing a value. It is reported as a proper Matomo event: the screen supplies
    /// the event category, and the interaction supplies the action, name, and value.
    /// The tracking only occurs if the user has opted in to analytics.
    ///
    /// - Parameters:
    ///   - interaction: The interaction to track, conforming to `TrackableInteraction`. Provides
    ///     the event's action (`e_a`), and optionally its name (`e_n`) and value (`e_v`).
    ///   - screen: The screen the interaction happened on, conforming to `TrackableScreen`. Its
    ///     `identifier` is used as the event category (`e_c`).
    public func trackEvent(_ interaction: TrackableInteraction, on screen: TrackableScreen) {
        guard getOptInSetting() else {
#if targetEnvironment(simulator)
            /// Report the suppression so a silent console distinguishes "the user is opted out" from "the call never happened".
            let n = interaction.name.map { " / \($0)" } ?? ""
            let v = interaction.value.map { " = \($0)" } ?? ""
            print("🚫 Event: opted out, skipping \(screen.identifier) / \(interaction.action)\(n)\(v)")
#endif
            return
        }

#if targetEnvironment(simulator)
        /// When we're in a simulator environment (iOS Simulator & xcode preview), we do not actually call the tracker - just log it.
        let n = interaction.name.map { " / \($0)" } ?? ""
        let v = interaction.value.map { " = \($0)" } ?? ""
        print("⚡️ Event: \(screen.identifier) / \(interaction.action)\(n)\(v)")
#else
        guard let tracker = matomoTracker else { return }
        tracker.track(
            eventWithCategory: screen.identifier,   // ← your TrackableScreen, as the category
            action: interaction.action,
            name: interaction.name,
            value: interaction.value
        )
#endif
    }

    /// Tracks an event at most once per session, day or install.
    ///
    /// Use this for things the app shows **on its own initiative** — warnings, guide tips, callouts,
    /// what's-new sheets — which VGR's Matomo principles want reported as events with the action
    /// `shown`. Callers fire it on the transition from hidden to visible (for example when the
    /// condition behind a warning first becomes true), **not** from `onAppear`: a screen is re-appeared
    /// far more often than its content changes. The throttle is a safety net against the remaining
    /// repeats, not the primary dedupe.
    ///
    /// The throttle key is the event's category, action and name (`screen.identifier`,
    /// `interaction.action`, `interaction.name` — a `nil` name counts as empty). The value is not
    /// part of the key, so the same warning reported with different values is still one event.
    ///
    /// When the call is not throttled it is forwarded to `trackEvent(_:on:)`, so the opt-in guard and
    /// the simulator logging apply unchanged. The key is recorded only when the event was actually
    /// sent (or logged in the simulator): while the user is **opted out** nothing is recorded, so the
    /// first display after opting back in is counted.
    ///
    /// `.day` and `.ever` state lives in `UserDefaults` under the prefixes `matomo_event_lasttracked_`
    /// and `matomo_event_tracked_`, separate from the `matomo_lasttracked_` keys of `trackOnceDaily`.
    /// `.ever` therefore resets with a reinstall. `.session` state is in memory only.
    ///
    /// - Parameters:
    ///   - interaction: The interaction to track, conforming to `TrackableInteraction`.
    ///   - screen: The screen the interaction happened on; its `identifier` is the event category.
    ///   - per: How often the event may be reported. See `TrackingThrottle`.
    public func trackEvent(_ interaction: TrackableInteraction, on screen: TrackableScreen, once per: TrackingThrottle) {
        trackEventUnlessThrottled(interaction, on: screen, once: per)
    }

    /// Tracks a screen view only once per day.
    ///
    /// This method ensures that the same screen is tracked at most once per calendar day.
    /// Subsequent calls within the same day will be ignored. The tracking state is persisted
    /// in UserDefaults.
    ///
    /// - Parameters:
    ///   - screen: The screen to track, conforming to `TrackableScreen` protocol.
    ///   - note: An optional additional note to include with the screen tracking.
    public func trackOnceDaily(_ screen: TrackableScreen, note: String? = nil) {
        var eventKey = screen.identifier
        if let note {
            eventKey = "\(screen.identifier)_\(note)"
        }

        let lastTrackedKey = "matomo_lasttracked_\(eventKey)"

        let calendar = Calendar.current
        let now = Date()

        if let lastTrackedDate = UserDefaults.standard.object(forKey: lastTrackedKey) as? Date {
            if calendar.isDate(lastTrackedDate, inSameDayAs: now) {
                /// Do not track
                return
            }
        }

        trackScreen(screen, note: note)

        UserDefaults.standard.set(now, forKey: lastTrackedKey)
    }

    /// Tracks an action-triggered screen view in the analytics system.
    ///
    /// - Note: Despite its name, this method registers the call as a **view**, not as a Matomo
    ///   event. It is a thin convenience wrapper around `trackScreen`.
    ///
    /// Use this for things that are *triggered* like events in the app but that you want recorded
    /// as their own self-contained view rather than as an action performed on another view. For
    /// example, deleting a medication intake is logged as a single `"delete_medication"` view —
    /// not as a `"delete"` action on a `"view_medication"` category.
    ///
    /// For interactions that should be recorded as true Matomo events (a category with a separate
    /// action, name, and value), use `trackEvent(_:on:)` instead.
    ///
    /// The tracking only occurs if the user has opted in to analytics.
    ///
    /// - Parameters:
    ///   - screen: The screen to track, conforming to `TrackableScreen` protocol.
    ///   - note: An optional additional note to include with the tracking.
    public func trackEvent(_ screen: TrackableScreen, note: String? = nil) {
        trackScreen(screen, note: note)
    }

    // MARK: - initialization and management of opt-in/out

    func initTracker() {
        /// If there was no previous value, default to true
        if !hasOptInSetting() {
            setOptInSetting(true)
        } else {
            /// Get user setting
            let isOptedIn = getOptInSetting()

            /// Pass it back to ensure the wrapped tracker has the same setting
            setOptInSetting(isOptedIn)
        }

        reportConsentStateOncePerDay()
    }

    /// Indicates whether the user has opted in to analytics tracking.
    ///
    /// This is the inverse of the internal `isOptedOut` setting. It provides a convenient
    /// boolean property for checking the user's consent status. This is particularly useful
    /// for UI toggles where the "on" state represents opted-in status.
    ///
    /// - Returns: `true` if the user has opted in to analytics, `false` otherwise.
    public var isOptedIn: Bool {
        let isOptedIn = getOptInSetting()
        return isOptedIn
    }

    let personalDataAgreementAccepted = "personalDataAgreementAccepted"

    /// Checks whether the user has previously set an opt-in/opt-out preference.
    ///
    /// This method determines if the user has made an explicit choice about analytics tracking.
    /// It's useful for distinguishing between users who haven't been asked yet versus those
    /// who have made a choice.
    ///
    /// - Returns: `true` if a preference has been set, `false` if no preference exists yet.
    public func hasOptInSetting() -> Bool {
        let val = UserDefaults.standard.object(forKey: personalDataAgreementAccepted)
        return val != nil
    }

    /// Retrieves the current opt-in setting for analytics tracking.
    ///
    /// - Returns: `true` if the user has opted in to analytics, `false` otherwise.
    public func getOptInSetting() -> Bool {
        let isOptedIn = UserDefaults.standard.bool(forKey: personalDataAgreementAccepted)
        return isOptedIn
    }

    /// Sets the user's opt-in preference for analytics tracking.
    ///
    /// This method updates both the UserDefaults preference and configures the underlying
    /// Matomo tracker accordingly. When the user opts out, no analytics data will be collected —
    /// with one exception, the consent state itself, see `reportConsentState(_:)`.
    ///
    /// When the preference genuinely changes (a user-initiated toggle — not the re-application that
    /// happens on every launch via `initTracker()`), the new state is reported immediately as a
    /// `consent` event, in addition to the daily report made at launch.
    ///
    /// - Parameter isOptedIn: `true` to enable analytics tracking, `false` to disable it.
    public func setOptInSetting(_ isOptedIn: Bool) {
        /// Detect a genuine change *before* overwriting the stored value. `setOptInSetting` is also
        /// called on every launch to re-apply the persisted setting, so reporting unconditionally
        /// would massively over-count. `hasOptInSetting()` also excludes the first-launch default.
        let didChange = hasOptInSetting() && getOptInSetting() != isOptedIn

        UserDefaults.standard.set(isOptedIn, forKey: personalDataAgreementAccepted)

        if didChange {
            reportConsentState(isOptedIn)
        }

        guard let tracker = matomoTracker else {
#if targetEnvironment(simulator)
            print("👀 Tracker is disabled: Opt-in setting should be set to '\(isOptedIn)'")
#endif
            return
        }
        tracker.isOptedOut = !isOptedIn
    }

    // MARK: - consent reporting

    /// Throttle key under which the daily consent report is remembered. Deliberately independent of
    /// the state being reported, so opting in and out on the same day does not yield a second census entry.
    static let consentReportThrottleKey = "consent/state"

    /// Reports the current consent state once per calendar day, so the share of opted-out users can
    /// be measured. Called at launch; the throttle persists across launches like any `.day` event.
    func reportConsentStateOncePerDay() {
        guard !hasTrackedEvent(key: Self.consentReportThrottleKey, once: .day) else {
#if targetEnvironment(simulator)
            print("🔁 Event: already tracked today, skipping consent / \(getOptInSetting() ? "opt_in" : "opt_out")")
#endif
            return
        }
        reportConsentState(getOptInSetting())
    }

    /// Reports the consent state as a `consent` / `opt_in` or `opt_out` event,
    /// **regardless of consent**: this is the one event that is sent for opted-out users too, since
    /// otherwise they would vanish from the statistics the moment they opt out.
    ///
    /// It bypasses the public tracking methods (their `getOptInSetting()` guard would drop it) and
    /// goes straight through the wrapped tracker. `MatomoTracker` discards events at enqueue time
    /// while `isOptedOut` is set, so the flag is lifted for the duration of the call and restored
    /// afterwards. The event is flushed immediately rather than left to the dispatch timer, so an
    /// opt-out followed by a kill of the app still gets through.
    ///
    /// Also records today's throttle key, so a change-triggered report counts as the day's census.
    private func reportConsentState(_ isOptedIn: Bool) {
        recordTrackedEvent(key: Self.consentReportThrottleKey, once: .day)

        let action = isOptedIn ? "opt_in" : "opt_out"

        guard let tracker = matomoTracker else {
#if targetEnvironment(simulator)
            print("⚡️ Event: consent / \(action) (reported regardless of consent)")
#endif
            return
        }

        let wasOptedOut = tracker.isOptedOut
        tracker.isOptedOut = false
        tracker.track(eventWithCategory: "consent", action: action)
        tracker.dispatch()
        tracker.isOptedOut = wasOptedOut
    }
}

// MARK: - Event throttling
extension Tracker {
    /// `UserDefaults` prefix for `.day` throttle state. Distinct from `trackOnceDaily`'s `matomo_lasttracked_`.
    static let dayThrottleKeyPrefix = "matomo_event_lasttracked_"

    /// `UserDefaults` prefix for `.ever` throttle state.
    static let everThrottleKeyPrefix = "matomo_event_tracked_"

    /// Builds the throttle key for an event: category, action and name. The value is deliberately
    /// excluded. `/` is used as separator since it cannot appear in a snake_case identifier, so
    /// `a_b` + `c` and `a` + `b_c` never collide the way they would with `_`.
    static func throttleKey(for interaction: TrackableInteraction, on screen: TrackableScreen) -> String {
        "\(screen.identifier)/\(interaction.action)/\(interaction.name ?? "")"
    }

    /// Worker behind `trackEvent(_:on:once:)`. Returns `false` when the throttle suppressed the call,
    /// `true` when it was forwarded to `trackEvent(_:on:)` (which may still drop it if opted out).
    @discardableResult
    func trackEventUnlessThrottled(_ interaction: TrackableInteraction, on screen: TrackableScreen, once throttle: TrackingThrottle) -> Bool {
        let key = Self.throttleKey(for: interaction, on: screen)

        guard !hasTrackedEvent(key: key, once: throttle) else {
#if targetEnvironment(simulator)
            /// Report the suppression so a silent console distinguishes "throttled" from "the call never happened".
            let n = interaction.name.map { " / \($0)" } ?? ""
            print("🔁 Event: already tracked \(throttle.suppressionDescription), skipping \(screen.identifier) / \(interaction.action)\(n)")
#endif
            return false
        }

        trackEvent(interaction, on: screen)

        /// Only remember the event if it was actually sent or logged. While opted out `trackEvent(_:on:)`
        /// drops it, and we want the first display after opting back in to be counted.
        if getOptInSetting() {
            recordTrackedEvent(key: key, once: throttle)
        }
        return true
    }

    /// Whether the event identified by `key` has already been reported within the throttle's window.
    func hasTrackedEvent(key: String, once throttle: TrackingThrottle) -> Bool {
        switch throttle {
            case .session:
                return sessionTrackedEventKeys.contains(key)
            case .day:
                guard let lastTracked = throttleDefaults.object(forKey: Self.dayThrottleKeyPrefix + key) as? Date else {
                    return false
                }
                return Calendar.current.isDate(lastTracked, inSameDayAs: now())
            case .ever:
                return throttleDefaults.object(forKey: Self.everThrottleKeyPrefix + key) != nil
        }
    }

    /// Remembers that the event identified by `key` was reported now.
    private func recordTrackedEvent(key: String, once throttle: TrackingThrottle) {
        switch throttle {
            case .session:
                sessionTrackedEventKeys.insert(key)
            case .day:
                throttleDefaults.set(now(), forKey: Self.dayThrottleKeyPrefix + key)
            case .ever:
                throttleDefaults.set(now(), forKey: Self.everThrottleKeyPrefix + key)
        }
    }
}

private extension TrackingThrottle {
    /// Fills in "already tracked …" in the simulator suppression line.
    var suppressionDescription: String {
        switch self {
            case .session: return "this session"
            case .day: return "today"
            case .ever: return "on this install"
        }
    }
}

// MARK: - Deprecated Methods
extension Tracker {
    @available(*, deprecated, message: "Use trackScreen(_ screen: TrackableScreen, note: String? = nil) instead.")
    public func trackScreen(_ screen: TrackerScreen, note: String? = nil) {
        let isOptedIn = getOptInSetting()
        if !isOptedIn {
            return
        }

#if targetEnvironment(simulator)
        /// When we're in a simulator environment (iOS Simulator & xcode preview), we do not actually call the tracker - just log it.
        print("👀 Tracker: \(screen.toString)")
#else
        guard let tracker = matomoTracker else { return }
        if let note = note {
            tracker.track(view: [screen.toString, note])
        } else {
            tracker.track(view: [screen.toString])
        }
#endif
    }

    @available(*, deprecated, message: "Use trackEvent(_ screen: TrackableScreen, note: String? = nil) instead.")
    public func trackEvent(_ screen: TrackerScreen, note: String? = nil) {
        trackScreen(screen, note: note)
    }
}
