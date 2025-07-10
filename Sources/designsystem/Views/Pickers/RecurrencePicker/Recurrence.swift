import Foundation

public struct Recurrence: Codable, Equatable, Hashable {

    /// frequency is used to control the basic frequency (every, every 2nd, etc)
    public var frequency: Int

    /// period is used to control which period (day, week, month)
    public var period: RecurrencePeriod

    /// index is used to indicate which day in the month
    public var index: Int?

    /// weekdays is used to control which weekdays are affected
    /// this is only applicable when period is set to _week_
    public var weekdays: [RecurrenceWeekday]?

    enum CodingKeys: String, CodingKey {
        case frequency = "frequency"
        case period = "period"
        case index = "index"
        case weekdays = "weekdays"
    }

    public init(frequency: Int, period: RecurrencePeriod, index: Int? = nil, weekdays: [RecurrenceWeekday]? = nil) {
        self.frequency = frequency
        self.period = period
        self.index = index
        self.weekdays = weekdays
    }

    /// decodeFromString takes a string containing a JSON object and decodes it into a `Recurrence` struct.
    /// If the decoding fails, nil is returned.
    public static func decodeFromString(_ recurrenceString: String?) -> Recurrence? {
        guard let recurrenceString else { return nil }
        do {
            return try JSONDecoder().decode(Recurrence.self, from: Data(recurrenceString.utf8))
        } catch {
            return nil
        }
    }

    /// conform to Equatable
    public static func == (lhs: Recurrence, rhs: Recurrence) -> Bool {
        return lhs.frequency == rhs.frequency &&
                lhs.period == rhs.period &&
                lhs.index == rhs.index &&
                lhs.weekdays == rhs.weekdays
    }

    public func formatString(startDate: Date? = nil) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .ordinal
        nf.locale = .current

        var every: String = ""
        if self.frequency > 4 {
            if let num = nf.string(for: self.frequency) {

                every = "\(LocalizedHelper.localized(forKey: "recurrence.every")) \(num)"
            }
        } else {
            every = LocalizedHelper.localized(forKey: "recurrence.every.\(self.frequency)")
        }

        let period = LocalizedHelper.localized(forKey: "recurrence.period.\(self.period.description)")

        if self.period == .week {
            if let selectedWeekdays = self.weekdays {
                let weekdays = selectedWeekdays.sorted().map{ LocalizedHelper.localized(forKey: "recurrence.weekday.\($0.description).plural").lowercased()}
                let lf = ListFormatter()
                let dateOn = LocalizedHelper.localized(forKey: "recurrence.date.on")
                return "\(every) \(period.lowercased()) \(dateOn) \(lf.string(from: weekdays) ?? "")"
            }
        }

        if self.period == .month {
            if let startDate {
                let dayInMonth = startDate.dayInMonth
                if let num = nf.string(for: dayInMonth) {
                    let dateThe = LocalizedHelper.localized(forKey: "recurrence.date.the")
                    return "\(every) \(period.lowercased()) \(dateThe) \(num)"
                }
            }
        }

        return "\(every) \(period.lowercased())"
    }

    /// Calculates recurring dates within a dateInterval using the provided recurrence pattern.
    /// If provided, the _filter_ parameter is used to further reduce the returned entries.
    public func getRecurringDates(for dateInterval: DateInterval,
                                  filter: DateInterval? = nil) -> [Date] {
        let calendar = Calendar.current
        let interval = DateInterval(start: dateInterval.start.startOfDay, end: dateInterval.end.endOfDay)
        var currentDate = interval.start

        var dates: [Date] = []
        let addDate: (Date) -> Void = { date in
            if interval.contains(date) {
                if let filter {
                    if filter.contains(date) { dates.append(date) }
                } else {
                    dates.append(date)
                }
            }
        }

        var failSafe: Int = 10

        while calendar.compare(currentDate, to: interval.end, toGranularity: .day) == .orderedAscending ||
                calendar.compare(currentDate, to: interval.end, toGranularity: .day) == .orderedSame {
            if failSafe <= 0 { break }

            switch self.period {
                case .day:
                    // Every X:th day
                    addDate(currentDate)

                    guard let nextDate = calendar.date(byAdding: .day, value: self.frequency, to: currentDate) else { failSafe-=1; break }
                    currentDate = nextDate

                case .week:
                    // Every X:th week on [Y] days
                    guard let weekdays = self.weekdays else { failSafe-=1; break }

                    let currentWeek = DateInterval(start: currentDate.startOfWeek.startOfDay, end: currentDate.endOfWeek.endOfDay)

                    let weekdayInts = weekdays.map { Int($0.rawValue) }
                    let days = calendar.weekdays(in: currentWeek, matching: weekdayInts)
                    for day in days { addDate(day) }

                    guard let nextDate = calendar.date(byAdding: .weekOfYear,
                                                       value: self.frequency,
                                                       to: currentDate) else { failSafe-=1; break }
                    currentDate = nextDate

                case .month:
                    // Every X:th month on the Y:th day
                    var dayIndex = self.index ?? -1
                    if dayIndex == -1 {
                        dayIndex = dateInterval.start.dayInMonth
                    }

                    guard let date = calendar.dateWithSpecificDay(from: currentDate, dayIndex: dayIndex) else { failSafe-=1; break }

                    addDate(date)

                    guard let nextDate = calendar.date(byAdding: .month, value: self.frequency, to: currentDate) else { failSafe-=1; break }
                    currentDate = nextDate
            }
        }

        return dates
    }
}

public enum RecurrencePeriod: Int, CaseIterable, Identifiable, Codable {
    case day = 0
    case week = 1
    case month = 2
    
    public var id: Self { self }
    public var description: String {
        switch self {
            case .day: "day"
            case .week: "week"
            case .month: "month"
        }
    }
}

public enum RecurrenceWeekday: Int, CaseIterable, Identifiable, Codable, Comparable {
    public static func < (lhs: RecurrenceWeekday, rhs: RecurrenceWeekday) -> Bool {
        let l: Int = (lhs == .sunday) ? 8 : lhs.rawValue
        let r: Int = (rhs == .sunday) ? 8 : rhs.rawValue
        return l < r
    }

    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    public var id: Self { self }
    public var description: String {
        switch self {
            case .monday: "mon"
            case .tuesday: "tue"
            case .wednesday: "wed"
            case .thursday: "thu"
            case .friday: "fri"
            case .saturday: "sat"
            case .sunday: "sun"
        }
    }
}
