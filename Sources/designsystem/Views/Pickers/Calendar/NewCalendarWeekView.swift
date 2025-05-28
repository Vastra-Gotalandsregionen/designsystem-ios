import SwiftUI

struct NewCalendarWeekView<Content, Data>: View where Data: Hashable, Content: View {

    @Binding var selectedDate: CalendarIndexKey
    @Binding var currentWeekID: String?
    @State private var vm: CalendarViewModel
    @State private var currentHeight: CGFloat = .zero

    let today: CalendarIndexKey
    let data: [CalendarIndexKey: Data]
    let interval: DateInterval
    let heightRetrieval: (Data?) -> CGFloat
    let dayBuilder: (CalendarIndexKey, Data?, _ isCurrent: Bool, _ isSelected: Bool) -> Content

    public init(
        currentWeekID: Binding<String?>,
        today: CalendarIndexKey,
        interval: DateInterval,
        data: [CalendarIndexKey: Data],
        using calendar: Calendar = .current,
        selectedDate: Binding<CalendarIndexKey>,
        insets: EdgeInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16),
        heightRetrieval: @escaping (Data?) -> CGFloat,
        dayBuilder: @escaping (CalendarIndexKey, Data?, _: Bool, _: Bool) -> Content
    ) {
        self._currentWeekID = currentWeekID
        self.vm = .init(interval: interval, calendar: calendar)
        self.interval = interval
        self.calendar = calendar
        self.data = data
        self.today = today
        self._selectedDate = selectedDate
        self.dayBuilder = dayBuilder
        self.insets = insets
        self.heightRetrieval = heightRetrieval
        self.height = self.heightRetrieval(nil)
    }

    private let insets: EdgeInsets
    private let calendar: Calendar
    private let daysPerWeek = 7

    var body: some View {
        VStack {
            CalendarWeekHeaderView()
                .padding(.leading, insets.leading)
                .padding(.trailing, insets.trailing)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 0) {
                    ForEach(vm.weeks, id: \.self) { week in
                        HStack(alignment: .top, spacing: 2) {
                            ForEach(week.days, id: \.self) { idx in
                                dayBuilder(
                                    idx,
                                    data[idx],
                                    idx == today,
                                    idx == selectedDate
                                )
                                .id(idx.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedDate = idx
                                }
                            }
                        }
                        .id(week.idx.weekID)
                        .frame(height: maxHeight(for: week), alignment: .top)
                        .padding(.leading, insets.leading)
                        .padding(.trailing, insets.trailing)
                        .containerRelativeFrame([.horizontal], alignment: .top)
                        .accessibilityElement(children: .contain)
                    }
                }
                .frame(height: height, alignment: .top)
                .scrollTargetLayout()
            }
            .scrollPosition(id: $currentWeekID)
            .scrollTargetBehavior(.paging)
            .onAppear {

                let period = vm.periodForWeekID(currentWeekID)
                height = maxHeight(for: period)

                currentWeekID = selectedDate.weekID
            }
            .onChange(of: currentWeekID) { o, n in
                withAnimation(.easeInOut) {
                    let period = vm.periodForWeekID(n)
                    height = maxHeight(for: period)
                }

                if o != today.weekID && selectedDate == today { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectDay(old: o, new: n)
                }
            }
        }
    }

    private func selectDay(old: String?, new: String?) {
        guard let new else { return }
        guard let old else { return }

        guard let newPeriod = vm.periodForWeekID(new) else { return }
        guard let oldPeriod = vm.periodForWeekID(old) else { return }

        let days = newPeriod.days
        selectedDate = oldPeriod.idx.date > newPeriod.idx.date ? days.last! : days.first!
    }

    @State private var height: CGFloat

    private func maxHeight(for period: CalendarPeriodModel?) -> CGFloat {
        guard let period else {
            return self.heightRetrieval(nil)
        }
        return period.days.map { data[$0] }.map(heightRetrieval).max() ?? 0
    }
}


#Preview {
    @Previewable @State var currentWeekID: String? = nil
    @Previewable @State var selectedDate: CalendarIndexKey = CalendarIndexKey(from: .now)
    @Previewable @State var calendarData: [CalendarIndexKey: ExampleCalendarData] = [
        CalendarIndexKey(year: 2025, month: 5, day: 20) : .init(hasEvent: true, isRecurring: false),
        CalendarIndexKey(year: 2025, month: 5, day: 22) : .init(hasEvent: true, isRecurring: false),
        CalendarIndexKey(year: 2025, month: 5, day: 27) : .init(hasEvent: true, isRecurring: false),
        CalendarIndexKey(year: 2025, month: 5, day: 30) : .init(hasEvent: true, isRecurring: false),
    ]

    let today: CalendarIndexKey = CalendarIndexKey(from: .now)

    /// The total maximal range for the Calendar. Can be set arbitrarily.
    let maxInterval: DateInterval = Calendar.current.dateInterval(
        from: .now,
        count: 2,
        component: .year
    )!

    NavigationStack {

        VStack {
            NewCalendarWeekView(currentWeekID: $currentWeekID,
                                today: today,
                                interval: maxInterval,
                                data: calendarData,
                                selectedDate: $selectedDate,
                                heightRetrieval: { data in
                /// Default height of a day cell
                guard let data else { return 42.0 }

                /// Calculate height of a day cell
                return 44.0 + (CGFloat(data.numItems) * 20.0) + (CGFloat(data.numItems-1) * 2.0)

            }) { index, data, isCurrent, isSelected in

                ExampleDayCell(date: index, data: data, current: isCurrent, selected: isSelected)
                    .accessibilityHint("Double-tap to select this date")
                    .accessibilityAddTraits(.isButton)
            }
        }

        ScrollView {
            VStack {
                Text("Valt datum")
                Text(selectedDate.id)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.yellow.opacity(0.5))
        }
        .toolbar {
            ToolbarItem {
                Button {
                    selectedDate = today
                    currentWeekID = today.weekID
                } label: {
                    Text("Idag")
                }
            }
        }
        .navigationTitle("PagedWeekView")
        .navigationBarTitleDisplayMode(.inline)
    }
}
