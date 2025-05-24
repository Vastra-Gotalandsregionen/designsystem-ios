import Foundation

/// CalendarIndexKey is used as an index for the data structure that holds all events in the calendar
/// The reason for using it is to have a simple way of accessing the different elements in a date
/// without having to resort to using the Calendar.
public struct CalendarIndexKey: Hashable, Equatable, Identifiable {
    var year: Int
    var month: Int
    var day: Int

    public var id: String {
        "\(year)-\(month)-\(day)" // Unique string, e.g., "2025-6-26"
    }

    public var monthID: String {
        "\(year)-\(month)" 
    }


    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init(from date: Date) {
        let calendar = Calendar.current
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
        self.day = calendar.component(.day, from: date)
    }

    public var date: Date {
        return Calendar.current.date(self.year, self.month, self.day)
    }

    public static func == (lhs: CalendarIndexKey, rhs: CalendarIndexKey) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
}


