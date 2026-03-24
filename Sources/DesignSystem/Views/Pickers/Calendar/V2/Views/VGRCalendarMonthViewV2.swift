import SwiftUI

struct VGRCalendarMonthViewV2<T: Identifiable & Equatable, MonthHeader: View, DayContent: View>: View {

    /// The calendar used for week generation and date calculations
    let calendar: Calendar

    /// The calendar index key representing this month (used to generate weeks and display the month name)
    let index: VGRCalendarIndexKey

    /// Dictionary mapping each day to its data entry, looked up via O(1) subscript per day cell
    @Binding var data: [VGRCalendarIndexKey: T]

    /// The currently selected date, compared against each day to determine selection state
    @Binding var selectedDate: VGRCalendarIndexKey

    /// Custom month header builder, receiving the month key and an array of data entries for that month
    @ViewBuilder var monthHeader: (VGRCalendarIndexKey, [T]) -> MonthHeader

    /// Custom view builder for each day cell, receiving the day key, optional data, and selection state
    @ViewBuilder var dayContent: (VGRCalendarIndexKey, T?, Bool) -> DayContent

    /// Pre-computed grid of weeks for this month, where nil represents padding days outside the month
    private let weeks: [[VGRCalendarIndexKey?]]

    init(calendar: Calendar = .current,
         index: VGRCalendarIndexKey,
         data: Binding<[VGRCalendarIndexKey: T]>,
         selectedDate: Binding<VGRCalendarIndexKey>,
         @ViewBuilder monthHeader: @escaping (VGRCalendarIndexKey, [T]) -> MonthHeader,
         @ViewBuilder dayContent: @escaping (VGRCalendarIndexKey, T?, Bool) -> DayContent) {
        self.calendar = calendar
        self.index = index
        self._data = data
        self._selectedDate = selectedDate
        self.monthHeader = monthHeader
        self.dayContent = dayContent
        self.weeks = index.generateWeeks(calendar)
    }

    /// Collects all data entries for days in this month via O(1) lookups
    private var monthEntries: [T] {
        weeks.flatMap { $0.compactMap { $0 } }
            .compactMap { data[$0] }
    }

    var body: some View {
        VStack(spacing: 16) {
            monthHeader(index, monthEntries)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                VGRCalendarWeekdaysViewV2(calendar: calendar)
                    .accessibilityHidden(true)

                Grid(horizontalSpacing: 2, verticalSpacing: 8) {
                    ForEach(0..<weeks.count, id: \.self) { weekIndex in
                        GridRow(alignment: .top) {
                            ForEach(0..<weeks[weekIndex].count, id: \.self) { dayIndex in
                                if let day = weeks[weekIndex][dayIndex] {
                                    dayContent(day, data[day], day == selectedDate)
                                        .id(day.dayID)
                                        .gridCellUnsizedAxes(.vertical)

                                } else {
                                    Color.clear
                                        .gridCellUnsizedAxes(.horizontal)
                                }
                            }
                        }
                    }
                }
                .accessibilityElement(children: .contain)
            }
        }
        .padding(16)
        .background(Color.Elevation.elevation1)
    }
}

#Preview {
    @Previewable @State var data: [VGRCalendarIndexKey: ExampleEventData] = [:]
    @Previewable @State var selectedDate: VGRCalendarIndexKey = VGRCalendarIndexKey(year: 1978, month: 9, day: 23)
    NavigationStack {
        ScrollView {
            VGRCalendarMonthViewV2(index: VGRCalendarIndexKey(year: 1978, month: 9, day: 23),
                              data: $data,
                              selectedDate: $selectedDate) { month, entries in
                Text(month.monthName())
                    .font(.title2).fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } dayContent: { day, entry, selected in
                ExampleDayView(index: day,
                               data: entry,
                               selected: selected)
            }
        }
        .navigationTitle("VGRCalendarMonthViewV2")
        .navigationBarTitleDisplayMode(.inline)
    }
}
