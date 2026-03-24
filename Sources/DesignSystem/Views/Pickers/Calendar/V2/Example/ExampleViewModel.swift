import Foundation
import SwiftUI

@MainActor
@Observable
class ExampleViewModel {

    var data: [VGRCalendarIndexKey: ExampleEventData] = [:]
    var calendarDateInterval: DateInterval
    var selectedDate: VGRCalendarIndexKey

    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        let now = Date()
        calendarDateInterval = DateInterval(
            start: calendar.date(byAdding: .month, value: -12, to: now)!,
            end: calendar.date(byAdding: .month, value: 12, to: now)!
        )

        selectedDate = .init(calendar, now)
    }

    func loadEvents() async {
        try? await Task.sleep(for: .seconds(3))

        let calendar = self.calendar
        let result = await Task.detached {
            let today = Date()
            var result: [VGRCalendarIndexKey: ExampleEventData] = [:]

            for dayOffset in -60...60 {
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
                let key = VGRCalendarIndexKey(from: date, using: calendar)

                if dayOffset != 0 {
                    guard Double.random(in: 0...1) < 0.3 else { continue }
                }
                let eventCount = Int.random(in: 1...3)
                let events = (0..<eventCount).map { _ in
                    ExampleEvent(type: ExampleEventType.allCases.randomElement()!)
                }
                result[key] = ExampleEventData(isToday: dayOffset == 0, events: events)
            }
            return result
        }.value

        var transaction = Transaction(animation: .snappy)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            data = result
        }
    }

    func updateEvents() async {
        let calendar = self.calendar
        let result = await Task.detached {
            let today = Date()
            var result: [VGRCalendarIndexKey: ExampleEventData] = [:]

            for dayOffset in -60...60 {
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
                let key = VGRCalendarIndexKey(from: date, using: calendar)

                if dayOffset != 0 {
                    guard Double.random(in: 0...1) < 0.3 else { continue }
                }
                let eventCount = Int.random(in: 1...3)
                let events = (0..<eventCount).map { _ in
                    ExampleEvent(type: ExampleEventType.allCases.randomElement()!)
                }
                result[key] = ExampleEventData(isToday: dayOffset == 0, events: events)
            }
            return result
        }.value

        var transaction = Transaction(animation: .snappy)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            data = result
        }
    }

    func randomizeDateInterval() {
        let now = Date()
        let extraStart = Int.random(in: 1...6)
        let extraEnd = Int.random(in: 1...6)
        calendarDateInterval = DateInterval(
            start: calendar.date(byAdding: .month, value: -(12 + extraStart), to: now)!,
            end: calendar.date(byAdding: .month, value: 12 + extraEnd, to: now)!
        )
    }

}
