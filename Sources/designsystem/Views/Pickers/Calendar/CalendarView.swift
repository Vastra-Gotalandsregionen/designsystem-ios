import SwiftUI

struct CalendarView<Data, Content>: View where Data: Hashable, Content: View {

    /// Public
    @Binding var selectedIndex: CalendarIndexKey
    let interval: DateInterval
    let data: [CalendarIndexKey: Data]

    public init(
        selectedIndex: Binding<CalendarIndexKey>,
        interval: DateInterval,
        data: [CalendarIndexKey : Data],
        onTapDay: @escaping (CalendarIndexKey) -> Void,
        day: @escaping (CalendarIndexKey, Data?, _: Bool, _: Bool) -> Content
    ) {
        self._selectedIndex = selectedIndex
        self.interval = interval
        self.data = data

        self.onTapDay = onTapDay
        self.dayBuilder = day

        self.dates = self.interval.monthsIncluded().map { CalendarIndexKey(from: $0) }
    }

    /// Private
    private let dates: [CalendarIndexKey]
    private let onTapDay: (CalendarIndexKey) -> Void
    private let dayBuilder: (CalendarIndexKey, Data?, _ isCurrent: Bool, _ isSelected: Bool) -> Content

    @State private var today: CalendarIndexKey = CalendarIndexKey(from: .now)
    @State private var scrollProxy: ScrollViewProxy? = nil

    private func scrollToSelectedIndex(using proxy: ScrollViewProxy? = nil) {
        guard let proxy else { return }

        ///Scroll to target
        let targetMonth = "\(selectedIndex.year)-\(selectedIndex.month)"
        print("Scrolling")
        DispatchQueue.main.async {
            proxy.scrollTo(targetMonth, anchor: .top)
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 32) {
                    ForEach(dates, id: \.self) { month in
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
            }
            .background(Color.Elevation.background)
            .defaultScrollAnchor(.top)
            .onDayChange { today = CalendarIndexKey(from: .now) }
            .onAppear {
                scrollProxy = proxy
                scrollToSelectedIndex(using: proxy)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Idag") {
                        selectedIndex = CalendarIndexKey(from: .now)
                        scrollToSelectedIndex(using: proxy)
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

    let maxInterval: DateInterval = Calendar.current.dateInterval(
        from: .now,
        count: 6,
        component: .month
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
        .navigationDestination(item: $selectedWeekIndex) { val in
            CalendarWeekView(selectedIndex: $selectedIndex)
        }
    }
}
