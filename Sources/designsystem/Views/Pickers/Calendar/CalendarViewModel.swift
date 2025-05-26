import Foundation
import SwiftUI

@Observable final class CalendarViewModel {

    var months: [CalendarPeriodModel] = []
    var weeks: [CalendarPeriodModel] = []

    private let calendar: Calendar
    private let interval: DateInterval

    init(interval: DateInterval, calendar: Calendar = .current) {
        self.interval = interval
        self.calendar = calendar
        self.months = self.generateMonths(for: interval, calendar: calendar)
        self.weeks = self.generateWeeks(for: interval, calendar: calendar)
    }

    private func generateWeeks(for interval: DateInterval, calendar: Calendar) -> [CalendarPeriodModel] {
        var weeks: [CalendarPeriodModel] = []

        guard let startOfFirstWeek = calendar.dateInterval(of: .weekOfYear, for: interval.start)?.start else {
            return []
        }

        var currentWeekStart = startOfFirstWeek

        while currentWeekStart <= interval.end {
            let days = (0..<7).compactMap { offset -> CalendarIndexKey? in
                guard let day = calendar.date(byAdding: .day, value: offset, to: currentWeekStart) else {
                    return nil
                }
                return CalendarIndexKey(from: day)
            }

            weeks.append(CalendarPeriodModel(
                date: currentWeekStart,
                idx: CalendarIndexKey(from: currentWeekStart),
                days: days,
                leadingPadding: 0
            ))

            // Move to next week
            guard let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) else {
                break
            }

            currentWeekStart = nextWeekStart
        }

        return weeks
    }

    private func generateMonths(for interval: DateInterval, calendar: Calendar) -> [CalendarPeriodModel] {
        return interval.monthsIncluded().map { date in
            let result = generateCalendarGrid(for: date, calendar: calendar)

            return CalendarPeriodModel(
                date: date,
                idx: CalendarIndexKey(from: date),
                days: result.dates,
                leadingPadding: result.leadingPadding
            )
        }
    }

    private func generateCalendarGrid(for date: Date, calendar: Calendar) -> (leadingPadding:Int, dates:[CalendarIndexKey]) {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return (0, [])
        }
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: firstDay) else { return (0, []) }
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return (0, []) }

        let grid = range.compactMap { day -> CalendarIndexKey? in
            guard let newDate = calendar.date(bySetting: .day, value: day, of: monthInterval.start) else { return nil }
            return CalendarIndexKey(from: newDate)
        }

        let startWeekday = calendar.component(.weekday, from: firstDay)
        let firstWeekday = calendar.firstWeekday
        let leadingEmpty = (startWeekday - firstWeekday + 7) % 7

        return (leadingEmpty, grid)
    }
}
