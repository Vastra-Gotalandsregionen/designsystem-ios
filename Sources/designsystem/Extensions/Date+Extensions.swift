import Foundation

/// Source: https://stackoverflow.com/a/20158940/254695
public extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }

    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }

    var nextMonth: Date {
        var components = DateComponents()
        components.month = 1
        return Calendar.current.date(byAdding: components, to: self)!
    }
}


public extension Date {
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
    var year: Int {
        Calendar.current.dateComponents([.year], from: self).year!
    }

    var month: Int {
        Calendar.current.dateComponents([.month], from: self).month!
    }

    var dayInMonth: Int {
        Calendar.current.dateComponents([.day], from: self).day!
    }

    var hour: Int {
        Calendar.current.dateComponents([.hour], from: self).hour!
    }

    var minute: Int {
        Calendar.current.dateComponents([.minute], from: self).minute!
    }

    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
}

public extension Date {
    /// vgrDateFormat formats a date with full day and month name, but only includes year if it differs from current year
    var vgrDateFormat: String {
        if Calendar.current.compare(Date(), to: self, toGranularity: .year) == .orderedSame {
            return self.formatted(.dateTime.day().month(.wide))
        }
        return self.formatted(.dateTime.day().month(.wide).year())
    }

    /// vgrMonthFormat formats a date with full month name, but only includes year if it differs from current year
    var vgrMonthFormat: String {
        if Calendar.current.compare(Date(), to: self, toGranularity: .year) == .orderedSame {
            return self.formatted(.dateTime.month(.wide))
        }
        return self.formatted(.dateTime.month(.wide).year())
    }

    /// vgrWeekFormat formats a date with week number, but only includes year if it differs from current year
    var vgrWeekFormat: String {
        if Calendar.current.compare(Date(), to: self, toGranularity: .year) == .orderedSame {
            return "v " + self.formatted(.dateTime.week())
        }

        return "v " + self.formatted(.dateTime.week()) + ", " + self.formatted(.dateTime.year())
    }

    var vgrShortTimeFormat: String {
        return self.formatted(date: .omitted, time: .shortened)
    }

    var vgrDateTimeFormat: String {
        return "\(self.vgrDateFormat) \(self.vgrShortTimeFormat)"
    }

    var vgrDateTimeA11yFormat: String {
        return "\(self.vgrDateFormat) \("general.time.at".localized.lowercased()) \(self.vgrShortTimeFormat)"
    }
}

public extension Date {

    func isWithin(_ interval: DateInterval, calendar: Calendar = .current) -> Bool {
        let startDate = calendar.startOfDay(for: interval.start)
        let endDate = calendar.startOfDay(for: interval.end)
        let targetDate = calendar.startOfDay(for: self)

        return targetDate >= startDate && targetDate <= endDate
    }

}

public extension Date {

    func isEqual(to date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        return calendar.compare(self, to: date, toGranularity: component) == .orderedSame
    }

    func isEqualOrLess(than date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        let comparison = calendar.compare(self, to: date, toGranularity: component)
        return comparison == .orderedSame || comparison == .orderedAscending
    }

    func isEqualOrGreater(than date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        let comparison = calendar.compare(self, to: date, toGranularity: component)
        return comparison == .orderedSame || comparison == .orderedDescending
    }

    func isLess(than date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        let comparison = calendar.compare(self, to: date, toGranularity: component)
        return comparison == .orderedAscending
    }

    func isGreater(than date: Date, calendar: Calendar = .current, component: Calendar.Component = .day) -> Bool {
        let comparison = calendar.compare(self, to: date, toGranularity: component)
        return comparison == .orderedDescending
    }

}
