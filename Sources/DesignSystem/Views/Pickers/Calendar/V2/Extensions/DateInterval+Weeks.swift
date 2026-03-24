import Foundation

extension DateInterval {
    func generateWeeks(_ calendar: Calendar = .current) -> [VGRCalendarIndexKey] {
        guard let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: start)?.start else {
            return []
        }

        var weeks: [VGRCalendarIndexKey] = []
        var current = firstWeekStart

        while current <= end {
            weeks.append(VGRCalendarIndexKey(from: current, using: calendar))
            current = calendar.date(byAdding: .weekOfYear, value: 1, to: current)!
        }

        return weeks
    }
}
