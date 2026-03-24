import SwiftUI

struct VGRCalendarWeekViewV2<T: Identifiable & Equatable, DayContent: View>: View {

    /// The calendar used for date calculations
    var calendar: Calendar = .current

    /// Controls which weeks are rendered
    var interval: DateInterval

    /// Contains data for each day, keyed by CalendarIndexKey
    @Binding var data: [VGRCalendarIndexKey: T]

    /// The currently selected date
    @Binding var selectedDate: VGRCalendarIndexKey

    /// Controls the horizontal scroll position (which week is visible)
    @Binding var scrollPosition: ScrollPosition

    /// Custom day view builder, receiving the day key, optional data, and selection state
    @ViewBuilder var dayContent: (VGRCalendarIndexKey, T?, Bool) -> DayContent

    /// One CalendarIndexKey per week start, generated from the interval
    @State private var weeks: [VGRCalendarIndexKey] = []

    /// Measured content height per week, keyed by weekID
    @State private var weekHeights: [String: CGFloat] = [:]

    /// The current frame height of the scroll view, driven by the visible week's measured height
    @State private var contentHeight: CGFloat = 40

    /// Internal property, used to set the initial height of the week without animation
    @State private var hasInitialHeight: Bool = false

    /// Tracks the last visible weekID to determine scroll direction
    @State private var lastVisibleWeekID: String?

    /// Internal property, used to control visibility of week elements for voice over
    @State private var weekVisibility: [String: Bool] = [:]

    /// Internal property, used to control accessibility/voiceover focus of days
    @AccessibilityFocusState private var focusedDayState: String?

    /// Internal property, used to control focus of days
    @FocusState private var focusedDay: VGRCalendarIndexKey?

    var body: some View {
        VStack(spacing: 0) {
            VGRCalendarWeekdaysViewV2(calendar: calendar)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 0) {
                    ForEach(weeks, id: \.weekID) { week in
                        Grid(horizontalSpacing: 2, verticalSpacing: 0) {
                            GridRow(alignment: .top) {
                                ForEach(week.daysInWeek(calendar), id: \.dayID) { day in
                                    dayContent(day, data[day], day == selectedDate)
                                        .id(day.dayID)
                                        .accessibilityFocused($focusedDayState, equals: day.dayID)
                                        .focused($focusedDay, equals: day)
                                        .gridCellUnsizedAxes(.vertical)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .containerRelativeFrame(.horizontal)
                        .onGeometryChange(for: CGFloat.self) { geo in
                            geo.size.height
                        } action: { height in
                            weekHeights[week.weekID] = height
                            if scrollPosition.viewID(type: String.self) == week.weekID {
                                updateHeightForVisibleWeek()
                            }
                        }
                        .onScrollVisibilityChange { visible in
                            /// This is used to hide weeks that are contained in the LazyHStack
                            /// but should not be visible for voiceOver
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                weekVisibility[week.weekID] = visible
                            }
                        }
                        .accessibilityHidden(weekVisibility[week.weekID] == false)
                        .accessibilityAction(named: "calendar.accessibility.previousWeek".localized) {
                            navigateToPreviousWeek(from: week)
                        }
                        .accessibilityAction(named: "calendar.accessibility.nextWeek".localized) {
                            navigateToNextWeek(from: week)
                        }
                        .id(week.weekID)
                    }
                }
                .scrollTargetLayout()
            }
            .frame(height: contentHeight, alignment: .top)
            .scrollTargetBehavior(.paging)
            .scrollPosition($scrollPosition)
            .onScrollPhaseChange { _, newPhase in
                if newPhase == .idle {
                    updateHeightForVisibleWeek()
                    selectDayAfterScroll()
                }
            }
            .onChange(of: scrollPosition) { _, _ in
                updateHeightForVisibleWeek()
            }
        }
        .padding(.bottom, 8)
        .onChange(of: interval, initial: true) {
            weeks = interval.generateWeeks(calendar)
            lastVisibleWeekID = scrollPosition.viewID(type: String.self)
        }
        .onChange(of: data) {
            updateHeightForVisibleWeek()
        }
    }

    private func navigateToPreviousWeek(from week: VGRCalendarIndexKey) {
        let previousWeek = week.previousWeek(calendar)
        guard let lastDay = previousWeek.daysInWeek(calendar).last else { return }

        selectedDate = lastDay
        scrollPosition.scrollTo(id: previousWeek.weekID)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            focusedDayState = lastDay.dayID
            focusedDay = lastDay
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
    }

    private func navigateToNextWeek(from week: VGRCalendarIndexKey) {
        let nextWeek = week.nextWeek(calendar)
        guard let firstDay = nextWeek.daysInWeek(calendar).first else { return }

        selectedDate = firstDay
        scrollPosition.scrollTo(id: nextWeek.weekID)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            focusedDayState = firstDay.dayID
            focusedDay = firstDay
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
    }

    private func selectDayAfterScroll() {
        guard let visibleID = scrollPosition.viewID(type: String.self) else { return }
        defer { lastVisibleWeekID = visibleID }

        guard let previousID = lastVisibleWeekID, previousID != visibleID else { return }

        /// Skip if selectedDate is already in the visible week (e.g. programmatic scroll)
        if selectedDate.weekID == visibleID { return }

        let oldIndex = weeks.firstIndex(where: { $0.weekID == previousID })
        let newIndex = weeks.firstIndex(where: { $0.weekID == visibleID })

        guard let oldIdx = oldIndex, let newIdx = newIndex else { return }

        let week = weeks[newIdx]
        let days = week.daysInWeek(calendar)

        if newIdx > oldIdx {
            if let firstDay = days.first { selectedDate = firstDay }
        } else {
            if let lastDay = days.last { selectedDate = lastDay }
        }
    }

    private func updateHeightForVisibleWeek() {
        guard let visibleID = scrollPosition.viewID(type: String.self),
              let height = weekHeights[visibleID], height > 0 else { return }

        /// If this is a subsequent call, animate the change in height
        if hasInitialHeight {
            withAnimation(.easeInOut(duration: 0.2)) {
                contentHeight = height
            }
        } else {

            /// Iniitla run, just set the height.
            contentHeight = height
            hasInitialHeight = true
        }
    }
}

#Preview {
    @Previewable @State var data: [VGRCalendarIndexKey: ExampleEventData] = [:]
    @Previewable @State var selectedDate = VGRCalendarIndexKey(from: Date())
    @Previewable @State var scrollPosition = ScrollPosition(id: VGRCalendarIndexKey(from: Date()).weekID)

    NavigationStack {
        VStack(spacing: 0) {
            VGRCalendarWeekViewV2(
                interval: DateInterval(
                    start: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                    end: Calendar.current.date(byAdding: .month, value: 3, to: Date())!
                ),
                data: $data,
                selectedDate: $selectedDate,
                scrollPosition: $scrollPosition
            ) { day, entry, selected in
                ExampleDayView(index: day, data: entry, selected: selected)
            }
            .border(.red, width: 1)

            ScrollView {
                Text("Here goes some content...")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)

            }
            .frame(maxHeight: .infinity)
            .border(.blue, width: 1)
        }

        .background(Color.white)
        .navigationTitle("VGRCalendarWeekViewV2")
        .navigationBarTitleDisplayMode(.inline)

    }
}
