import Foundation

extension DateInterval {
    func monthsIncluded(using calendar: Calendar = .current) -> [Date] {
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
