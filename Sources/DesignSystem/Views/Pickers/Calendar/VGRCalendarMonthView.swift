import Foundation
import SwiftUI

/// A view that displays a single calendar month with a header and a grid of day cells.
///
/// `VGRCalendarMonthView` renders a month header showing the month and year, followed by
/// a week header and a grid layout of individual day cells. It supports custom day cell
/// rendering, data binding, tap handling, and accessibility customization.
///
/// - Parameters:
///   - Data: A `Hashable` type representing custom data associated with each calendar day
///   - Content: The `View` type used to render individual day cells
///
/// ## Example Usage
/// ```swift
/// VGRCalendarMonthView(
///     month: monthModel,
///     today: todayIndex,
///     selectedIndex: $selectedDate,
///     dataAccessibilityLabel: { month in
///         "Calendar for \(month.idx.date.formatted())"
///     },
///     data: eventData,
///     onTapDay: { index in
///         print("Selected: \(index.date)")
///     }
/// ) { index, data, isCurrent, isSelected in
///     CustomDayCell(index: index, data: data)
/// }
/// ```
public struct VGRCalendarMonthView<Data, Content>: View where Data: Hashable, Content: View {

    // MARK: - Public Properties

    /// Contains information about the current month's layout including days and padding.
    /// The `VGRCalendarPeriodModel` provides the month structure needed for rendering.
    let month: VGRCalendarPeriodModel

    /// The calendar index key representing today's date.
    /// Used to highlight the current day in the month view.
    let today: VGRCalendarIndexKey

    /// Binding to the currently selected calendar date index.
    /// Updates when the user taps a day or when programmatically changed.
    @Binding var selectedIndex: VGRCalendarIndexKey

    /// A dictionary mapping calendar index keys to custom data.
    /// Use this to associate events, appointments, or other information with specific dates.
    let data: [VGRCalendarIndexKey: Data]

    // MARK: - Private Properties

    /// The calendar system used for date calculations and formatting.
    private let calendar: Calendar

    /// The locale used for date formatting and localization.
    private let locale = Locale.current

    /// Grid column configuration for the 7-day week layout.
    /// Creates 7 flexible columns with 2pt spacing and top alignment.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2, alignment: .top), count: 7)

    /// Optional closure that generates a custom accessibility label for the month header.
    /// - Parameter month: The `VGRCalendarPeriodModel` representing this month
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

    // MARK: - Initialization

    /// Creates a new calendar month view with the specified configuration.
    ///
    /// - Parameters:
    ///   - month: The month model containing layout information
    ///   - today: The index key for today's date
    ///   - selectedIndex: Binding to the currently selected date
    ///   - dataAccessibilityLabel: Optional closure to generate custom accessibility labels for the month header
    ///   - data: Dictionary of custom data keyed by calendar index (defaults to empty)
    ///   - calendar: The calendar system to use (defaults to `.current`)
    ///   - onTapDay: Closure called when a day is tapped (defaults to no-op)
    ///   - day: View builder that creates the UI for each day cell
    public init(month: VGRCalendarPeriodModel,
                today: VGRCalendarIndexKey,
                selectedIndex: Binding<VGRCalendarIndexKey>,
                dataAccessibilityLabel: ((VGRCalendarPeriodModel) -> String)? = nil,
                data: [VGRCalendarIndexKey: Data] = [:],
                using calendar: Calendar = .current,
                onTapDay: @escaping (VGRCalendarIndexKey) -> Void = { _ in },
                @ViewBuilder day: @escaping (VGRCalendarIndexKey, Data?, _: Bool, _: Bool) -> Content) {
        self.month = month
        self.today = today
        self._selectedIndex = selectedIndex
        self.data = data
        self.calendar = calendar
        self.dataAccessibilityLabel = dataAccessibilityLabel
        self.onTapDay = onTapDay
        self.dayBuilder = day
    }

    // MARK: - Computed Properties

    /// Generates the accessibility label for the month header.
    /// - Returns: A custom label if `dataAccessibilityLabel` is provided, otherwise defaults to the formatted month and year
    var a11yLabel: String {
        guard let dataAccessibilityLabel else { return month.idx.date.formatted(.dateTime.year().month(.wide)) }
        return dataAccessibilityLabel(month)
    }

    public var body: some View {
        VStack(spacing: 8) {
            Text(month.idx.date.formatted(.dateTime.year().month(.wide)))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.Neutral.text)
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                VGRCalendarWeekHeaderView()

                LazyVGrid(
                    columns: columns,
                    alignment: .leading,
                    spacing: 8,
                    pinnedViews: [.sectionHeaders]
                ) {

                    ForEach(0..<month.leadingPadding, id: \.self) { _ in
                        Spacer()
                    }
                    .accessibilityHidden(true)

                    ForEach(self.month.days, id: \.self) { day in
                        dayBuilder(day,
                                   data[day],
                                   day.hashValue == today.hashValue,
                                   day.hashValue == selectedIndex.hashValue)
                        .id(day.id)
                        .onTapGesture {
                            selectedIndex = day
                            onTapDay(day)
                        }
                    }
                    .accessibilityElement(children: .contain)
                }
                .accessibilityElement(children: .contain)
            }
            .accessibilityElement(children: .contain)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(a11yLabel)
    }
}


#Preview {
    @Previewable @State var selectedIndex: VGRCalendarIndexKey = VGRCalendarIndexKey(from: Calendar.current.date(2025,5,30))
    @Previewable @State var calendarData: [VGRCalendarIndexKey: ExampleCalendarData] = [
        VGRCalendarIndexKey(year: 2025, month: 12, day: 20) : .init(hasEvent: true, isRecurring: false),
        VGRCalendarIndexKey(year: 2025, month: 12, day: 22) : .init(hasEvent: true, isRecurring: false),
    ]

    let vm: VGRCalendarViewModel = .init(interval: DateInterval(start: Calendar.current.date(2025,12,1),
                                                                end: Calendar.current.date(2025,12,31)))
    let firstMonth = vm.months.first!
    let today = VGRCalendarIndexKey(from: Calendar.current.date(2025,12,15))

    NavigationStack {
        ScrollView {
            VGRCalendarMonthView(month: firstMonth,
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
