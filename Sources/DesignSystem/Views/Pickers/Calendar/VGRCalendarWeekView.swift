import SwiftUI

public struct VGRCalendarWeekView<Content, Data>: View where Data: Hashable, Content: View {
    
    @Binding var selectedDate: VGRCalendarIndexKey
    @Binding var currentWeekID: String?
    
    @State private var vm: VGRCalendarViewModel
    @State private var currentHeight: CGFloat = .zero
    @State private var today: VGRCalendarIndexKey = VGRCalendarIndexKey(from: .now)
    @FocusState private var focusedDay: VGRCalendarIndexKey?
    @AccessibilityFocusState private var a11yFocusedDay: String?

    private let data: [VGRCalendarIndexKey: Data]
    private let interval: DateInterval
    private let heightRetrieval: (Data?) -> CGFloat
    private let dayBuilder: (VGRCalendarIndexKey, Data?, _ isCurrent: Bool, _ isSelected: Bool) -> Content
    private let insets: EdgeInsets
    private let calendar: Calendar

    @State private var weekVisibility: [String: Bool] = [:]

    public init(
        currentWeekID: Binding<String?>,
        interval: DateInterval,
        data: [VGRCalendarIndexKey: Data],
        using calendar: Calendar = .current,
        selectedDate: Binding<VGRCalendarIndexKey>,
        insets: EdgeInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16),
        heightRetrieval: @escaping (Data?) -> CGFloat,
        dayBuilder: @escaping (VGRCalendarIndexKey, Data?, _: Bool, _: Bool) -> Content
    ) {
        self._currentWeekID = currentWeekID
        self.vm = .init(interval: interval, calendar: calendar)
        self.interval = interval
        self.calendar = calendar
        self.data = data
        self._selectedDate = selectedDate
        self.dayBuilder = dayBuilder
        self.insets = insets
        self.heightRetrieval = heightRetrieval
        self.height = self.heightRetrieval(nil)
    }
    
    public var body: some View {
        VStack {
            VGRCalendarWeekHeaderView()
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
                                .accessibilityIdentifier(idx.id)
                                .focused($focusedDay, equals: idx)
                                .accessibilityFocused($a11yFocusedDay, equals: idx.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedDate = idx
                                }
                            }
                        }
                        .onScrollVisibilityChange { visible in
                            /// This is used to hide weeks that are contained in the LazyHStack
                            /// but should not be visible for voiceOver
                            weekVisibility[week.idx.weekID] = visible
                        }
                        .id(week.idx.weekID)
                        .frame(height: maxHeight(for: week), alignment: .top)
                        .padding(.leading, insets.leading)
                        .padding(.trailing, insets.trailing)
                        .containerRelativeFrame([.horizontal], alignment: .top)
                        .accessibilityElement(children: .contain)
                        .accessibilityHidden(weekVisibility[week.idx.weekID] == false)
                    }
                    .accessibilityAction(named: "calendar.week.next".localizedBundle, {
                        if let nextPeriod = vm.getPeriodAfterWeekID(currentWeekID) {
                            let oldWeek = currentWeekID
                            let newWeek = nextPeriod.idx.weekID

                            currentWeekID = newWeek
                            selectDay(old: oldWeek, new: newWeek)
                        }
                    })
                    .accessibilityAction(named: "calendar.week.previous".localizedBundle, {
                        if let previousPeriod = vm.getPeriodBeforeWeekID(currentWeekID) {
                            let oldWeek = currentWeekID
                            let newWeek = previousPeriod.idx.weekID

                            currentWeekID = newWeek
                            selectDay(old: oldWeek, new: newWeek)
                        }
                    })
                }
                .frame(height: height, alignment: .top)
                .scrollTargetLayout()
            }
            .scrollPosition(id: $currentWeekID)
            .scrollTargetBehavior(.paging)
            .onDayChange {
                today = VGRCalendarIndexKey(from: .now)
            }
            .onAppear {
                let period = vm.periodForWeekID(currentWeekID)
                height = maxHeight(for: period)
                
                currentWeekID = selectedDate.weekID
            }
            .onChange(of: selectedDate) {
                focusedDay = selectedDate
            }
            .onChange(of: currentWeekID) { oldWeek, newWeek in
                withAnimation(.easeInOut) {
                    let period = vm.periodForWeekID(newWeek)
                    height = maxHeight(for: period)
                }
                
                if oldWeek != today.weekID && selectedDate == today { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    selectDay(old: oldWeek, new: newWeek)
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
        a11yFocusedDay = selectedDate.id
    }
    
    @State private var height: CGFloat

    /// Method is used to retrieve the height of the week element
    private func maxHeight(for period: VGRCalendarPeriodModel?) -> CGFloat {
        /// Check if heightRetrieval is implemented
        guard let period else {
            return self.heightRetrieval(nil)
        }

        /// Get height for all days in the full period, pick the largest value
        return period.days.map { data[$0] }.map(heightRetrieval).max() ?? 0
    }
}


#Preview {
    @Previewable @State var currentWeekID: String? = nil
    @Previewable @State var selectedDate: VGRCalendarIndexKey = VGRCalendarIndexKey(from: .now)
    @Previewable @State var calendarData: [VGRCalendarIndexKey: ExampleCalendarData] = [
        VGRCalendarIndexKey(year: 2025, month: 5, day: 20) : .init(hasEvent: true, isRecurring: false),
        VGRCalendarIndexKey(year: 2025, month: 5, day: 22) : .init(hasEvent: true, isRecurring: false),
        VGRCalendarIndexKey(year: 2025, month: 5, day: 27) : .init(hasEvent: true, isRecurring: false),
        VGRCalendarIndexKey(year: 2025, month: 5, day: 30) : .init(hasEvent: true, isRecurring: false),
    ]
    
    let today: VGRCalendarIndexKey = VGRCalendarIndexKey(from: .now)
    
    /// The total maximal range for the Calendar. Can be set arbitrarily.
    let maxInterval: DateInterval = Calendar.current.dateInterval(
        from: .now,
        count: 2,
        component: .year
    )!
    
    NavigationStack {
        
        VStack {
            VGRCalendarWeekView(currentWeekID: $currentWeekID,
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
        .background(Color.Elevation.elevation1)
        
        ScrollView {
            if let data = calendarData[selectedDate] {
                VStack(spacing: 8) {
                    ForEach(data.items) { item in
                        HStack {
                            VStack {
                                Text(item.title)
                                    .font(.body).fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(item.description)
                                    .font(.footnote).fontWeight(.regular)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                    }
                }
            } else {
                Text("No events on this particular day")
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.Elevation.background)
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation {
                        selectedDate = today
                        currentWeekID = today.weekID
                    }
                } label: {
                    Text("Idag")
                }
            }
        }
        .navigationTitle("CalendarWeekView")
        .navigationBarTitleDisplayMode(.inline)
    }
}
