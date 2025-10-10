import Foundation

public struct VGRCalendarPeriodModel: Identifiable, Hashable {
    /// Unique identifier for the period.
    public var id: UUID = UUID()

    /// The index key representing this period in the calendar.
    public var idx: VGRCalendarIndexKey

    /// The list of days (as index keys) that belong to this period.
    public var days: [VGRCalendarIndexKey]

    /// Used to pad out the monthViews first days, in case the month starts on anything else than a monday
    var leadingPadding: Int
}
