import XCTest
@testable import DesignSystem

/// Covers `Tracker.setDimension(_:forIndex:)`. The tracker runs in the simulator here, so nothing is
/// sent; what is asserted is the value the tracker keeps for each index.
final class TrackerDimensionTests: XCTestCase {

    private let suiteName = "TrackerDimensionTests"

    private func makeTracker() -> Tracker {
        Tracker(throttleDefaults: UserDefaults(suiteName: suiteName)!)
    }

    func testSetDimensionKeepsValue() {
        let tracker = makeTracker()
        tracker.setDimension("breast", forIndex: 2)
        XCTAssertEqual(tracker.dimensions[2], "breast")
    }

    func testSetDimensionReplacesValue() {
        let tracker = makeTracker()
        tracker.setDimension("breast", forIndex: 2)
        tracker.setDimension("prostate", forIndex: 2)
        XCTAssertEqual(tracker.dimensions[2], "prostate")
    }

    func testNilRemovesDimension() {
        let tracker = makeTracker()
        tracker.setDimension("breast", forIndex: 2)
        tracker.setDimension(nil, forIndex: 2)
        XCTAssertNil(tracker.dimensions[2])
    }

    func testDimensionsAreIndependent() {
        let tracker = makeTracker()
        tracker.setDimension("breast", forIndex: 2)
        tracker.setDimension("gothenburg", forIndex: 3)
        tracker.setDimension(nil, forIndex: 2)
        XCTAssertEqual(tracker.dimensions, [3: "gothenburg"])
    }
}
