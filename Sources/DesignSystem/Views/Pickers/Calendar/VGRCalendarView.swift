import SwiftUI
import SwiftUIIntrospect

/// A scrollable calendar view that displays multiple months in a vertical layout.
///
/// `VGRCalendarView` provides a month-by-month calendar interface with customizable day cells,
/// data binding, and accessibility support. The view automatically handles scrolling to the
/// selected date and provides a "Today" button for quick navigation.
///
/// - Parameters:
///   - Data: A `Hashable` type representing custom data associated with each calendar day
///   - Content: The `View` type used to render individual day cells
///
/// ## Example Usage
/// ```swift
/// VGRCalendarView(
///     selectedIndex: $selectedDate,
///     interval: dateInterval,
///     data: calendarData,
///     onTapDay: { index in
///         print("Tapped: \(index.date)")
///     },
///     dataAccessibilityLabel: { month in
///         "\(month.idx.date.formatted(.dateTime.month().year()))"
///     }
/// ) { index, data, isCurrent, isSelected in
///     CustomDayCell(index: index, data: data)
/// }
/// ```
public struct VGRCalendarView<Data, Content>: View where Data: Hashable, Content: View {

    // MARK: - Public Properties

    /// Binding to the currently selected calendar date index.
    /// Updates when the user taps a day or when programmatically changed.
    @Binding var selectedIndex: VGRCalendarIndexKey

    /// The date interval that defines the range of dates to display in the calendar.
    /// All months within this interval will be rendered.
    let interval: DateInterval

    /// A dictionary mapping calendar index keys to custom data.
    /// Use this to associate events, appointments, or other information with specific dates.
    let data: [VGRCalendarIndexKey: Data]

    /// Controls whether the scroll view scrolls to top when the status bar is tapped.
    /// Defaults to `false`.
    var scrollsToTop: Bool = false

    // MARK: - Private Properties

    /// View model managing the calendar's month data and layout calculations.
    @State private var vm: VGRCalendarViewModel

    /// Optional closure that generates accessibility labels for month headers.
    /// - Parameter month: The `VGRCalendarPeriodModel` representing the month
    /// - Returns: A custom accessibility label string for the month header
    private let dataAccessibilityLabel: ((VGRCalendarPeriodModel) -> String)?

    /// Closure invoked when a user taps a day in the calendar.
    /// - Parameter index: The `VGRCalendarIndexKey` representing the tapped day
    private let onTapDay: (VGRCalendarIndexKey) -> Void

    /// View builder closure that creates the visual representation of each day cell.
    /// - Parameters:
    ///   - index: The calendar index key for the day
    ///   - data: Optional custom data associated with the day
    ///   - isCurrent: Whether this day represents today's date
    ///   - isSelected: Whether this day is currently selected
    /// - Returns: A `View` representing the day cell
    private let dayBuilder: (VGRCalendarIndexKey, Data?, _ isCurrent: Bool, _ isSelected: Bool) -> Content

    /// Tracks today's date and updates at midnight via `onDayChange` modifier.
    @State private var today: VGRCalendarIndexKey = VGRCalendarIndexKey(from: .now)

    /// Scroll position target for programmatic scrolling to specific months.
    /// Uses the month ID to identify which month to scroll to.
    @State private var currentMonthTarget: String? = nil

    /// Tracks which month currently has VoiceOver focus.
    @AccessibilityFocusState private var focusedMonthID: String?

    // MARK: - Initialization

    /// Creates a new calendar view with the specified configuration.
    ///
    /// - Parameters:
    ///   - selectedIndex: Binding to the currently selected date
    ///   - interval: Date range to display in the calendar
    ///   - data: Dictionary of custom data keyed by calendar index
    ///   - calendar: The calendar system to use (defaults to `.current`)
    ///   - scrollsToTop: Whether to enable scroll-to-top on status bar tap (defaults to `false`)
    ///   - onTapDay: Closure called when a day is tapped
    ///   - dataAccessibilityLabel: Optional closure to generate custom accessibility labels for month headers
    ///   - day: View builder that creates the UI for each day cell
    public init(selectedIndex: Binding<VGRCalendarIndexKey>,
                interval: DateInterval,
                data: [VGRCalendarIndexKey : Data],
                calendar: Calendar = .current,
                scrollsToTop: Bool = false,
                onTapDay: @escaping (VGRCalendarIndexKey) -> Void,
                dataAccessibilityLabel: ((VGRCalendarPeriodModel) -> String)? = nil,
                day: @escaping (VGRCalendarIndexKey, Data?, _: Bool, _: Bool) -> Content) {

        self.vm = .init(interval: interval, calendar: calendar)
        self._selectedIndex = selectedIndex
        self.interval = interval
        self.data = data

        self.dataAccessibilityLabel = dataAccessibilityLabel
        self.onTapDay = onTapDay
        self.dayBuilder = day
        self.currentMonthTarget = selectedIndex.wrappedValue.monthID
        self.scrollsToTop = scrollsToTop
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(vm.months, id: \.id) { month in
                    VGRCalendarMonthView(month: month,
                                         today: today,
                                         selectedIndex: $selectedIndex,
                                         dataAccessibilityLabel: dataAccessibilityLabel,
                                         data: data,
                                         onTapDay: onTapDay,
                                         day: dayBuilder)
                    .id(month.idx.monthID)
                    .padding(.horizontal, 12)
                    .accessibilityFocused($focusedMonthID, equals: month.idx.monthID)
                }
            }
            .scrollTargetLayout()
        }
        .introspect(.scrollView, on: .iOS(.v17, .v18, .v26)) { scrollView in
            scrollView.scrollsToTop = scrollsToTop
        }
        .scrollPosition(id: $currentMonthTarget, anchor: .top)
        .background(Color.Elevation.background)
        .onDayChange { today = VGRCalendarIndexKey(from: .now) }
        .onAppear {
            DispatchQueue.main.async {
                print("onAppear: Setting monthTarget to \(selectedIndex.monthID) (\(currentMonthTarget ?? "n/a"))")
                currentMonthTarget = nil
                currentMonthTarget = selectedIndex.monthID
                focusedMonthID = selectedIndex.monthID
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("calendar.today".localizedBundle) {
                    DispatchQueue.main.async {
                        currentMonthTarget = nil
                        selectedIndex = today
                        currentMonthTarget = selectedIndex.monthID
                        focusedMonthID = selectedIndex.monthID
                        print("today: Setting monthTarget to \(selectedIndex.monthID) (\(currentMonthTarget ?? "n/a"))")
                    }
                }
            }
        }
    }
}

#Preview {
    /// selectedIndex contains the currently selected date using the CalendarIndexKey
    @Previewable @State var selectedIndex: VGRCalendarIndexKey = VGRCalendarIndexKey(from: .now)

    /// selectedWeekIndex is only used to trigger / push the weekView onto the NavStack
    @Previewable @State var selectedWeekIndex: VGRCalendarIndexKey? = nil

    /// This is an example of what the data that can be passed to the CalendarView can look like.
    /// ExampleCalendarData is your own data structure that you pass and that you use to populate
    /// the DayCells (in this example called _ExampleDayCell_).
    @Previewable @State var calendarData: [VGRCalendarIndexKey: ExampleCalendarData] = [
        VGRCalendarIndexKey(year: 2025, month: 5, day: 20) : .init(hasEvent: true, isRecurring: false),
        VGRCalendarIndexKey(year: 2025, month: 5, day: 22) : .init(hasEvent: true, isRecurring: false),
    ]

    @Previewable @State var currentWeekID: String? = nil

    let today = VGRCalendarIndexKey(from: .now)

    /// The total maximal range for the Calendar. Can be set arbitrarily.
    let maxInterval: DateInterval = Calendar.current.dateInterval(
        from: .now,
        count: 2,
        component: .year
    )!

    TabView {

        Tab {

            NavigationStack {
                VGRCalendarView(selectedIndex: $selectedIndex,
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
                            let date = VGRCalendarIndexKey(from: maxInterval.start.addingTimeInterval(randomOffset))
                            withAnimation {
                                calendarData[date] = .init(hasEvent: true, isRecurring: false)
                            }
                        }
                    }
                }
                .navigationDestination(item: $selectedWeekIndex) { weekIndex in
                    VStack {
                        VGRCalendarWeekView(
                            currentWeekID: $currentWeekID,
                            interval: maxInterval,
                            data: calendarData,
                            selectedDate: $selectedIndex,
                        ) { data in
                            /// Default height of a day cell
                            guard let data else { return 52.0 }

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
        } label: {
            Image(systemName: "calendar")
            Text("Calendar")
        }

        Tab {
            Text("Demo tab just to test tab-switching behavior of the VGRCalendarView")
        } label: {
            Image(systemName: "house")
            Text("Other")
        }

    }
}
