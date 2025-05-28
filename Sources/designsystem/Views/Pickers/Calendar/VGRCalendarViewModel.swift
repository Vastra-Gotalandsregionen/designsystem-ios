import Foundation
import SwiftUI

@Observable final class VGRCalendarViewModel {

    var months: [VGRCalendarPeriodModel] = []
    var weeks: [VGRCalendarPeriodModel] = []

    private let calendar: Calendar
    private let interval: DateInterval

    private var weekIDLookup: [String: VGRCalendarPeriodModel] = [:]

    init(interval: DateInterval, calendar: Calendar = .current) {
        self.interval = interval
        self.calendar = calendar
        self.months = self.generateMonths(for: interval, calendar: calendar)
        self.weeks = self.generateWeeks(for: interval, calendar: calendar)
    }

    func periodForWeekID(_ weekID: String?) -> VGRCalendarPeriodModel? {
        guard let weekID else { return nil }
        if let p = weekIDLookup[weekID] { return p }

        if let p = weeks.filter({ $0.idx.weekID == weekID }).first {
            weekIDLookup[weekID] = p
            return p
        }

        return nil
    }

    private func generateWeeks(for interval: DateInterval, calendar: Calendar) -> [VGRCalendarPeriodModel] {
        var weeks: [VGRCalendarPeriodModel] = []

        guard let startOfFirstWeek = calendar.dateInterval(of: .weekOfYear, for: interval.start)?.start else {
            return []
        }

        var currentWeekStart = startOfFirstWeek

        while currentWeekStart <= interval.end {
            let days = (0..<7).compactMap { offset -> VGRCalendarIndexKey? in
                guard let day = calendar.date(byAdding: .day, value: offset, to: currentWeekStart) else {
                    return nil
                }
                return VGRCalendarIndexKey(from: day)
            }

            weeks.append(VGRCalendarPeriodModel(
                idx: VGRCalendarIndexKey(from: currentWeekStart),
                days: days,
                leadingPadding: 0
            ))

            /// Move to next week
            guard let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) else {
                break
            }

            currentWeekStart = nextWeekStart
        }

        return weeks
    }

    private func generateMonths(for interval: DateInterval, calendar: Calendar) -> [VGRCalendarPeriodModel] {
        return interval.monthsIncluded().map { date in
            let result = generateCalendarGrid(for: date, calendar: calendar)

            return VGRCalendarPeriodModel(
                idx: CalendarIndexKey(from: date),
                days: result.dates,
                leadingPadding: result.leadingPadding
            )
        }
    }

    private func generateCalendarGrid(for date: Date, calendar: Calendar) -> (leadingPadding:Int, dates:[VGRCalendarIndexKey]) {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return (0, [])
        }
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: firstDay) else { return (0, []) }
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return (0, []) }

        let grid = range.compactMap { day -> VGRCalendarIndexKey? in
            guard let newDate = calendar.date(bySetting: .day, value: day, of: monthInterval.start) else { return nil }
            return VGRCalendarIndexKey(from: newDate)
        }

        let startWeekday = calendar.component(.weekday, from: firstDay)
        let firstWeekday = calendar.firstWeekday
        let leadingEmpty = (startWeekday - firstWeekday + 7) % 7

        return (leadingEmpty, grid)
    }
}
