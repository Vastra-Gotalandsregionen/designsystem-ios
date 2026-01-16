import SwiftUI

/// Actions that can be performed on the calendar
public class VGRCalendarActions<DayData: Hashable>: ObservableObject {
    fileprivate weak var viewController: VGRCalendarViewController<DayData>?

    public init() {}

    /// Scrolls the calendar to today's date
    public func scrollToToday(animated: Bool = true) {
        viewController?.scrollToDate(Date(), animated: animated)
    }

    /// Scrolls the calendar to a specific date
    public func scrollToDate(_ date: Date, animated: Bool = true) {
        viewController?.scrollToDate(date, animated: animated)
    }
}

/// A high-performance SwiftUI calendar view backed by UIKit's UICollectionView
/// Supports infinite scrolling and custom day cell rendering
public struct VGRCalendarView<DataProvider: VGRCalendarDataProviding, DayContent: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = VGRCalendarViewController<DataProvider.DayData>

    /// Binding to the currently selected date
    @Binding var selectedDate: VGRCalendarIndexKey?

    /// Calendar data provider
    var data: DataProvider

    /// The initial date to scroll to (defaults to today)
    var initialDate: Date

    /// Actions object for controlling the calendar
    var actions: VGRCalendarActions<DataProvider.DayData>?

    /// Callback when a date is tapped (separate from selection binding)
    var onDateTapped: ((VGRCalendarIndexKey) -> Void)?

    /// Custom day content builder
    private let dayContent: (VGRCalendarIndexKey, DataProvider.DayData?, Bool, Bool) -> DayContent

    /// Initialize with custom day content
    /// - Parameters:
    ///   - selectedDate: Binding to the currently selected date
    ///   - data: Calendar data provider conforming to VGRCalendarDataProviding
    ///   - initialDate: The initial date to scroll to (defaults to today)
    ///   - actions: Actions object for controlling the calendar
    ///   - onDateTapped: Callback when a date is tapped (for navigation, etc.)
    ///   - dayContent: ViewBuilder closure providing custom day cell content
    ///     - Parameters: indexKey, eventData, isCurrent, isSelected
    public init(
        selectedDate: Binding<VGRCalendarIndexKey?>,
        data: DataProvider,
        initialDate: Date = Date(),
        actions: VGRCalendarActions<DataProvider.DayData>? = nil,
        onDateTapped: ((VGRCalendarIndexKey) -> Void)? = nil,
        @ViewBuilder dayContent: @escaping (VGRCalendarIndexKey, DataProvider.DayData?, Bool, Bool) -> DayContent
    ) {
        self._selectedDate = selectedDate
        self.data = data
        self.initialDate = initialDate
        self.actions = actions
        self.onDateTapped = onDateTapped
        self.dayContent = dayContent
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> VGRCalendarViewController<DataProvider.DayData> {
        let vc = VGRCalendarViewController<DataProvider.DayData>(
            initialDate: initialDate,
            dayContentBuilder: { [dayContent] indexKey, eventData, isCurrent, isSelected in
                AnyView(
                    dayContent(indexKey, eventData, isCurrent, isSelected)
                        .allowsHitTesting(false)
                )
            }
        )

        /// Build dictionaries from data provider
        updateViewControllerData(vc)

        vc.selectedDate = selectedDate
        vc.onDateSelected = { indexKey in
            context.coordinator.parent.selectedDate = indexKey
            context.coordinator.parent.onDateTapped?(indexKey)
        }

        /// Wire up actions
        actions?.viewController = vc

        return vc
    }

    public func updateUIViewController(_ uiViewController: VGRCalendarViewController<DataProvider.DayData>, context: Context) {
        context.coordinator.parent = self

        /// Update data from provider
        updateViewControllerData(uiViewController)

        if uiViewController.selectedDate != selectedDate {
            uiViewController.selectedDate = selectedDate
        }

        /// Keep actions wired up
        actions?.viewController = uiViewController
    }

    /// Updates the view controller's data dictionaries from the data provider
    private func updateViewControllerData(_ viewController: VGRCalendarViewController<DataProvider.DayData>) {
        viewController.calendarData = data.dayData
        viewController.monthAccessibilityLabels = data.monthLabels
    }

    public final class Coordinator {
        var parent: VGRCalendarView

        init(_ parent: VGRCalendarView) {
            self.parent = parent
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedDate: VGRCalendarIndexKey? = VGRCalendarIndexKey(from: .now)
    @Previewable @State var calendarActions = VGRCalendarActions<ExampleCalendarData>()
    @Previewable @State var navigateToDate: VGRCalendarIndexKey?

    /// Generate sample data spanning multiple months
    let sampleData: VGRCalendarData<ExampleCalendarData> = {
        var dayData: [VGRCalendarIndexKey: ExampleCalendarData] = [:]
        var monthLabels: [VGRCalendarSection: String] = [:]
        let calendar = Calendar.current
        let today = Date()

        /// Helper to add data for a specific day offset
        func addData(dayOffset: Int, hasEvent: Bool, isRecurring: Bool) {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { return }
            let key = VGRCalendarIndexKey(from: date)
            dayData[key] = ExampleCalendarData(hasEvent: hasEvent, isRecurring: isRecurring)
        }

        /// Add some sample events
        addData(dayOffset: -45, hasEvent: true, isRecurring: false)
        addData(dayOffset: -30, hasEvent: true, isRecurring: true)
        addData(dayOffset: -14, hasEvent: true, isRecurring: false)
        addData(dayOffset: -7, hasEvent: true, isRecurring: false)
        addData(dayOffset: -3, hasEvent: true, isRecurring: true)
        addData(dayOffset: 0, hasEvent: true, isRecurring: false)
        addData(dayOffset: 2, hasEvent: true, isRecurring: false)
        addData(dayOffset: 5, hasEvent: true, isRecurring: true)
        addData(dayOffset: 10, hasEvent: true, isRecurring: false)
        addData(dayOffset: 14, hasEvent: true, isRecurring: false)
        addData(dayOffset: 21, hasEvent: true, isRecurring: true)
        addData(dayOffset: 30, hasEvent: true, isRecurring: false)
        addData(dayOffset: 45, hasEvent: true, isRecurring: false)

        /// Generate month accessibility labels based on event counts
        let eventsByMonth = Dictionary(grouping: dayData) { element in
            VGRCalendarSection(year: element.key.year, month: element.key.month)
        }

        for (section, events) in eventsByMonth {
            let totalEvents = events.count
            let monthDate = section.firstDayDate
            let monthName = monthDate.formatted(.dateTime.month(.wide).year())
            monthLabels[section] = "\(monthName), \(totalEvents) events"
        }

        return VGRCalendarData(dayData: dayData, monthLabels: monthLabels)
    }()

    NavigationStack {
        VGRCalendarView(
            selectedDate: $selectedDate,
            data: sampleData,
            actions: calendarActions,
            onDateTapped: { date in
                navigateToDate = date
            }
        ) { indexKey, eventData, isCurrent, isSelected in
            ExampleDayCell(
                date: indexKey,
                data: eventData,
                current: isCurrent,
                selected: isSelected
            )
            .padding(.horizontal, 1)
        }
        .ignoresSafeArea()
        .background(Color.Elevation.background)
        .navigationTitle("VGRCalendarView")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $navigateToDate) { date in
            VStack {
                Text("Selected: \(date.id)")
                    .font(.headline)
                Text("Tap 'Today' to scroll back")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Detail")
            .onDisappear {
                if let selectedDate {
                    calendarActions.scrollToDate(selectedDate.date, animated: true)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    calendarActions.scrollToToday()
                } label: {
                    Text("calendar.today".localizedBundle)
                }
            }
        }
    }
}
