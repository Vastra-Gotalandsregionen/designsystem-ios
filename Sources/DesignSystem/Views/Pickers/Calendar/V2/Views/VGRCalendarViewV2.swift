import SwiftUI

struct VGRCalendarViewV2<T: Identifiable & Equatable, MonthHeader: View, DayContent: View>: View {

    /// The calendar used for date calculations
    var calendar: Calendar = .current

    /// Controls which months are rendered
    var interval: DateInterval

    /// Private structure that contains an CalendarIndexKey for each month that shows up in the calendar.
    @State private var months: [VGRCalendarIndexKey] = []

    /// Contains data for each and every day
    @Binding var data: [VGRCalendarIndexKey: T]

    /// The currently selected date
    @Binding var selectedDate: VGRCalendarIndexKey

    /// Controls the scrollposition (which month is scrolled to)
    @Binding var scrollPosition: ScrollPosition

    /// Custom month header builder, receiving the month key and an array of data entries for that month
    @ViewBuilder var monthHeader: (VGRCalendarIndexKey, [T]) -> MonthHeader

    /// Custom day view builder
    @ViewBuilder var dayContent: (VGRCalendarIndexKey, T?, Bool) -> DayContent

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                ForEach(months, id: \.monthID) { month in
                    VGRCalendarMonthViewV2(calendar: calendar,
                                      index: month,
                                      data: $data,
                                      selectedDate: $selectedDate,
                                      monthHeader: monthHeader,
                                      dayContent: dayContent)
                        .id(month.monthID)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition($scrollPosition, anchor: .top)
        .accessibilityRotor("calendar.accessibility.months".localized) {
            ForEach(months, id: \.monthID) { month in
                AccessibilityRotorEntry(month.monthName(calendar), id: month.monthID)
            }
        }
        .onChange(of: interval, initial: true) {
            months = interval.generateMonths(calendar)
        }
    }
}
