import SwiftUI

struct CalendarWeekView<Data, Content>: View where Data: Hashable, Content: View {

    /// Public
    let today: CalendarIndexKey
    let data: [CalendarIndexKey: Data]

    @Binding var selectedIndex: CalendarIndexKey

    public init(selectedIndex: Binding<CalendarIndexKey>,
                today: CalendarIndexKey,
                data: [CalendarIndexKey : Data],
                using calendar: Calendar = Calendar.current,
                day: @escaping (CalendarIndexKey, Data?, _: Bool, _: Bool) -> Content) {
        self.today = today
        self._selectedIndex = selectedIndex
        self.data = data
        self.calendar = calendar
        self.dayBuilder = day

        self.weekInterval = calendar.weekIntervalExact(containing: selectedIndex.wrappedValue.date)
        self.dates = [selectedIndex.wrappedValue]
    }

    /// Private
    private let calendar: Calendar
    private let dayBuilder: (CalendarIndexKey, Data?, _ isCurrent: Bool, _ isSelected: Bool) -> Content
    @State private var weekInterval: DateInterval?
    private let rows = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    @State private var dates: [CalendarIndexKey]
    @State private var animationDirection: Bool = false

    private func getDayCells(_ startDate: CalendarIndexKey) -> [CalendarIndexKey] {
        return startDate.date.datesForCurrentWeek(startingFrom: .monday).map { CalendarIndexKey(from: $0) }
    }

    private var dayCells: [CalendarIndexKey] {
        guard let weekInterval else { return [] }
        let days = calendar.daysBetween(weekInterval.start, endDate: weekInterval.end)
        return days.map { CalendarIndexKey(from: $0) }
    }

    private func previousDate() {
        guard let firstDate = dates.first else { return }
        let newDate = calendar.date(byAdding: .day, value: -7, to: firstDate.date)!

        animationDirection = true

        withAnimation {
            dates.insert(CalendarIndexKey(from: newDate), at: 0)
            dates.removeLast()
        } completion: {

            self.weekInterval = calendar.weekIntervalExact(containing: newDate)
            if let weekInterval {
                selectedIndex = CalendarIndexKey(from: weekInterval.end)
            }

//            UIAccessibility.postPrioritizedAnnouncement(a11yLabel, withPriority: .high)
//            focusedElement = vm.selectedDate.formatted(date: .numeric, time: .omitted)
        }
    }

    private func nextDate() {
        guard let firstDate = dates.first else { return }
        let newDate = calendar.date(byAdding: .day, value: 7, to: firstDate.date)!

        animationDirection = false
        withAnimation {
            dates.append(CalendarIndexKey(from: newDate))
            dates.removeFirst()
        } completion: {

            self.weekInterval = calendar.weekIntervalExact(containing: newDate)
            if let weekInterval {
                self.selectedIndex = CalendarIndexKey(from: weekInterval.start)
            }

//            UIAccessibility.postPrioritizedAnnouncement(a11yLabel, withPriority: .high)
//            focusedElement = vm.selectedDate.formatted(date: .numeric, time: .omitted)
        }
    }

    private func gotoToday() {
        guard let firstDate = dates.first else { return }
//        let todaysDate = Date.now
        let compare = Calendar.current.compare(today.date, to: firstDate.date, toGranularity: .day)
        if compare == .orderedSame { return }

        animationDirection = compare == .orderedAscending

        withAnimation {
            if compare == .orderedAscending {
                dates.insert(today, at: 0)
                dates.removeLast()
            } else {
                dates.append(today)
                dates.removeFirst()
            }

        } completion: {

            self.weekInterval = calendar.weekIntervalExact(containing: today.date)
            self.selectedIndex = today

//            vm.selectedDate = todaysDate
//            initialDate = todaysDate

//            UIAccessibility.postPrioritizedAnnouncement(a11yLabel, withPriority: .high)
//            focusedElement = vm.selectedDate.formatted(date: .numeric, time: .omitted)
        }
    }

    var body: some View {
        VStack {

            CalendarWeekHeaderView()

            HStack {
                ForEach(dates, id: \.self) { date in
                    HStack {
                        ForEach(getDayCells(date), id: \.self) { day in
                            dayBuilder(day,
                                       data[day],
                                       day.hashValue == today.hashValue,
                                       day.hashValue == selectedIndex.hashValue)
                            .id(day.hashValue)
                            .onTapGesture {
                                selectedIndex = day
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)

                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: animationDirection ? .leading : .trailing),
                            removal: .move(edge: animationDirection ? .trailing : .leading)
                        )
                    )
                }
            }
        }
        .onSwipe(minimumDistance: 40, coordinateSpace: .local) { direction in
            if direction == .left {
                nextDate()
            }
            if direction == .right {
                previousDate()
            }
        }
        .navigationTitle(selectedIndex.id)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Idag") {
                    gotoToday()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var weekIndex: CalendarIndexKey = CalendarIndexKey(year: 2025, month: 4, day: 1)
    @Previewable @State var selectedIndex: CalendarIndexKey = CalendarIndexKey(year: 2025, month: 4, day: 10)
    @Previewable @State var calendarData: [CalendarIndexKey: ExampleCalendarData] = [
        CalendarIndexKey(year: 2025, month: 5, day: 20) : .init(hasEvent: true, isRecurring: false),
        CalendarIndexKey(year: 2025, month: 5, day: 22) : .init(hasEvent: true, isRecurring: false),
    ]

    let today = CalendarIndexKey(from: Calendar.current.date(2025,5,15))

    NavigationStack {
        VStack {
            CalendarWeekView(selectedIndex: $selectedIndex,
                             today: today,
                             data: calendarData) { index, data, isCurrent, isSelected in

                ExampleDayCell(date: index,
                               data: data,
                               current: isCurrent,
                               selected: isSelected)

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
        .onChange(of: selectedIndex) {
            /// Used for debugging that CalendarWeekView triggers change in selectedIndex
            print("Changed weekIndex to: \(selectedIndex.id)")
        }
    }
}
