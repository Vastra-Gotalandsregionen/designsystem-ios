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

    @Binding var startDate: Date
    @Binding var selectedFrequency: Int
    @Binding var selectedPeriod: RecurrencePeriod
    @Binding var selectedWeekdays: [RecurrenceWeekday]?

    public init(startDate: Binding<Date>,
                selectedFrequency: Binding<Int>,
                selectedPeriod: Binding<RecurrencePeriod>,
                selectedWeekdays: Binding<[RecurrenceWeekday]?>) {
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

    /// selectedIndex only returns a valid value when the user has selected a monthly recurrence pattern
    var selectedIndex: Int? {
        return self.selectedPeriod == .month ? self.startDate.dayInMonth : nil
    }

    var currentSelection: String {
        let recurrence = Recurrence(
            frequency: self.selectedFrequency,
            period: self.selectedPeriod,
            index: self.selectedIndex,
            weekdays: self.selectedWeekdays ?? []
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
                weekdays.removeAll { $0 == weekDay }
            }
        } else {
            weekdays.append(weekDay)
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
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 16) {
                        Text("recurrence.interval".localizedBundle)
                            .font(.body).fontWeight(.medium)
                            .foregroundStyle(Color.Neutral.text)
                        Text(currentSelection)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .font(.body).fontWeight(.regular)
                            .foregroundStyle(Color.Neutral.text)
                    }
                    .foregroundColor(Color.Neutral.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)

                    Divider()
                        .foregroundStyle(Color.Neutral.divider)

                    VGRMultiPickerView(data: self.pickerData,
                                       widths: self.widths,
                                       selections: self.$selections)
                    .onChange(of: self.selections) { _, newVal in
                        updateSelection(newVal)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.Elevation.elevation1)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding([.top,.leading,.trailing],16)

                if isWeekPeriod {
                    VStack(spacing: 16) {
                        Text("recurrence.weekday.choose".localizedBundle)
                            .textCase(.none)
                            .font(.headline)
                            .foregroundStyle(Color.Neutral.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 32)

                        VStack(spacing: 0) {
                            ForEach(RecurrenceWeekday.allCases, id:\.id) { weekday in
                                Label {
                                    if selectedWeekdays?.contains(weekday) == true {
                                        Text("recurrence.weekday.\(weekday.description)".localizedBundle)
                                            .foregroundStyle(Color.Neutral.text)
                                            .accessibilityLabel("\("general.selected".localizedBundle), \("recurrence.weekday.\(weekday.description)".localizedBundle)")
                                    } else {
                                        Text("recurrence.weekday.\(weekday.description)".localizedBundle)
                                            .foregroundStyle(Color.Neutral.text)
                                            .accessibilityLabel("\("general.notselected".localizedBundle), \("recurrence.weekday.\(weekday.description)".localizedBundle)")
                                    }

                                } icon: {
                                    if selectedWeekdays?.contains(weekday) == true {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.Primary.action)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundStyle(Color.Primary.action)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    toggleWeekday(weekday)
                                }

                                if weekday != .sunday {
                                    Divider()
                                        .foregroundStyle(Color.Neutral.divider)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.Elevation.elevation1)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding([.leading, .trailing, .bottom], 16)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.Elevation.background)
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
    @Previewable @State var weekdays: [RecurrenceWeekday]? = []

    NavigationStack {
        VGRRecurrencePickerView(startDate: $startDate,
                                selectedFrequency: $frequency,
                                selectedPeriod: $period,
                                selectedWeekdays: $weekdays)
    }
}
