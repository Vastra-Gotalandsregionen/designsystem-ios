import Foundation

public extension Calendar {
    // Source: https://sarunw.com/posts/getting-number-of-days-between-two-dates/
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)

        return numberOfDays.day! + 1 // <1>
    }

    // <1> Includes the start date
}

public extension Calendar {
    func daysBetween(_ startDate: Date?, endDate: Date?) -> [Date] {
        guard let startedAt = startDate else { return [] }
        guard let endedAt = endDate else { return [startedAt] }
        let dayCount = numberOfDaysBetween(startedAt, and: endedAt)
        if dayCount <= 0 { return [startedAt] }

        let result = (0 ... dayCount - 1).map {
            let newDate = self.date(byAdding: .day, value: $0, to: startedAt)
            if let date = newDate {
                return date
            }
            return Date()
        }

        return result
    }
}

public extension Calendar {
    func lessThanOrEqual(_ startDate: Date, _ endDate: Date, precision: Component = .day) -> Bool {
        let result = self.compare(startDate, to: endDate, toGranularity: precision)
        switch result {
            case .orderedAscending, .orderedSame:
                return true
            case .orderedDescending:
                return false
        }
    }

    func lessThan(_ startDate: Date, _ endDate: Date, precision: Component = .day) -> Bool {
        let result = self.compare(startDate, to: endDate, toGranularity: precision)
        switch result {
            case .orderedAscending:
                return true
            case .orderedDescending, .orderedSame:
                return false
        }
    }

    func greaterThanOrEqual(_ startDate: Date, _ endDate: Date, precision: Component = .day) -> Bool {
        let result = self.compare(startDate, to: endDate, toGranularity: precision)
        switch result {
            case .orderedDescending, .orderedSame:
                return true
            case .orderedAscending:
                return false
        }
    }

    func greaterThan(_ startDate: Date, _ endDate: Date, precision: Component = .day) -> Bool {
        let result = self.compare(startDate, to: endDate, toGranularity: precision)
        switch result {
            case .orderedDescending:
                return true
            case .orderedAscending, .orderedSame:
                return false
        }
    }

    func isSameDay(_ startDate: Date, _ endDate: Date, precision: Component = .day) -> Bool {
        let result = self.compare(startDate, to: endDate, toGranularity: precision)
        switch result {
            case .orderedDescending, .orderedAscending:
                return false
            case .orderedSame:
                return true
        }
    }
}

public extension Calendar {
    func date(_ year: Int = 2023,
              _ month: Int = 9,
              _ day: Int = 16,
              time hour: Int = 12,
              _ minute: Int = 30,
              _ second: Int = 30) -> Date
    {
        let dc = DateComponents(calendar: self,
                                year: year,
                                month: month,
                                day: day,
                                hour: hour,
                                minute: minute,
                                second: second)

        if let date = dc.date {
            return date
        }

        return Date()
    }
}

public extension Calendar {
    func addDays(_ days: Int, to date: Date) -> Date {
        let newDate = self.date(byAdding: .day, value: days, to: date)!
        return newDate
    }
}

public extension Calendar {

    /// formatDate turns a Date into a presentable string
    /// If the year is not the current year, year is shown
    /// If the allDay flag is set to true, time is omitted
    func formatDate(_ date: Date, showWeekday: Bool = false, allDay: Bool = true) -> String {
        let now = Date()
        let dateYear = self.component(.year, from: date)
        let currentYear: Int = now.year
        let showYear: Bool = dateYear != currentYear

        var parts: [String] = []

        /// monday 23 december
        /// monday 23 december, 12:13
        /// monday 23 december 2023, 12:13

        if showWeekday {
            parts.append(date.formatted(.dateTime.weekday(.wide)))
            parts.append(" ")
        }

        parts.append(date.formatted(.dateTime.day()))
        parts.append(" ")
        parts.append(date.formatted(.dateTime.month(.wide)))

        if showYear {
            parts.append(" ")
            parts.append(date.formatted(.dateTime.year()))
        }

        if !allDay {
            parts.append(", ")
            parts.append(date.formatted(date: .omitted, time: .shortened))
        }

        return parts.joined()
    }

    /// formatDateInterval turns a DateInterval into a presentable string
    /// If the start/end differs in terrms of years, year is shown on both start/end
    /// If the start/end differs in terms of months, month is shown on both start/end
    /// If the start/end is within the same month and year, only day-interval and month are shown
    /// If the end-date is today, a string "Today" shows instead of the actual date.
    func formatDateInterval(_ interval: DateInterval, allDay: Bool = true, a11y: Bool = false, forceShowEndDate: Bool = false) -> String {
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: interval.start)
        let endYear = calendar.component(.year, from: interval.end)
        let showYear: Bool = startYear != endYear
        let currentYear: Int = calendar.component(.year, from: Date())
        let isToday = calendar.isDateInToday(interval.end) && !forceShowEndDate
        let startMonth = calendar.component(.month, from: interval.start)
        let endMonth = calendar.component(.month, from: interval.end)
        let showMonth: Bool = (startMonth != endMonth) || isToday

        var parts: [String] = []

        /// If the String:s purpose is A11Y, replace the seperator with readable String
        let separator = a11y ? LocalizedHelper.localized(forKey: "a11y.to") : "-"

        /// Start/End month differs
        if showMonth {

            /// 23 September
            parts.append(interval.start.formatted(.dateTime.day()))
            parts.append(interval.start.formatted(.dateTime.month(.wide)))

            if !allDay {
                /// 23 September 13:37
                parts.append(interval.start.formatted(date: .omitted, time: .shortened))
            }

            if showYear {
                /// 23 September 2024
                parts.append(interval.start.formatted(.dateTime.year()))
            }

            parts.append(separator)

            if isToday {
                /// Today
                parts.append(LocalizedHelper.localized(forKey: "general.today"))
            } else {
                /// 23 September
                parts.append(interval.end.formatted(.dateTime.day()))
                parts.append(interval.end.formatted(.dateTime.month(.wide)))
            }

            if !allDay && !isToday {
                /// 23 September 13:37
                parts.append(interval.end.formatted(date: .omitted, time: .shortened))
            }

            if (showYear || currentYear != endYear) && (!isToday)  {
                /// 23 September 2024
                parts.append(interval.end.formatted(.dateTime.year()))
            }

        } else {
            if showYear {
                /// 23 September 2024
                parts.append(interval.start.formatted(.dateTime.day()))
                parts.append(interval.start.formatted(.dateTime.month(.wide)))
                parts.append(interval.start.formatted(.dateTime.year()))

                if !allDay {
                    /// 23 September 2024 13:37
                    parts.append(interval.start.formatted(date: .omitted, time: .shortened))
                }

                parts.append(separator)

                if isToday {
                    /// Today
                    parts.append("general.today".localized)
                } else {
                    /// 23 September 2024
                    parts.append(interval.end.formatted(.dateTime.day()))
                    parts.append(interval.end.formatted(.dateTime.month(.wide)))
                    parts.append(interval.end.formatted(.dateTime.year()))
                }

                if !allDay && !isToday {
                    /// 23 September 2024 13:37
                    parts.append(interval.end.formatted(date: .omitted, time: .shortened))
                }

            } else {
                /// 23
                parts.append(interval.start.formatted(.dateTime.day()))
                if !allDay {
                    /// 23 September 13:37
                    parts.append(interval.start.formatted(.dateTime.month(.wide)))
                    parts.append(interval.start.formatted(date: .omitted, time: .shortened))
                }

                parts.append(separator)

                if isToday {
                    /// Today
                    parts.append("general.today".localized)
                } else {
                    /// 23 September
                    parts.append(interval.end.formatted(.dateTime.day()))
                    parts.append(interval.end.formatted(.dateTime.month(.wide)))
                }

                if !allDay && !isToday {
                    /// 23 September 13:37
                    parts.append(interval.end.formatted(date: .omitted, time: .shortened))
                }

                if (currentYear != endYear) && (!isToday) {
                    /// 23 September 2024
                    parts.append(interval.end.formatted(.dateTime.year()))
                }
            }
        }

        return parts.joined(separator: " ")
    }

}

public extension Calendar {
    func weekdays(in interval: DateInterval, matching weekdays: [Int]) -> [Date] {
        var matchedDates = [Date]()
        var currentDate = interval.start

        // Loop through each day within the interval
        while currentDate <= interval.end {
            // Check if the current day's weekday matches any of the desired weekdays
            let currentWeekday = component(.weekday, from: currentDate)
            if weekdays.contains(currentWeekday) {
                matchedDates.append(currentDate)
            }

            // Move to the next day
            currentDate = date(byAdding: .day, value: 1, to: currentDate)!
        }

        return matchedDates
    }
}

public extension Calendar {
    /// dateWithSpecificDay expects a _date_ and a _dayIndex_ and returns an optional date.
    /// The _from_ dates year and month are combined with the _dayIndex_ to create a Date with a specifc day.
    /// If the month in question has less number of days than the ones dictated by _dayIndex_, this method
    /// returns the last day of the month.
    func dateWithSpecificDay(from date: Date, dayIndex: Int) -> Date? {
        let components = dateComponents([.year, .month], from: date)
        guard let year = components.year, let month = components.month else { return nil }

        let range = range(of: .day, in: .month, for: date)
        guard let range else { return nil }

        let lastDayOfMonth = range.upperBound - 1

        var actualDayIndex = dayIndex
        if actualDayIndex > lastDayOfMonth {
            actualDayIndex = lastDayOfMonth
        }

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = actualDayIndex

        return self.date(from: dateComponents)
    }
}

public extension Calendar {
    func combinedDateTime(date: Date, time: Date) -> Date? {
        /// Extract components from the date and time
        let dateComponents = self.dateComponents([.year, .month, .day], from: date)
        let timeComponents = self.dateComponents([.hour, .minute, .second], from: time)

        /// Create a new date with the date components from the first parameter and time components from the second parameter
        return self.date(from: DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: timeComponents.hour, minute: timeComponents.minute, second: timeComponents.second))
    }
}

public extension Calendar {
    func areEqual(_ date1: Date?, date2: Date?) -> Bool {
        /// use nil to compare
        if date1 == nil && date2 == nil { return true }
        if date1 == nil && date2 != nil { return false }
        if date1 != nil && date2 == nil { return false }

        /// Unwrap
        guard let date1abs = date1 else { return false }
        guard let date2abs = date2 else { return false }

        /// Compare
        return self.compare(date1abs, to: date2abs, toGranularity: .day) == .orderedSame
    }
}

public extension Calendar {

    /// weeksInMonth returns a nil-padded 2-dimensional array containing the dates for the requested month
    /// nils are used to pad out the week in order to be displayed in a calendar view
    func weeksInMonth(for month: Int, year: Int) -> [[Date?]]? {
        var weeks: [[Date?]] = []

        let components = DateComponents(year: year, month: month, hour: 12, minute: 0, second: 0)
        guard let firstDayOfMonth = self.date(from: components),
              let range = self.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return nil
        }

        var currentWeek: [Date?] = Array(repeating: nil, count: 7)

        for day in range {
            guard let date = self.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) else { continue }
            let weekday = self.component(.weekday, from: date)
            let weekdayIndex = (weekday + 5) % 7 // Adjust to make Monday = 0 and Sunday = 6


            currentWeek[weekdayIndex] = date

            if weekdayIndex == 6 { // End of the week (Sunday)
                weeks.append(currentWeek)
                currentWeek = Array(repeating: nil, count: 7)
            }
        }

        if currentWeek.contains(where: { $0 != nil }) {
            weeks.append(currentWeek) // Append the last week if it contains any dates
        }

        return weeks
    }

}

public extension Calendar {

    /// Returns an array of dates with one date per month in the given interval.
    /// - Parameters:
    ///   - interval: The `DateInterval` defining the range.
    ///   - preferredDay: The day of the month to use (e.g., 1 for the first day of the month). Defaults to 1.
    /// - Returns: An array of `Date` objects, one for each month in the interval.
    func datesByMonth(in interval: DateInterval, preferredDay: Int = 1) -> [Date] {
        guard let startOfFirstMonth = self.date(from: self.dateComponents([.year, .month], from: interval.start)),
              let endOfLastMonth = self.date(from: self.dateComponents([.year, .month], from: interval.end)) else {
            return []
        }

        var dates: [Date] = []
        var currentMonth = startOfFirstMonth

        while currentMonth <= endOfLastMonth {
            if let preferredDate = self.date(bySetting: .day, value: preferredDay, of: currentMonth) {
                dates.append(preferredDate)
            }

            // Move to the first day of the next month
            guard let nextMonth = self.date(byAdding: .month, value: 1, to: currentMonth) else {
                break
            }
            currentMonth = nextMonth
        }

        return dates
    }

}

public extension Calendar {
    func dateInterval(from date: Date, count: Int, component: Calendar.Component) -> DateInterval? {
        /// Create a date by adding (and removing) the date components to the given date
        guard let startDate = self.date(byAdding: component, value: -count, to: date),
              let endDate = self.date(byAdding: component, value: count, to: date) else {
            return nil
        }

        return DateInterval(start: startDate, end: endDate)
    }

}

extension Calendar {
    func weekIntervalExact(containing date: Date) -> DateInterval? {
        guard let start = self.dateInterval(of: .weekOfYear, for: date)?.start,
              let end = self.date(byAdding: DateComponents(day: 6), to: start),
              let endOfDay = self.date(bySettingHour: 23, minute: 59, second: 59, of: end)
        else {
            return nil
        }

        return DateInterval(start: start, end: endOfDay)
    }
}

import Foundation

extension Calendar {
    /// Returns the start date of the week that contains the specified date.
    ///
    /// - Parameter date: The date for which to find the start of the week.
    /// - Returns: A `Date` representing the start of the week (e.g., Monday or Sunday, depending on the calendar).
    ///
    /// This method uses the `.yearForWeekOfYear` and `.weekOfYear` components to construct
    /// the start of the week. It respects the calendar's locale and configuration, such as
    /// what day the week starts on.
    ///
    /// - Note: This force-unwraps the result of `self.date(from:)`. In practice, it is safe
    ///         because the provided components are guaranteed to be valid for the calendar.
    func startOfWeek(for date: Date) -> Date {
        self.date(from: self.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date))!
    }
}
