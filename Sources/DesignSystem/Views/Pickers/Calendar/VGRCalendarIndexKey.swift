import Foundation

/// CalendarIndexKey is used as an index for the data structure that holds all events in the calendar
/// The reason for using it is to have a simple way of accessing the different elements in a date
/// without having to resort to using the Calendar.
public struct VGRCalendarIndexKey: Hashable, Equatable, Identifiable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int
    public let weekday: VGRCalendarWeekday

    public var id: String {
        "\(year)-\(month)-\(day)" // Unique string, e.g., "2025-6-26"
    }

    public var monthID: String {
        "\(year)-\(month)"
    }

    /// Returns a unique string identifying the ISO week of the year, e.g., "2025-W26"
    public var weekID: String {
        let calendar = Calendar.current
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
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        self.weekday = VGRCalendarWeekday(calendar.component(.weekday, from: date))
    }

    public init(from date: Date, using calendar: Calendar = .current) {
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
        self.day = calendar.component(.day, from: date)
        self.weekday = VGRCalendarWeekday(calendar.component(.weekday, from: date))
    }

    public init(_ calendar: Calendar, _ date: Date) {
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        self.year = components.year!
        self.month = components.month!
        self.day = components.day!
        self.weekday = VGRCalendarWeekday(components.weekday!)
    }

    public var date: Date {
        let calendar = Calendar.current
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
        } else if calendar.isDateInYesterday(date) {
            return "general.yesterday".localizedBundle
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

// MARK: - V2 Calendar Support

extension VGRCalendarIndexKey {

    public var dayID: String {
        "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
    }

    public func date(_ calendar: Calendar = .current) -> Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    public func weekID(_ calendar: Calendar) -> String {
        guard let date = date(calendar) else { return weekID }
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: date)
        return "\(yearForWeekOfYear)-W\(String(format: "%02d", weekOfYear))"
    }

    public func monthName(_ calendar: Calendar = .current) -> String {
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else { return "-" }
        return date.formatted(.dateTime.month(.wide).year().locale(calendar.locale ?? .current))
    }

    public func generateWeeks(_ calendar: Calendar = .current) -> [[VGRCalendarIndexKey?]] {
        let components = DateComponents(year: year, month: month, day: 1)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7

        var weeks: [[VGRCalendarIndexKey?]] = []
        var week: [VGRCalendarIndexKey?] = Array(repeating: nil, count: offset)

        for day in range {
            let date = calendar.date(from: DateComponents(year: year, month: month, day: day))!
            week.append(VGRCalendarIndexKey(calendar, date))

            if week.count == 7 {
                weeks.append(week)
                week = []
            }
        }

        if !week.isEmpty {
            while week.count < 7 {
                week.append(nil)
            }
            weeks.append(week)
        }
        
        return weeks
    }

    public func daysInWeek(_ calendar: Calendar = .current) -> [VGRCalendarIndexKey] {
        guard let date = date(calendar),
              let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }
        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) else { return nil }
            return VGRCalendarIndexKey(calendar, day)
        }
    }

    public func previousWeek(_ calendar: Calendar = .current) -> VGRCalendarIndexKey {
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: date)!
        return VGRCalendarIndexKey(calendar, previous)
    }

    public func nextWeek(_ calendar: Calendar = .current) -> VGRCalendarIndexKey {
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let next = calendar.date(byAdding: .weekOfYear, value: 1, to: date)!
        return VGRCalendarIndexKey(calendar, next)
    }
}
