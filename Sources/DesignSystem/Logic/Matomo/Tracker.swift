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

#if targetEnvironment(simulator)
        print("📱 Tracker is running in simulated environment")
        matomoTracker = nil
#else
        if matomoURL.isEmpty || matomoSiteId.isEmpty {
            fatalError("invalid configuration for analytics")
        }

        let url = URL(string: matomoURL)
        if let baseURL = url {
            let newTracker = MatomoTracker(siteId: matomoSiteId, baseURL: baseURL)
            newTracker.logger = DefaultLogger(minLevel: .info)
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

        let isOptedIn = getOptInSetting()
        if !isOptedIn {
            return
        }

#if targetEnvironment(simulator)
        /// When we're in a simulator environment (iOS Simulator & xcode preview), we do not actually call the tracker - just log it.
        if let note {
            print("👀 Tracker: \(screen.identifier), 🗒️ \"\(note)\"")
        } else {
            print("👀 Tracker: \(screen.identifier)")
        }
#else
        guard let tracker = matomoTracker else { return }
        
        if let note {
            tracker.track(view: [screen.identifier, note])
        } else {
            tracker.track(view: [screen.identifier])
        }
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

    /// Tracks an event in the analytics system.
    ///
    /// This is a convenience method that internally calls `trackScreen`. Use this when
    /// tracking user interactions or events rather than screen views.
    ///
    /// - Parameters:
    ///   - screen: The event to track, conforming to `TrackableScreen` protocol.
    ///   - note: An optional additional note to include with the event tracking.
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
    /// - Parameter isOptedIn: `true` to enable analytics tracking, `false` to disable it.
    public func setOptInSetting(_ isOptedIn: Bool) {
        UserDefaults.standard.set(isOptedIn, forKey: personalDataAgreementAccepted)
        guard let tracker = matomoTracker else {
            print("👀 Tracker is disabled: Opt-in setting should be set to '\(isOptedIn)'")
            return
        }
        tracker.isOptedOut = !isOptedIn
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
