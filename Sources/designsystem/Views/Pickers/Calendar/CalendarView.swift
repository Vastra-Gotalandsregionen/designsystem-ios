import SwiftUI

struct CalendarView<Data, Content>: View where Data: Hashable, Content: View {

    /// Public
    @Binding var selectedIndex: CalendarIndexKey
    let interval: DateInterval
    let data: [CalendarIndexKey: Data]

    public init(selectedIndex: Binding<CalendarIndexKey>,
                interval: DateInterval,
                data: [CalendarIndexKey : Data],
                onTapDay: @escaping (CalendarIndexKey) -> Void,
                day: @escaping (CalendarIndexKey, Data?, _: Bool, _: Bool) -> Content) {

        self._selectedIndex = selectedIndex
        self.interval = interval
        self.data = data

        self.onTapDay = onTapDay
        self.dayBuilder = day

        self.months = self.interval.monthsIncluded().map { CalendarIndexKey(from: $0) }
        self.currentMonthTarget = selectedIndex.wrappedValue.monthID
    }

    /// Private
    private let months: [CalendarIndexKey]
    private let onTapDay: (CalendarIndexKey) -> Void
    private let dayBuilder: (CalendarIndexKey, Data?, _ isCurrent: Bool, _ isSelected: Bool) -> Content

    @State private var today: CalendarIndexKey = CalendarIndexKey(from: .now)
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var currentMonthTarget: String? = nil

    private func scrollToSelectedIndex(using proxy: ScrollViewProxy? = nil, force: Bool = false) {
        guard let proxy else { return }

        ///Scroll to target
        let targetMonth = "\(selectedIndex.year)-\(selectedIndex.month)"

        /// Prevent unneccessary scrolling
//        if !force {
//            if let currentMonthTarget = currentMonthTarget, currentMonthTarget == targetMonth {
//                print("Debounce (\(currentMonthTarget)) == \(targetMonth))")
//                return
//            }
//        }

        currentMonthTarget = targetMonth

        print("Scrolling")
        DispatchQueue.main.async {
            proxy.scrollTo(targetMonth, anchor: .top)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(months, id: \.self) { month in
                    CalendarMonthView(month: month,
                                      today: today,
                                      selectedIndex: $selectedIndex,
                                      data: data,
                                      onTapDay: onTapDay,
                                      day: dayBuilder)
                    .padding(.horizontal, 12)
                    .id("\(month.year)-\(month.month)")

                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $currentMonthTarget, anchor: .top)
        .background(Color.Elevation.background)
        .onDayChange { today = CalendarIndexKey(from: .now) }
        .onAppear {
            currentMonthTarget = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("Setting monthTarget to \(selectedIndex.monthID) (\(currentMonthTarget ?? "n/a"))")
                currentMonthTarget = selectedIndex.monthID
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Idag") {
                    DispatchQueue.main.async {
                        selectedIndex = today
                        currentMonthTarget = selectedIndex.monthID
                        print("Setting monthTarget to \(selectedIndex.monthID) (\(currentMonthTarget ?? "n/a"))")
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedIndex: CalendarIndexKey = CalendarIndexKey(from: .now)
    @Previewable @State var selectedWeekIndex: CalendarIndexKey? = nil
    @Previewable @State var calendarData: [CalendarIndexKey: ExampleCalendarData] = [
        CalendarIndexKey(year: 2025, month: 5, day: 20) : .init(hasEvent: true, isRecurring: false),
        CalendarIndexKey(year: 2025, month: 5, day: 22) : .init(hasEvent: true, isRecurring: false),
    ]

    let today = CalendarIndexKey(from: .now)

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
                CalendarWeekView(selectedIndex: $selectedIndex,
                                 today: today,
                                 data: calendarData) { index, data, current, selected in
                    ExampleDayCell(date: index,
                                   data: data,
                                   current: current,
                                   selected: selected)
                }.padding(.horizontal, 12)

                ScrollView {
                    if let data = calendarData[selectedIndex] {
                        VStack {
                            ForEach(data.items, id: \.self) { item in
                                Text(item.title)
                            }
                        }
                    } else {
                        Text("No data for selected date")
                    }
                }
            }
        }
    }
}
