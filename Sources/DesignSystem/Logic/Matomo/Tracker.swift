import Foundation
import MatomoTracker
import OSLog

/// Tracker is used to pass events to the underlying/wrapped analytics solution, which in our case is Matomo.
public class Tracker {
    @MainActor public static let shared = Tracker()

    private let logger = Logger(subsystem: "Tracker", category: "Analytics")

    /// matomoTracker is kept private, we do not want to expose its interface to the rest of the app
    private var matomoTracker: MatomoTracker?

    init() {
        let matomoSiteId = Bundle.main.object(forInfoDictionaryKey:"MATOMO_SITE_ID") as? String ?? ""
        let matomoURL = Bundle.main.object(forInfoDictionaryKey:"MATOMO_URL") as? String ?? ""
        let appVersionDimensionIndex = Int(Bundle.main.object(forInfoDictionaryKey:"MATOMO_APPVERSION_DIMENSION") as? String ?? "") ?? -1
        let appVersion = Bundle.main.appVersionLong

#if targetEnvironment(simulator)
        logger.info("📱 Tracker is running in simulated environment")
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

        guard getOptInSetting() else { return }

#if targetEnvironment(simulator)
        /// When we're in a simulator environment (iOS Simulator & xcode preview), we do not actually call the tracker - just log it.
        let noteSuffix = note.map { ", 🗒️ \"\($0)\"" } ?? ""
        logger.info("👀 Tracker: \(screen.identifier)\(noteSuffix)")
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
        guard getOptInSetting() else { return }

#if targetEnvironment(simulator)
        /// When we're in a simulator environment (iOS Simulator & xcode preview), we do not actually call the tracker - just log it.
        let n = interaction.name.map { " / \($0)" } ?? ""
        let v = interaction.value.map { " = \($0)" } ?? ""
        logger.info("⚡️ Event: \(screen.identifier) / \(interaction.action)\(n)\(v)")
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
    /// Matomo tracker accordingly. When the user opts out, no analytics data will be collected.
    ///
    /// When the preference genuinely changes (a user-initiated toggle — not the re-application that
    /// happens on every launch via `initTracker()`), a `consent` event carrying the new value is
    /// reported. For an opt-**out** the event is tracked and flushed *before* `isOptedOut` is set:
    /// once that flag is on, `MatomoTracker` discards every event at enqueue time, so the opt-out
    /// could never otherwise be recorded. This is what lets us measure how many users disable
    /// tracking.
    ///
    /// - Parameter isOptedIn: `true` to enable analytics tracking, `false` to disable it.
    public func setOptInSetting(_ isOptedIn: Bool) {
        /// Detect a genuine change *before* overwriting the stored value. `setOptInSetting` is also
        /// called on every launch to re-apply the persisted setting, so reporting unconditionally
        /// would massively over-count. `hasOptInSetting()` also excludes the first-launch default.
        let didChange = hasOptInSetting() && getOptInSetting() != isOptedIn

        UserDefaults.standard.set(isOptedIn, forKey: personalDataAgreementAccepted)

        guard let tracker = matomoTracker else {
            logger.info("👀 Tracker is disabled: Opt-in setting should be set to '\(isOptedIn)'")
            return
        }

        /// The consent event goes straight through the wrapped tracker, bypassing the public
        /// tracking methods: their `getOptInSetting()` guard reads the value we just persisted,
        /// which for an opt-out would suppress this very event.
        if isOptedIn {
            /// Enabling: lift the opt-out first so the event can be queued, then report the change.
            tracker.isOptedOut = false
            if didChange {
                tracker.track(eventWithCategory: "consent", action: "opt_in", value: 1.0)
            }
        } else {
            /// Disabling: report and flush the opt-out while still opted in, BEFORE isOptedOut is
            /// set — afterwards `queue(event:)` would silently drop it.
            if didChange {
                tracker.track(eventWithCategory: "consent", action: "opt_out", value: 0.0)
                tracker.dispatch()
            }
            tracker.isOptedOut = true
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
        logger.info("👀 Tracker: \(screen.toString)")
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
