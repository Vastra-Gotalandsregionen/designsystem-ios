import Foundation

public struct VGRCalendarPeriodModel: Identifiable, Hashable {
    public var id: UUID = UUID()
    var idx: VGRCalendarIndexKey
    var days: [VGRCalendarIndexKey]

    /// Used to pad out the monthViews first days, in case the month starts on anything else than a monday
    var leadingPadding: Int
}
