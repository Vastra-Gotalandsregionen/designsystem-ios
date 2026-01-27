import Foundation

public extension DateInterval {
    public func monthsIncluded(using calendar: Calendar = .current) -> [Date] {
        var dates: [Date] = []

        /// Start with the first of the start month
        guard let firstMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: start)) else {
            return []
        }

        var current = firstMonthStart

        while current <= end {
            dates.append(current)
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: current) else {
                break
            }
            current = nextMonth
        }

        return dates
    }
}

public extension DateInterval {
    /// mergeWith returns a new DateInterval by comparing and merging the upper and lower boundaries of the passed interval to self.
    public func mergeWith(_ dateInterval: DateInterval) -> DateInterval {
        return DateInterval(start: min(self.start, dateInterval.start), end: max(self.end, dateInterval.end))
    }
}

public extension DateInterval {
    /// The number of full calendar days between the start and end date
    public var numberOfDays: Int? {
        Calendar.current.dateComponents([.day], from: start, to: end).day
    }
}
