import Foundation
import SwiftUI

struct CalendarMonthView<Data, Content>: View where Data: Hashable, Content: View {

    /// Public
    let month: CalendarIndexKey
    let today: CalendarIndexKey
    @Binding var selectedIndex: CalendarIndexKey
    let data: [CalendarIndexKey: Data]

    public init(month: CalendarIndexKey,
                today: CalendarIndexKey,
                selectedIndex: Binding<CalendarIndexKey>,
                data: [CalendarIndexKey: Data] = [:],
                onTapDay: @escaping (CalendarIndexKey) -> Void = { _ in },
                @ViewBuilder day: @escaping (CalendarIndexKey, Data?, _: Bool, _: Bool) -> Content) {
        self.month = month
        self.today = today
        self._selectedIndex = selectedIndex
        self.data = data
        self.onTapDay = onTapDay
        self.dayBuilder = day
    }

    /// Private
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

    private var dayCells: [CalendarIndexKey] {
        let nonNilDates = days.compactMap { $0 }
        let calendarKeys = nonNilDates.map { CalendarIndexKey(from: $0) }
        return calendarKeys
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(month.date.formatted(.dateTime.year().month()))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.Neutral.text)
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                CalendarWeekHeaderView()

                LazyVGrid(columns: columns, spacing: 8, pinnedViews: [.sectionHeaders]) {

                    ForEach(0..<numPaddingCellsAtBeginning, id: \.self) { _ in
                        Spacer()
                    }
                    .accessibilityHidden(true)

                    ForEach(dayCells, id: \.self) { day in
                        dayBuilder(day,
                                   data[day],
                                   day.hashValue == today.hashValue,
                                   day.hashValue == selectedIndex.hashValue)
                        .id(day.hashValue)
                        .onTapGesture {
                            selectedIndex = day
                            onTapDay(day)
                        }
                    }
                }
            }
        }
        .onAppear {
            print("Appear: \(month.date.year)-\(month.date.month)")
            days = generateCalendarGrid(for: month.date)
        }
        .onDisappear {
            print("Disappear: \(month.date.year)-\(month.date.month)")
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


#Preview {
    @Previewable @State var selectedDate: Date = Calendar.current.date(2025,5,30)
    @Previewable @State var selectedIndex: CalendarIndexKey = CalendarIndexKey(from: Calendar.current.date(2025,5,30))

    @Previewable @State var calendarData: [CalendarIndexKey: ExampleCalendarData] = [
        CalendarIndexKey(year: 2025, month: 5, day: 20) : .init(hasEvent: true, isRecurring: false),
        CalendarIndexKey(year: 2025, month: 5, day: 22) : .init(hasEvent: true, isRecurring: false),
    ]

    let month: CalendarIndexKey = CalendarIndexKey(from: Calendar.current.date(2025,5,1))

    let today = CalendarIndexKey(from: Calendar.current.date(2025,5,15))

    NavigationStack {
        ScrollView {
            CalendarMonthView(month: month,
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
