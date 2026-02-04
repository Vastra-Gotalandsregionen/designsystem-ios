import Foundation

/// CalendarIndexKey is used as an index for the data structure that holds all events in the calendar
/// The reason for using it is to have a simple way of accessing the different elements in a date
/// without having to resort to using the Calendar.
public struct VGRCalendarIndexKey: Hashable, Equatable, Identifiable, Sendable {
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



extension VGRCalendarIndexKey {
    /// Returns a localized accessibility label for the date
    /// - Returns: "Idag" for today, "Imorgon" for tomorrow, or formatted date like "Måndag, 2:a februari 2026"
    public var accessibilityLabel: String {
        let date = self.date
        let calendar = Calendar.current

        /// Check if it's today or tomorrow
        if calendar.isDateInToday(date) {
            return "general.today".localizedBundle
        } else if calendar.isDateInTomorrow(date) {
            return "general.tomorrow".localizedBundle
        }

        /// Format as "Måndag, 2:a februari 2026"
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sv_SE")

        /// Get weekday and month/year
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date)

        formatter.dateFormat = "MMMM yyyy"
        let monthYear = formatter.string(from: date)

        /// Get day number and add Swedish ordinal suffix
        let day = calendar.component(.day, from: date)
        let ordinalSuffix = swedishOrdinalSuffix(for: day)

        return "\(weekday), \(day):\(ordinalSuffix) \(monthYear)"
    }

    /// Returns the Swedish ordinal suffix for a day number
    /// - Parameter day: The day of the month (1-31)
    /// - Returns: "a" for days ending in 1 or 2, "e" for all others
    private func swedishOrdinalSuffix(for day: Int) -> String {
        /// In Swedish: 1:a, 2:a, 3:e, 4:e, etc.
        /// Days ending in 1 or 2 use "a", all others use "e"
        let lastDigit = day % 10
        if lastDigit == 1 || lastDigit == 2 {
            return "a"
        } else {
            return "e"
        }
    }
}
