import SwiftUI
import XCTest
@testable import DesignSystem

@MainActor
final class VGRNavRowLazinessTests: XCTestCase {

    @MainActor
    private final class Probe {
        static var initCount = 0
    }

    @MainActor
    private struct ProbeDestination: View {
        init() { Probe.initCount += 1 }
        var body: some View { Text("destination") }
    }

    func testDestinationIsNotBuiltWhenRowIsCreated() {
        Probe.initCount = 0

        _ = VGRNavRow(title: "Row") { ProbeDestination() }

        XCTAssertEqual(Probe.initCount, 0,
                       "Destination must not be constructed when the row is created")
    }

    func testDestinationIsNotBuiltWhenRowBodyIsEvaluated() {
        Probe.initCount = 0

        let row = VGRNavRow(title: "Row") { ProbeDestination() }
        _ = row.body

        XCTAssertEqual(Probe.initCount, 0,
                       "Destination must not be constructed when the row renders")
    }

    /// Positive control. Without it the two assertions above would also pass
    /// if the probe simply never counted anything.
    func testProbeCountsItsOwnConstruction() {
        Probe.initCount = 0

        _ = ProbeDestination()

        XCTAssertEqual(Probe.initCount, 1, "Probe should count each construction")
    }
}
