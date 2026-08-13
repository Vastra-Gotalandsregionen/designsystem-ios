import SwiftUI

/// A reusable SwiftUI view that allows users to configure a recurrence pattern.
///
/// This picker supports selecting:
/// - **Frequency** (e.g., every 1–99 intervals)
/// - **Period** (day, week, month)
/// - **Optional weekdays** when the period is weekly
///
/// It provides:
/// - A combined display string summarizing the current selection
/// - Multi-column picker for frequency and period
/// - A selectable list of weekdays if weekly recurrence is chosen
///
/// Bindings:
/// - `startDate`: Used to initialize the monthly recurrence index (e.g., day of month)
/// - `selectedFrequency`: The currently selected frequency (e.g., every 2 weeks)
/// - `selectedPeriod`: The recurrence period (day, week, month)
/// - `selectedWeekdays`: The selected weekdays (only applicable for weekly recurrences)
///
/// Example:
/// ```swift
/// VGRRecurrencePickerView(
///     startDate: $startDate,
///     selectedFrequency: $frequency,
///     selectedPeriod: $period,
///     selectedWeekdays: $weekdays
/// )
/// ```
public struct VGRRecurrencePickerView: View {

    @ScaledMetric private var iconSize: CGFloat = 22
    @Binding var startDate: Date
    @Binding var selectedFrequency: Int
    @Binding var selectedPeriod: RecurrencePeriod
    @Binding var selectedWeekdays: Set<RecurrenceWeekday>?

    public init(startDate: Binding<Date>,
                selectedFrequency: Binding<Int>,
                selectedPeriod: Binding<RecurrencePeriod>,
                selectedWeekdays: Binding<Set<RecurrenceWeekday>?>) {
        self._startDate = startDate
        self._selectedFrequency = selectedFrequency
        self._selectedPeriod = selectedPeriod
        self._selectedWeekdays = selectedWeekdays
    }

    private let pickerData: [[String]] = [
        (1...99).map({ String($0) }),
        RecurrencePeriod.allCases.map({ "recurrence.period.\($0.description)".localizedBundle.lowercased() }),
    ]

    private let widths: [CGFloat] = [
        60, 90,
    ]

    @State private var selections: [Int] = [0, 0]

    /// Bridges the optional `selectedWeekdays` binding to the non-optional
    /// selection binding required by `VGRMultiSelectionList`, treating `nil` as empty.
    private var weekdaySelection: Binding<Set<RecurrenceWeekday>> {
        Binding(
            get: { selectedWeekdays ?? [] },
            set: { selectedWeekdays = $0 }
        )
    }

    /// selectedIndex only returns a valid value when the user has selected a monthly recurrence pattern
    var selectedIndex: Int? {
        return self.selectedPeriod == .month ? self.startDate.dayInMonth : nil
    }

    var currentSelection: String {
        let recurrence = Recurrence(
            frequency: self.selectedFrequency,
            period: self.selectedPeriod,
            index: self.selectedIndex,
            weekdays: self.selectedWeekdays.map(Array.init) ?? []
        )
        return recurrence.formatString(startDate: startDate)
    }

    var isWeekPeriod: Bool {
        return self.selections[1] == RecurrencePeriod.week.rawValue
    }

    var isMonthPeriod: Bool {
        return self.selections[1] == RecurrencePeriod.month.rawValue
    }

    func toggleWeekday(_ weekDay: RecurrenceWeekday) {
        guard var weekdays = selectedWeekdays else {
            /// If nil, initialize with the tapped weekday
            selectedWeekdays = [weekDay]
            return
        }

        if weekdays.contains(weekDay) {
            /// Prevent clearing out all weekdays
            if weekdays.count > 1 {
                weekdays.remove(weekDay)
            }
        } else {
            weekdays.insert(weekDay)
        }

        selectedWeekdays = weekdays
    }

    func setSelections() {
        self.selections[0] = self.selectedFrequency - 1
        self.selections[1] = RecurrencePeriod.allCases.firstIndex(of: self.selectedPeriod) ?? 0
    }

    func updateSelection(_ selection: [Int]) {
        self.selectedFrequency = selection[0] + 1
        self.selectedPeriod = RecurrencePeriod.allCases[selection[1]]

        /// If there is no weekday selected at start, set the current weekday as pre-selected
        if isWeekPeriod {
            if selectedWeekdays?.isEmpty ?? true {
                if let today = RecurrenceWeekday(rawValue: Date.now.weekday) {
                    selectedWeekdays = [today]
                }
            }
        }
    }

    public var body: some View {
        VGRContainer {
            VGRSection {
                VGRList {
                    VGRListRow(title: "recurrence.interval".localizedBundle,
                               subtitle: currentSelection,
                               icon: {
                        Image(systemName: "repeat")
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize)
                    })

                    VGRMultiPickerView(data: self.pickerData,
                                       widths: self.widths,
                                       selections: self.$selections)
                    .onChange(of: self.selections) { _, newVal in
                        updateSelection(newVal)
                    }
                }
            }

            if isWeekPeriod {
                VGRMultiSelectionList(
                    header: "recurrence.weekday.choose".localizedBundle,
                    items: RecurrenceWeekday.allCases,
                    selection: weekdaySelection,
                    minimumSelectionCount: 1,
                    warnIfNotSelected: false) { weekday, selected in
                        VGRCheckRow(title: "recurrence.weekday.\(weekday.description)".localizedBundle,
                                     isSelected: selected)
                    }
            }
        }
        .navigationTitle("recurrence.title".localizedBundle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setSelections()
        }
    }
}

#Preview {
    @Previewable @State var startDate: Date = .now
    @Previewable @State var frequency: Int = 1
    @Previewable @State var period: RecurrencePeriod = .week
    @Previewable @State var weekdays: Set<RecurrenceWeekday>? = []

    NavigationStack {
        VGRRecurrencePickerView(startDate: $startDate,
                                selectedFrequency: $frequency,
                                selectedPeriod: $period,
                                selectedWeekdays: $weekdays)
    }
}
