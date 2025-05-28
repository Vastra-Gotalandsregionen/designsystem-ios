import Foundation

public struct CalendarPeriodModel: Identifiable, Hashable {
    public var id: UUID = UUID()
    var idx: CalendarIndexKey
    var days: [CalendarIndexKey]

    /// Used to pad out the monthViews first days, in case the month starts on anything else than a monday
    var leadingPadding: Int
}
