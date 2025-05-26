import Foundation

struct CalendarPeriodModel: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var idx: CalendarIndexKey
    var days: [CalendarIndexKey]
    var leadingPadding: Int
}
