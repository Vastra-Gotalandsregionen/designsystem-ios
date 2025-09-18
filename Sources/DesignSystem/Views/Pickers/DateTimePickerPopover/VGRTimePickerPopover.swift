import SwiftUI


public struct TimePickerPopoverModifier: ViewModifier {
    @Binding var isPresented: Bool
    let dateBinding: Binding<Date>
    let title: String
    let dateRange: ClosedRange<Date>
    let onDismiss: (() -> Void)?

    @State var selections: [Int] = [10, 30]

    let data: [[String]] = [
        Array(0 ... 23).map { String(format: "%02d", $0) },
        Array(0 ... 59).map { String(format: "%02d", $0) },
    ]

    let widths: [CGFloat] = [
        60, 60,
    ]

    public init(
        isPresented: Binding<Bool>,
        dateBinding: Binding<Date>,
        title: String,
        dateRange: ClosedRange<Date>,
        onDismiss: (() -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.dateBinding = dateBinding
        self.title = title
        self.dateRange = dateRange
        self.onDismiss = onDismiss

        /// Initialize selections based on the current dateBinding value
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: dateBinding.wrappedValue)
        let minute = calendar.component(.minute, from: dateBinding.wrappedValue)
        self._selections = State(initialValue: [hour, minute])
    }

    public func body(content: Content) -> some View {
        content
            .popover(isPresented: $isPresented) {
                VGRMultiPickerView(data: data,
                                   widths: widths,
                                   selections: $selections)
                .frame(width: 200, height: 216)
                .presentationCompactAdaptation(.popover)
                .accessibilityLabel(title)
            }
            .onChange(of: isPresented) { _, newValue in
                if !newValue { /// When popup is dismissed
                    onDismiss?()
                }
            }
            .onChange(of: selections) { _, newValue in
                var calendar = Calendar.current
                calendar.timeZone = .current

                let now = Date()
                if let updatedDate = calendar.date(
                    bySettingHour: newValue[0],
                    minute: newValue[1],
                    second: 0,
                    of: now
                ) {
                    dateBinding.wrappedValue = updatedDate
                }
            }
    }
}

public extension View {
    func vgrTimePickerPopover(
        isPresented: Binding<Bool>,
        date: Binding<Date>,
        title: String,
        dateRange: ClosedRange<Date>,
        onDismiss: (() -> Void)? = nil // Added optional onDismiss parameter
    ) -> some View {
        self.modifier(
            TimePickerPopoverModifier(
                isPresented: isPresented,
                dateBinding: date,
                title: title,
                dateRange: dateRange,
                onDismiss: onDismiss
            )
        )
    }
}

#Preview {
    @Previewable @State var isPopoverVisible = false
    @Previewable @State var timeOfDay = Date()

    let startDateRange: Date = Date().addingTimeInterval(-300000)
    let endDateRange: Date = Date().addingTimeInterval(300000)
    let range: ClosedRange<Date> = startDateRange...endDateRange

    NavigationStack {
        ScrollView {
            Spacer()
                .frame(height: 100)
            Button {
                isPopoverVisible.toggle()
            } label: {
                Text("\(timeOfDay.formatted(date: .omitted, time: .shortened))")
                    .font(.system(.title2, design: .monospaced))
                    .foregroundStyle(Color.primary)
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .vgrTimePickerPopover(
                isPresented: $isPopoverVisible,
                date: $timeOfDay,
                title: "Välj tid",
                dateRange: range,
                onDismiss: {
                    print("dismissed")
                }
            )

        }
        .navigationTitle("VGRTimePickerPopover")
    }
}
