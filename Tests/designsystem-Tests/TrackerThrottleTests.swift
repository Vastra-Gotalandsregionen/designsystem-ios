import XCTest
@testable import DesignSystem

/// Covers `Tracker.trackEvent(_:on:once:)`. The tracker runs in the simulator here, so nothing is
/// sent; what is asserted is the throttle decision (`trackEventUnlessThrottled` returning whether
/// the call was forwarded) and the state it persists.
final class TrackerThrottleTests: XCTestCase {

    private enum Screen: TrackableScreen {
        case home
        var identifier: String { "home" }
    }

    private struct Warning: TrackableInteraction {
        var action: String { "shown" }
        var name: String?
        var value: Float?

        init(name: String? = nil, value: Float? = nil) {
            self.name = name
            self.value = value
        }
    }

    private let suiteName = "TrackerThrottleTests"
    private var defaults: UserDefaults!
    private var previousOptIn: Any?

    /// The clock the tracker under test reads. Tests move it to cross a day boundary.
    private var now = Date()

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)

        /// Opt-in lives in `UserDefaults.standard`; remember the host's value and force opted-in.
        previousOptIn = UserDefaults.standard.object(forKey: "personalDataAgreementAccepted")
        UserDefaults.standard.set(true, forKey: "personalDataAgreementAccepted")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        if let previousOptIn {
            UserDefaults.standard.set(previousOptIn, forKey: "personalDataAgreementAccepted")
        } else {
            UserDefaults.standard.removeObject(forKey: "personalDataAgreementAccepted")
        }
        super.tearDown()
    }

    private func makeTracker() -> Tracker {
        Tracker(throttleDefaults: defaults, now: { self.now })
    }

    private func nextDay(after date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: date)!
    }

    private func assertStoredDate(forKey key: String, equals expected: Date, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        guard let stored = defaults.object(forKey: key) as? Date else {
            return XCTFail("no Date stored under \(key). \(message)", file: file, line: line)
        }
        XCTAssertEqual(stored.timeIntervalSinceReferenceDate, expected.timeIntervalSinceReferenceDate, accuracy: 0.001, message, file: file, line: line)
    }

    // MARK: - Key

    func testThrottleKeyIsCategoryActionAndNameWithoutValue() {
        XCTAssertEqual(Tracker.throttleKey(for: Warning(name: "low_battery", value: 3), on: Screen.home),
                       "home/shown/low_battery")
        XCTAssertEqual(Tracker.throttleKey(for: Warning(), on: Screen.home),
                       "home/shown/", "nil name is treated as empty")
    }

    // MARK: - Session

    func testSessionThrottleSendsOncePerTracker() {
        let tracker = makeTracker()

        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .session))
        XCTAssertFalse(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .session))

        /// A new tracker instance stands in for a new app process: nothing was persisted.
        let nextLaunch = makeTracker()
        XCTAssertTrue(nextLaunch.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .session))
        XCTAssertNil(defaults.object(forKey: "matomo_event_lasttracked_home/shown/a"))
        XCTAssertNil(defaults.object(forKey: "matomo_event_tracked_home/shown/a"))
    }

    // MARK: - Day

    func testDayThrottleSuppressesSameDayAndSendsNextDay() {
        let tracker = makeTracker()

        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
        XCTAssertFalse(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))

        let firstDay = now
        assertStoredDate(forKey: "matomo_event_lasttracked_home/shown/a", equals: firstDay)

        now = nextDay(after: firstDay)
        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
        assertStoredDate(forKey: "matomo_event_lasttracked_home/shown/a", equals: now)
        XCTAssertFalse(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
    }

    func testDayThrottleIsPersistedAcrossTrackerInstances() {
        XCTAssertTrue(makeTracker().trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
        XCTAssertFalse(makeTracker().trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
    }

    func testDayThrottleKeyDoesNotCollideWithTrackOnceDaily() {
        /// `trackOnceDaily` stores under `matomo_lasttracked_{identifier}` in `UserDefaults.standard`;
        /// the event throttle must never read or write that key.
        UserDefaults.standard.removeObject(forKey: "matomo_lasttracked_home/shown/a")
        defer { UserDefaults.standard.removeObject(forKey: "matomo_lasttracked_home/shown/a") }

        let tracker = Tracker(throttleDefaults: .standard, now: { self.now })
        defer {
            UserDefaults.standard.removeObject(forKey: "matomo_event_lasttracked_home/shown/a")
            UserDefaults.standard.removeObject(forKey: "matomo_event_lasttracked_consent/state")
        }

        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
        XCTAssertNotNil(UserDefaults.standard.object(forKey: "matomo_event_lasttracked_home/shown/a"))
        XCTAssertNil(UserDefaults.standard.object(forKey: "matomo_lasttracked_home/shown/a"))
    }

    // MARK: - Ever

    func testEverThrottleSendsOnceAndPersists() {
        let tracker = makeTracker()

        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .ever))
        XCTAssertFalse(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .ever))
        XCTAssertNotNil(defaults.object(forKey: "matomo_event_tracked_home/shown/a"))

        /// Neither a new day nor a new tracker instance lets it through again.
        now = nextDay(after: now)
        XCTAssertFalse(makeTracker().trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .ever))
    }

    // MARK: - Key identity

    func testDifferentNamesAreThrottledIndependently() {
        let tracker = makeTracker()

        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "low_battery"), on: Screen.home, once: .day))
        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "no_network"), on: Screen.home, once: .day))
        XCTAssertFalse(tracker.trackEventUnlessThrottled(Warning(name: "low_battery"), on: Screen.home, once: .day))
        XCTAssertFalse(tracker.trackEventUnlessThrottled(Warning(name: "no_network"), on: Screen.home, once: .day))
    }

    func testValueIsNotPartOfTheKey() {
        let tracker = makeTracker()

        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a", value: 1), on: Screen.home, once: .day))
        XCTAssertFalse(tracker.trackEventUnlessThrottled(Warning(name: "a", value: 2), on: Screen.home, once: .day))
    }

    func testThrottlesAreIndependentOfEachOther() {
        let tracker = makeTracker()

        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .session))
        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .ever))
    }

    // MARK: - Daily consent report

    private let consentKey = "matomo_event_lasttracked_consent/state"

    func testConsentStateIsReportedOncePerDayAtLaunch() {
        XCTAssertNil(defaults.object(forKey: consentKey))

        _ = makeTracker()
        let firstLaunch = now
        assertStoredDate(forKey: consentKey, equals: firstLaunch)

        /// A second launch the same day does not report again.
        now = firstLaunch.addingTimeInterval(60)
        _ = makeTracker()
        assertStoredDate(forKey: consentKey, equals: firstLaunch)

        /// The next day it does.
        now = nextDay(after: firstLaunch)
        _ = makeTracker()
        assertStoredDate(forKey: consentKey, equals: now)
    }

    func testConsentStateIsReportedForOptedOutUsers() {
        UserDefaults.standard.set(false, forKey: "personalDataAgreementAccepted")

        _ = makeTracker()
        assertStoredDate(forKey: consentKey, equals: now)
    }

    func testConsentChangeReportsImmediatelyAndCountsAsTodaysReport() {
        let tracker = makeTracker()
        let launch = now
        assertStoredDate(forKey: consentKey, equals: launch)

        now = launch.addingTimeInterval(60)
        tracker.setOptInSetting(false)
        assertStoredDate(forKey: consentKey, equals: now, "a genuine toggle reports and refreshes the day marker")

        /// Re-applying the same value (what every launch does) is not a change and reports nothing.
        let toggle = now
        now = toggle.addingTimeInterval(60)
        tracker.setOptInSetting(false)
        assertStoredDate(forKey: consentKey, equals: toggle)
    }

    // MARK: - Opt-out

    func testOptedOutCallIsNotRecorded() {
        let tracker = makeTracker()
        tracker.setOptInSetting(false)

        /// Not throttled, so forwarded — but `trackEvent(_:on:)` drops it, and nothing may be remembered.
        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .ever))
        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .session))
        XCTAssertNil(defaults.object(forKey: "matomo_event_lasttracked_home/shown/a"))
        XCTAssertNil(defaults.object(forKey: "matomo_event_tracked_home/shown/a"))
        XCTAssertFalse(tracker.hasTrackedEvent(key: "home/shown/a", once: .session))

        /// The first display after opting back in counts.
        tracker.setOptInSetting(true)
        XCTAssertTrue(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
        XCTAssertFalse(tracker.trackEventUnlessThrottled(Warning(name: "a"), on: Screen.home, once: .day))
    }
}
