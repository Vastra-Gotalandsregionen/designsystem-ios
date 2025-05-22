import Foundation
import SwiftUI

struct NewCalendarView<Data, Content>: View where Data: Hashable, Content: View {

    /* Public */
    let currentDate: Date
    @Binding var currentIndex: CalendarIndexKey
    let data: [CalendarIndexKey: Data]

    public init(currentDate: Date,
                currentIndex: Binding<CalendarIndexKey>,
                data: [CalendarIndexKey: Data] = [:],
                onTapDay: @escaping (CalendarIndexKey) -> Void = { _ in },
                @ViewBuilder day: @escaping (CalendarIndexKey, Data?, _: Bool, _: Bool) -> Content) {
        self.currentDate = currentDate
        self._currentIndex = currentIndex
        self.data = data
        self.onTapDay = onTapDay
        self.dayBuilder = day
    }


    /* Private */
    private let today = CalendarIndexKey(from: .now)
    private let calendar = Calendar.current
    private let locale = Locale.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    private let onTapDay: (CalendarIndexKey) -> Void
    private let dayBuilder: (CalendarIndexKey, Data?, _ isCurrent: Bool, _ isSelected: Bool) -> Content

    @State private var days: [Date?] = []

    private var numPaddingCellsAtBeginning: Int {
        let nilCountAtBeginning = days.prefix { $0 == nil }.count
        return nilCountAtBeginning
    }

    private var dateCells: [CalendarIndexKey] {
        let nonNilDates = days.compactMap { $0 }
        let calendarKeys = nonNilDates.map { CalendarIndexKey(from: $0) }
        return calendarKeys
    }

    private func renderDays() -> [Date?] { generateCalendarGrid(for: currentDate) }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8, pinnedViews: [.sectionHeaders]) {
            Section {
                    ForEach(0..<numPaddingCellsAtBeginning, id: \.self) { _ in
                        Spacer()
                    }
                    .accessibilityHidden(true)

                    ForEach(dateCells, id: \.self) { day in
                        dayBuilder(day,
                                   data[day],
                                   day.hashValue == today.hashValue,
                                   day.hashValue == currentIndex.hashValue)
                            .id(day.hashValue)
                            .onTapGesture {
                                currentIndex = day
                                onTapDay(day)
                            }
                    }

            } header: {

                VStack(spacing: 16) {
                    Text(currentDate.formatted(.dateTime.year().month()))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.Neutral.text)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    weekdayHeader
                }
                .padding(.top, 12)
                .background(Color.Elevation.background)
            }
        }
        .padding(.horizontal, 12)
        .background(Color.Elevation.background)
        .onAppear {
            days = renderDays()
        }
    }

    private var weekdayHeader: some View {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1 /// calendar is 1-indexed
        let orderedWeekdays = Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])

        return HStack(spacing: 2) {
            ForEach(orderedWeekdays, id: \.self) { day in
                Text(day)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
        }
    }

    // MARK: - Calendar Grid Logic

    private func generateCalendarGrid(for date: Date) -> [Date?] {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        let numberOfDays = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        let startWeekday = calendar.component(.weekday, from: firstDay)
        let firstWeekday = calendar.firstWeekday
        let leadingEmpty = (startWeekday - firstWeekday + 7) % 7

        var grid: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                grid.append(calendar.startOfDay(for: date))
            }
        }

        return grid
    }
}

struct MyCalendarData: Hashable {
    let hasEvent: Bool
    let isRecurring: Bool
}

#Preview {
    @Previewable @State var selectedDate: Date = Calendar.current.date(2025,5,30)
    @Previewable @State var selectedIndex: CalendarIndexKey = CalendarIndexKey(from: Calendar.current.date(2025,5,30))
    @Previewable @State var calendarData: [CalendarIndexKey: MyCalendarData] = [
        CalendarIndexKey(year: 2025, month: 5, day: 20) : .init(hasEvent: true, isRecurring: false),
        CalendarIndexKey(year: 2025, month: 5, day: 22) : .init(hasEvent: true, isRecurring: false),
    ]

    let dates: [Date] = [
        Calendar.current.date(2025,5,1),
        Calendar.current.date(2025,6,1),
        Calendar.current.date(2025,7,1),
        Calendar.current.date(2025,8,1),
        Calendar.current.date(2025,9,1),
        Calendar.current.date(2025,10,1),
        Calendar.current.date(2025,11,1),
    ]

    let calendar = Calendar.current

    NavigationStack {
        ScrollView {
            LazyVStack {
                ForEach(dates, id: \.self) { date in
                    NewCalendarView(currentDate: date,
                                    currentIndex: $selectedIndex,
                                    data: calendarData) { index in

                        print("User tapped day: \(index.id)")
                        
                    } day: { index, data, current, selected in
                        NewDayCell(date: index, data: data, current: current, selected: selected)
                    }
                    .onAppear {
                        print("Appear: \(date.year)-\(date.month)")
                    }
                    .onDisappear {
                        print("Disappear: \(date.year)-\(date.month)")
                    }
                    .id("\(date.year)-\(date.month)")
                }
            }
        }
        .background(Color.Elevation.background)
        .navigationTitle("Calendar")
    }
}
