import Foundation

public enum VGRCalendarWeekday: Int, CaseIterable, Hashable, Codable, Sendable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    init(_ dayInt: Int) {
        self = VGRCalendarWeekday(rawValue: dayInt) ?? .sunday
    }

    var isWeekend: Bool { self == .saturday || self == .sunday }
}
