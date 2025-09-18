import SwiftUI

public struct VGRDatePickerPopover: View {
    @Binding var date: Date
    let title: String
    let dateRange: ClosedRange<Date>
    let displayedComponents: DatePicker.Components

    public init(date: Binding<Date>,
                title: String,
                dateRange: ClosedRange<Date>,
                displayedComponents: DatePicker.Components = [.date]) {
        self._date = date
        self.title = title
        self.dateRange = dateRange
        self.displayedComponents = displayedComponents
    }

    public var body: some View {
        DatePicker(
            title,
            selection: $date,
            in: dateRange,
            displayedComponents: displayedComponents
        )
        .labelsHidden()
        .frame(width: 350)
        .datePickerStyle(.graphical)
        .presentationCompactAdaptation(.popover)
    }
}

public struct DatePickerPopoverModifier: ViewModifier {
    @Binding var isPresented: Bool
    let dateBinding: Binding<Date>
    let title: String
    let dateRange: ClosedRange<Date>
    let displayedComponents: DatePicker.Components
    let onDismiss: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .popover(isPresented: $isPresented) {
                VGRDatePickerPopover(
                    date: dateBinding,
                    title: title,
                    dateRange: dateRange,
                    displayedComponents: displayedComponents
                )
            }
            .onChange(of: isPresented) { _, newValue in
                if !newValue { // When popup is dismissed
                    onDismiss?()
                }
            }
    }
}

public extension View {
    func vgrDatePickerPopover(
        isPresented: Binding<Bool>,
        date: Binding<Date>,
        title: String,
        dateRange: ClosedRange<Date>,
        displayedComponents: DatePicker.Components = [.date],
        onDismiss: (() -> Void)? = nil // Added optional onDismiss parameter
    ) -> some View {
        self.modifier(
            DatePickerPopoverModifier(
                isPresented: isPresented,
                dateBinding: date,
                title: title,
                dateRange: dateRange,
                displayedComponents: displayedComponents,
                onDismiss: onDismiss
            )
        )
    }
}

#Preview {
    @Previewable @State var isPopoverVisible = false
    @Previewable @State var selectedDate = Date()

    let startDateRange: Date = Date().addingTimeInterval(-((24*60*60) * 90))
    let endDateRange: Date = Date().addingTimeInterval(((24*60*60) * 90))
    let range: ClosedRange<Date> = startDateRange...endDateRange

    NavigationStack {
        ScrollView {
            Spacer()
                .frame(height: 100)
            Button {
                isPopoverVisible.toggle()
            } label: {
                Text("\(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(.title2, design: .monospaced))
                    .foregroundStyle(Color.primary)
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .vgrDatePickerPopover(
                isPresented: $isPopoverVisible,
                date: $selectedDate,
                title: "Välj datum",
                dateRange: range,
                onDismiss: {
                    print("dismissed")
                }
            )

        }
        .navigationTitle("VGRDatePickerPopover")
    }
}
