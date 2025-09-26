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
            fatalError("failed initializing tracker")
        }
#endif

        initTracker()
    }

    // MARK: - tracking methods

    @available(*, deprecated, message: "Use trackScreen(_ screen: TrackableScreen, note: String? = nil) instead.")
    public func trackScreen(_ screen: TrackerScreen, note: String? = nil) {
        // TODO: (ea) - Find a way to include voiceOver state in tracking
        // let isVoiceOverActive = UIAccessibility.isVoiceOverRunning

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
            print("👀 Tracker: \(screen.toString), 🗒️ \"\(note)\"")
        } else {
            print("👀 Tracker: \(screen.toString)")
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

    @available(*, deprecated, message: "Use trackEvent(_ screen: TrackableScreen, note: String? = nil) instead.")
    public func trackEvent(_ screen: TrackerScreen, note: String? = nil) {
        trackScreen(screen, note: note)
    }

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

    /// Inversion of _isOptedOut_ for convenience
    /// This is used for Toggles where the _on_ state is commonly used as a way to indicate that the user has opted in.
    public var isOptedIn: Bool {
        let isOptedIn = getOptInSetting()
        return isOptedIn
    }

    let personalDataAgreementAccepted = "personalDataAgreementAccepted"

    /// hasOptInSetting returns a boolean that indicates wether the user has set an opt-in/out setting
    public func hasOptInSetting() -> Bool {
        let val = UserDefaults.standard.object(forKey: personalDataAgreementAccepted)
        return val != nil
    }

    public func getOptInSetting() -> Bool {
        let isOptedIn = UserDefaults.standard.bool(forKey: personalDataAgreementAccepted)
        return isOptedIn
    }

    public func setOptInSetting(_ isOptedIn: Bool) {
        UserDefaults.standard.set(isOptedIn, forKey: personalDataAgreementAccepted)
        guard let tracker = matomoTracker else {
            print("👀 Tracker is disabled: Opt-in setting should be set to '\(isOptedIn)'")
            return
        }
        tracker.isOptedOut = !isOptedIn
    }
}
