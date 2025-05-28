import SwiftUI

public struct CalendarView<Data, Content>: View where Data: Hashable, Content: View {

    /// Public
    @Binding var selectedIndex: CalendarIndexKey
    let interval: DateInterval
    let data: [CalendarIndexKey: Data]

    public init(selectedIndex: Binding<CalendarIndexKey>,
                interval: DateInterval,
                data: [CalendarIndexKey : Data],
                calendar: Calendar = .current,
                onTapDay: @escaping (CalendarIndexKey) -> Void,
                day: @escaping (CalendarIndexKey, Data?, _: Bool, _: Bool) -> Content) {

        self.vm = .init(interval: interval, calendar: calendar)
        self._selectedIndex = selectedIndex
        self.interval = interval
        self.data = data

        self.onTapDay = onTapDay
        self.dayBuilder = day
        self.currentMonthTarget = selectedIndex.wrappedValue.monthID
    }

    /// Private
    @State private var vm: CalendarViewModel
    private let onTapDay: (CalendarIndexKey) -> Void
    private let dayBuilder: (CalendarIndexKey, Data?, _ isCurrent: Bool, _ isSelected: Bool) -> Content

    @State private var today: CalendarIndexKey = CalendarIndexKey(from: .now)
    @State private var currentMonthTarget: String? = nil

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(vm.months, id: \.id) { month in
                    CalendarMonthView(month: month,
                                      today: today,
                                      selectedIndex: $selectedIndex,
                                      data: data,
                                      onTapDay: onTapDay,
                                      day: dayBuilder)
                    .id(month.idx.monthID)
                    .padding(.horizontal, 12)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $currentMonthTarget, anchor: .top)
        .background(Color.Elevation.background)
        .onDayChange { today = CalendarIndexKey(from: .now) }
        .onAppear {
            DispatchQueue.main.async {
                print("onAppear: Setting monthTarget to \(selectedIndex.monthID) (\(currentMonthTarget ?? "n/a"))")
                currentMonthTarget = nil
                currentMonthTarget = selectedIndex.monthID
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Idag") {
                    DispatchQueue.main.async {
                        currentMonthTarget = nil
                        selectedIndex = today
                        currentMonthTarget = selectedIndex.monthID
                        print("today: Setting monthTarget to \(selectedIndex.monthID) (\(currentMonthTarget ?? "n/a"))")
                    }
                }
            }
        }
    }
}

#Preview {
    /// selectedIndex contains the currently selected date using the CalendarIndexKey
    @Previewable @State var selectedIndex: CalendarIndexKey = CalendarIndexKey(from: .now)

    /// selectedWeekIndex is only used to trigger / push the weekView onto the NavStack
    @Previewable @State var selectedWeekIndex: CalendarIndexKey? = nil

    /// This is an example of what the data that can be passed to the CalendarView can look like.
    /// ExampleCalendarData is your own data structure that you pass and that you use to populate
    /// the DayCells (in this example called _ExampleDayCell_).
    @Previewable @State var calendarData: [CalendarIndexKey: ExampleCalendarData] = [
        CalendarIndexKey(year: 2025, month: 5, day: 20) : .init(hasEvent: true, isRecurring: false),
        CalendarIndexKey(year: 2025, month: 5, day: 22) : .init(hasEvent: true, isRecurring: false),
    ]

    @Previewable @State var currentWeekID: String? = nil

    let today = CalendarIndexKey(from: .now)

    /// The total maximal range for the Calendar. Can be set arbitrarily.
    let maxInterval: DateInterval = Calendar.current.dateInterval(
        from: .now,
        count: 2,
        component: .year
    )!

    NavigationStack {
        CalendarView(selectedIndex: $selectedIndex,
                     interval: maxInterval,
                     data: calendarData) { index in

            print("Tapped on \(index.id)")
            currentWeekID = index.weekID
            selectedWeekIndex = index


        } day: { index, data, current, selected in
            ExampleDayCell(date: index,
                           data: data,
                           current: current,
                           selected: false)
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Add", systemImage: "plus.circle") {
                    let timeRange = maxInterval.end.timeIntervalSince(maxInterval.start)
                    let randomOffset = TimeInterval.random(in: 0...timeRange)
                    let date = CalendarIndexKey(from: maxInterval.start.addingTimeInterval(randomOffset))
                    withAnimation {
                        calendarData[date] = .init(hasEvent: true, isRecurring: false)
                    }
                }
            }
        }
        .navigationDestination(item: $selectedWeekIndex) { weekIndex in
            VStack {
                CalendarWeekView(
                    currentWeekID: $currentWeekID,
                    today: today,
                    interval: maxInterval,
                    data: calendarData,
                    selectedDate: $selectedIndex) { data in
                        /// Default height of a day cell
                        guard let data else { return 42.0 }

                        /// Calculate height of a day cell
                        return 44.0 + (CGFloat(data.numItems) * 20.0) + (CGFloat(data.numItems-1) * 2.0)

                    } dayBuilder: { index, data, current, selected in
                        ExampleDayCell(date: index,
                                       data: data,
                                       current: current,
                                       selected: selected)
                    }
                    .background(Color.Elevation.elevation1)

                ScrollView {
                    VStack {
                        if let data = calendarData[selectedIndex] {
                            VStack {
                                ForEach(data.items, id: \.self) { item in
                                    Text(item.title)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("No data for selected date")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.Elevation.background)
            }
            .navigationTitle("Week")
            .toolbar {
                ToolbarItem {
                    Button {
                        withAnimation {
                            selectedIndex = today
                            currentWeekID = today.weekID
                        }
                    } label: {
                        Text("Idag")
                    }
                }
            }
        }
    }
}
