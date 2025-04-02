import Foundation

public extension Date {
    /// The start of the day for the date, at midnight.
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// The end of the day for the date, just before the next day starts.
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    /// The start of the week for the date, based on the current calendar's first weekday.
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }

    /// The end of the week for the date, just before the next week starts.
    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }

    /// The start of the month for the date.
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    /// The end of the month for the date, just before the next month starts.
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }

    /// The date for the next month based on the current date.
    var nextMonth: Date {
        var components = DateComponents()
        components.month = 1
        return Calendar.current.date(byAdding: components, to: self)!
    }
}


public extension Date {
    /// Returns an array of dates for the current week, starting from the specified weekday.
    /// The `startOfWeek` parameter determines which day is considered the start of the week.
    func datesForCurrentWeek(startingFrom startOfWeek: Locale.Weekday = .monday) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = startOfWeek == .sunday ? 1 : 2

        // Find the start of the week for the given date
        let startOfWeekDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!

        // Generate dates for the week
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeekDate) }
    }
}

public extension Date {
    /// The year component of the date.
    var year: Int {
        Calendar.current.dateComponents([.year], from: self).year!
    }

    /// The month component of the date.
    var month: Int {
        Calendar.current.dateComponents([.month], from: self).month!
    }

    /// The day of the month component of the date.
    var dayInMonth: Int {
        Calendar.current.dateComponents([.day], from: self).day!
    }

    /// The hour component of the date.
    var hour: Int {
        Calendar.current.dateComponents([.hour], from: self).hour!
    }

    /// The minute component of the date.
    var minute: Int {
        Calendar.current.dateComponents([.minute], from: self).minute!
    }

    /// The weekday component of the date.
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
}

public extension Date {
    /// Formats the date with full day and month name, including the year only if it differs from the current year.
    var vgrDateFormat: String {
        if Calendar.current.compare(Date(), to: self, toGranularity: .year) == .orderedSame {
            return self.formatted(.dateTime.day().month(.wide))
        }
        return self.formatted(.dateTime.day().month(.wide).year())
    }

    /// Formats the date to a short time representation, omitting the date.
    var vgrShortTimeFormat: String {
        return self.formatted(date: .omitted, time: .shortened)
    }

    /// Formats the date and time into a combined string representation.
    var vgrDateTimeFormat: String {
        return "\(self.vgrDateFormat) \(self.vgrShortTimeFormat)"
    }

    /// Formats the date and time for accessibility, including a localized "at" string.
    var vgrDateTimeA11yFormat: String {
        return "\(self.vgrDateFormat) \("general.time.at".localized.lowercased()) \(self.vgrShortTimeFormat)"
    }
}

public extension Date {

    /// Checks if the date is within the specified date interval.
    func isWithin(_ interval: DateInterval, calendar: Calendar = .current) -> Bool {
        let startDate = calendar.startOfDay(for: interval.start)
        let endDate = calendar.startOfDay(for: interval.end)
        let targetDate = calendar.startOfDay(for: self)

        return targetDate >= startDate && targetDate <= endDate
    }

}

public extension Date {

    /// Compares the date to another date for equality based on the specified calendar component.
    func isEqual(to date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        return calendar.compare(self, to: date, toGranularity: component) == .orderedSame
    }

    /// Checks if the date is equal to or less than another date based on the specified calendar component.
    func isEqualOrLess(than date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        let comparison = calendar.compare(self, to: date, toGranularity: component)
        return comparison == .orderedSame || comparison == .orderedAscending
    }

    /// Checks if the date is equal to or greater than another date based on the specified calendar component.
    func isEqualOrGreater(than date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        let comparison = calendar.compare(self, to: date, toGranularity: component)
        return comparison == .orderedSame || comparison == .orderedDescending
    }

    /// Checks if the date is less than another date based on the specified calendar component.
    func isLess(than date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        let comparison = calendar.compare(self, to: date, toGranularity: component)
        return comparison == .orderedAscending
    }

    /// Checks if the date is greater than another date based on the specified calendar component.
    func isGreater(than date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        let comparison = calendar.compare(self, to: date, toGranularity: component)
        return comparison == .orderedDescending
    }

}
