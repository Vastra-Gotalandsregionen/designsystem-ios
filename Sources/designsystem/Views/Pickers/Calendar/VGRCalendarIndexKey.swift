import Foundation

/// CalendarIndexKey is used as an index for the data structure that holds all events in the calendar
/// The reason for using it is to have a simple way of accessing the different elements in a date
/// without having to resort to using the Calendar.
public struct VGRCalendarIndexKey: Hashable, Equatable, Identifiable {
    public var year: Int
    public var month: Int
    public var day: Int

    public var id: String {
        "\(year)-\(month)-\(day)" // Unique string, e.g., "2025-6-26"
    }

    public var monthID: String {
        "\(year)-\(month)" 
    }

    private static let sharedCalendar = Calendar.current

    /// Returns a unique string identifying the ISO week of the year, e.g., "2025-W26"
    public var weekID: String {
        let calendar = Self.sharedCalendar
        let date = self.date
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: date)
        return "\(yearForWeekOfYear)-W\(weekOfYear)"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(month)
        hasher.combine(day)
    }

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init(from date: Date) {
        let calendar = Self.sharedCalendar
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
        self.day = calendar.component(.day, from: date)
    }

    public var date: Date {
        let calendar = Self.sharedCalendar
        return calendar.date(self.year, self.month, self.day)
    }

    public static func == (lhs: VGRCalendarIndexKey, rhs: VGRCalendarIndexKey) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
}


