import Foundation

extension DateInterval {
    func generateMonths(_ calendar: Calendar = .current) -> [VGRCalendarIndexKey] {
        var months: [VGRCalendarIndexKey] = []
        var current = calendar.date(from: calendar.dateComponents([.year, .month], from: start))!

        while current <= end {
            months.append(VGRCalendarIndexKey(from: current, using: calendar))
            current = calendar.date(byAdding: .month, value: 1, to: current)!
        }

        return months
    }
}
