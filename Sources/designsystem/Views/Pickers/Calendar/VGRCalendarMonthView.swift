import Foundation
import SwiftUI

public struct VGRCalendarMonthView<Data, Content>: View where Data: Hashable, Content: View {

    /// month contains information about the current months layout (days, padding)
    let month: VGRCalendarPeriodModel

    /// today is the date/index for the current date
    let today: VGRCalendarIndexKey

    /// selectedIndex binds to a index key, used to detect changes in the currently selected day
    @Binding var selectedIndex: VGRCalendarIndexKey

    /// contains the data for each separate day
    let data: [VGRCalendarIndexKey: Data]

    public init(month: VGRCalendarPeriodModel,
                today: VGRCalendarIndexKey,
                selectedIndex: Binding<VGRCalendarIndexKey>,
                data: [VGRCalendarIndexKey: Data] = [:],
                using calendar: Calendar = .current,
                onTapDay: @escaping (VGRCalendarIndexKey) -> Void = { _ in },
                @ViewBuilder day: @escaping (VGRCalendarIndexKey, Data?, _: Bool, _: Bool) -> Content) {
        self.month = month
        self.today = today
        self._selectedIndex = selectedIndex
        self.data = data
        self.calendar = calendar
        self.onTapDay = onTapDay
        self.dayBuilder = day
    }

    /// Private
    private let calendar: Calendar
    private let locale = Locale.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2, alignment: .top), count: 7)

    private let onTapDay: (VGRCalendarIndexKey) -> Void
    private let dayBuilder: (VGRCalendarIndexKey, Data?, _ isCurrent: Bool, _ isSelected: Bool) -> Content


    public var body: some View {
        VStack(spacing: 8) {
            Text(month.idx.date.formatted(.dateTime.year().month()))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.Neutral.text)
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                CalendarWeekHeaderView()

                LazyVGrid(
                    columns: columns,
                    alignment: .leading,

                    spacing: 8,
                    pinnedViews: [.sectionHeaders]
                ) {

                    ForEach(0..<month.leadingPadding, id: \.self) { _ in
                        Spacer()
                    }
                    .accessibilityHidden(true)

                    ForEach(self.month.days, id: \.self) { day in
                        dayBuilder(day,
                                   data[day],
                                   day.hashValue == today.hashValue,
                                   day.hashValue == selectedIndex.hashValue)
                        .id(day.id)
                        .onTapGesture {
                            selectedIndex = day
                            onTapDay(day)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    @Previewable @State var selectedIndex: VGRCalendarIndexKey = VGRCalendarIndexKey(from: Calendar.current.date(2025,5,30))
    @Previewable @State var calendarData: [VGRCalendarIndexKey: ExampleCalendarData] = [
        VGRCalendarIndexKey(year: 2025, month: 5, day: 20) : .init(hasEvent: true, isRecurring: false),
        VGRCalendarIndexKey(year: 2025, month: 5, day: 22) : .init(hasEvent: true, isRecurring: false),
    ]

    let vm: CalendarViewModel = .init(interval: DateInterval(start: Calendar.current.date(2025,5,1),
                                                             end: Calendar.current.date(2025,5,31)))
    let firstMonth = vm.months.first!
    let today = VGRCalendarIndexKey(from: Calendar.current.date(2025,5,15))

    NavigationStack {
        ScrollView {
            VGRCalendarMonthView(month: firstMonth,
                              today: today,
                              selectedIndex: $selectedIndex,
                              data: calendarData) { index in

                print("User tapped day: \(index.id)")

            } day: { index, data, current, selected in
                ExampleDayCell(date: index,
                               data: data,
                               current: current,
                               selected: selected)
            }
        }
        .background(Color.Elevation.background)
        .navigationTitle("Calendar")
    }
}
