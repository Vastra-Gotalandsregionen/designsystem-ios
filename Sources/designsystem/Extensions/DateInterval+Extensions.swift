import Foundation

extension DateInterval {
    /// Merges the current interval with the given interval and returns a new `DateInterval`.
    ///
    /// The resulting interval spans from the earliest start date to the latest end date
    /// of the two intervals.
    ///
    /// - Parameter dateInterval: The `DateInterval` to merge with the current interval.
    /// - Returns: A new `DateInterval` covering the combined range of both intervals.
    func mergeWith(_ dateInterval: DateInterval) -> DateInterval {
        return DateInterval(start: min(self.start, dateInterval.start),
                            end: max(self.end, dateInterval.end))
    }
}

extension DateInterval {
    
    /// Calculates the number of whole days between the start and end dates of the interval.
    ///
    /// - Returns: The number of full days in the interval, or `nil` if the calculation fails.
    var numberOfDays: Int? {
        Calendar.current.dateComponents([.day], from: start, to: end).day
    }
}

extension DateInterval {
    /// Creates a `DateInterval` from the given optional start and end dates.
    ///
    /// - Parameters:
    ///   - startDate: An optional `Date` representing the start of the interval.
    ///   - endDate: An optional `Date` representing the end of the interval.
    /// - Returns: A `DateInterval` if both `startDate` and `endDate` are non-nil; otherwise, returns `nil`.
    ///
    /// This method takes two optional `Date` parameters and returns an optional `DateInterval`. If either
    /// `startDate` or `endDate` is `nil`, the method returns `nil`. If both dates are present, a `DateInterval`
    /// is created from the start and end dates and returned.
    ///
    /// - Note: The `startDate` must be earlier than or equal to the `endDate` for the `DateInterval` to be valid.
    static func fromDates(_ startDate: Date?, _ endDate: Date?) -> DateInterval? {
        guard let start = startDate else { return nil }
        guard let end = endDate else { return nil }
        return DateInterval(start: start, end: end)
    }
}
