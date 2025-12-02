import SwiftUI

/// En stepper-komponent med stöd för icke-uniforma stegvärden.
/// Exempel: 0 → 0.5 → 1 → 2 → 3 → ...
public struct VGRFlexibleStepper: View {

    @State private var repeatTimer: Timer?
    @State private var accelerationStep: Int = 0

    /// En bindning till det numeriska värdet som ska justeras.
    @Binding var value: Double

    /// Tillåtna värden i ordning (t.ex. [0, 0.5, 1, 2, 3]).
    let steps: [Double]

    /// Enhetstext som visas efter värdet.
    let unit: String?

    /// Anpassad formatterare för enhetstext baserat på värdet.
    let unitFormatter: ((Double) -> String)?

    /// Om långtryck med accelererande upprepning är aktiverat.
    let isRepeatOnHoldEnabled: Bool

    /// Tillgänglighetsenhet som läses upp av VoiceOver.
    let accessibilityUnit: String?

    /// Anpassad formatterare för tillgänglighetsenhet baserat på värdet.
    let accessibilityUnitFormatter: ((Double) -> String)?

    /// Anpassad formatterare för att visa värdet (t.ex. "0 - 1" för 0.5).
    let valueFormatter: ((Double) -> String)?

    var activeColor: Color = Color.Primary.action
    var inactiveColor: Color = Color.Primary.action.opacity(0.1)

    private var currentIndex: Int? {
        steps.firstIndex(of: value)
    }

    private var canIncrease: Bool {
        guard let index = currentIndex else { return false }
        return index < steps.count - 1
    }

    private var canDecrease: Bool {
        guard let index = currentIndex else { return false }
        return index > 0
    }

    /// Ökar värdet till nästa steg.
    private func increase() {
        guard let index = currentIndex, index < steps.count - 1 else { return }
        value = steps[index + 1]
    }

    /// Minskar värdet till föregående steg.
    private func decrease() {
        guard let index = currentIndex, index > 0 else { return }
        value = steps[index - 1]
    }

    private var formattedValue: String {
        if let formatter = valueFormatter {
            return formatter(value)
        }
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return value.formatted()
    }

    private var formattedUnit: String {
        if let formatter = unitFormatter {
            return formatter(value)
        }
        return unit ?? ""
    }

    private var formattedAccessibilityUnit: String {
        if let formatter = accessibilityUnitFormatter {
            return formatter(value)
        }
        return accessibilityUnit ?? ""
    }

    private var a11yLabel: String {
        return "\(formattedValue) \(formattedAccessibilityUnit)"
    }

    /// Skapar en ny instans av `VGRFlexibleStepper`.
    /// - Parameters:
    ///   - value: En bindning till det numeriska värdet som ska justeras.
    ///   - steps: En array av tillåtna värden i ordning (t.ex. [0, 0.5, 1, 2, 3]).
    ///   - unit: Enhetstext som visas efter värdet.
    ///   - isRepeatOnHoldEnabled: Om långtryck med accelererande upprepning är aktiverat.
    ///   - accessibilityUnit: Tillgänglighetsenhet som läses upp av VoiceOver.
    ///   - valueFormatter: Anpassad formatterare för att visa värdet.
    public init(
        value: Binding<Double>,
        steps: [Double],
        unit: String,
        isRepeatOnHoldEnabled: Bool = false,
        accessibilityUnit: String,
        valueFormatter: ((Double) -> String)? = nil
    ) {
        self._value = value
        self.steps = steps
        self.unit = unit
        self.unitFormatter = nil
        self.isRepeatOnHoldEnabled = isRepeatOnHoldEnabled
        self.accessibilityUnit = accessibilityUnit
        self.accessibilityUnitFormatter = nil
        self.valueFormatter = valueFormatter
    }

    /// Skapar en ny instans av `VGRFlexibleStepper` med dynamiska enheter.
    /// - Parameters:
    ///   - value: En bindning till det numeriska värdet som ska justeras.
    ///   - steps: En array av tillåtna värden i ordning (t.ex. [0, 0.5, 1, 2, 3]).
    ///   - unitFormatter: Anpassad formatterare för enhetstext baserat på värdet.
    ///   - isRepeatOnHoldEnabled: Om långtryck med accelererande upprepning är aktiverat.
    ///   - accessibilityUnitFormatter: Anpassad formatterare för tillgänglighetsenhet baserat på värdet.
    ///   - valueFormatter: Anpassad formatterare för att visa värdet.
    public init(
        value: Binding<Double>,
        steps: [Double],
        unitFormatter: @escaping (Double) -> String,
        isRepeatOnHoldEnabled: Bool = false,
        accessibilityUnitFormatter: @escaping (Double) -> String,
        valueFormatter: ((Double) -> String)? = nil
    ) {
        self._value = value
        self.steps = steps
        self.unit = nil
        self.unitFormatter = unitFormatter
        self.isRepeatOnHoldEnabled = isRepeatOnHoldEnabled
        self.accessibilityUnit = nil
        self.accessibilityUnitFormatter = accessibilityUnitFormatter
        self.valueFormatter = valueFormatter
    }

    // MARK: - Int initializers

    /// Skapar en ny instans av `VGRFlexibleStepper` med Int-värden.
    /// - Parameters:
    ///   - value: En bindning till det numeriska värdet som ska justeras.
    ///   - steps: En array av tillåtna värden i ordning (t.ex. [0, 1, 2, 3]).
    ///   - unit: Enhetstext som visas efter värdet.
    ///   - isRepeatOnHoldEnabled: Om långtryck med accelererande upprepning är aktiverat.
    ///   - accessibilityUnit: Tillgänglighetsenhet som läses upp av VoiceOver.
    ///   - valueFormatter: Anpassad formatterare för att visa värdet.
    public init(
        value: Binding<Int>,
        steps: [Int],
        unit: String,
        isRepeatOnHoldEnabled: Bool = false,
        accessibilityUnit: String,
        valueFormatter: ((Double) -> String)? = nil
    ) {
        self._value = Binding(
            get: { Double(value.wrappedValue) },
            set: { value.wrappedValue = Int($0) }
        )
        self.steps = steps.map { Double($0) }
        self.unit = unit
        self.unitFormatter = nil
        self.isRepeatOnHoldEnabled = isRepeatOnHoldEnabled
        self.accessibilityUnit = accessibilityUnit
        self.accessibilityUnitFormatter = nil
        self.valueFormatter = valueFormatter
    }

    /// Skapar en ny instans av `VGRFlexibleStepper` med Int-värden och dynamiska enheter.
    /// - Parameters:
    ///   - value: En bindning till det numeriska värdet som ska justeras.
    ///   - steps: En array av tillåtna värden i ordning (t.ex. [0, 1, 2, 3]).
    ///   - unitFormatter: Anpassad formatterare för enhetstext baserat på värdet.
    ///   - isRepeatOnHoldEnabled: Om långtryck med accelererande upprepning är aktiverat.
    ///   - accessibilityUnitFormatter: Anpassad formatterare för tillgänglighetsenhet baserat på värdet.
    ///   - valueFormatter: Anpassad formatterare för att visa värdet.
    public init(
        value: Binding<Int>,
        steps: [Int],
        unitFormatter: @escaping (Double) -> String,
        isRepeatOnHoldEnabled: Bool = false,
        accessibilityUnitFormatter: @escaping (Double) -> String,
        valueFormatter: ((Double) -> String)? = nil
    ) {
        self._value = Binding(
            get: { Double(value.wrappedValue) },
            set: { value.wrappedValue = Int($0) }
        )
        self.steps = steps.map { Double($0) }
        self.unit = nil
        self.unitFormatter = unitFormatter
        self.isRepeatOnHoldEnabled = isRepeatOnHoldEnabled
        self.accessibilityUnit = nil
        self.accessibilityUnitFormatter = accessibilityUnitFormatter
        self.valueFormatter = valueFormatter
    }

    public var body: some View {
        HStack {
            Button {
                decrease()
            } label: {
                Image(systemName: "minus")
                    .frame(width: 16, height: 16)
                    .fontWeight(.bold)
                    .foregroundColor(canDecrease ? activeColor : inactiveColor)
                    .padding(16)
                    .accessibilityHidden(true)
            }
            .disabled(!canDecrease)
            .accessibilityLabel(LocalizedHelper.localized(forKey: "general.decrease"))
            .buttonStyle(.borderless)
            .onTapGesture {
                Haptics.lightImpact()
            }
            .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 25, perform: {}, onPressingChanged: { isPressing in
                guard isRepeatOnHoldEnabled else { return }
                if isPressing {
                    startRepeating({
                        Task { @MainActor in
                            self.tryDecrease()
                        }
                    }, isFirst: true)
                } else {
                    stopRepeating()
                }
            })

            Text("\(formattedValue) \(formattedUnit)")
                .font(.body)
                .fontWeight(.bold)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.Neutral.text)
                .contentTransition(.numericText(value: value))
                .animation(.default, value: value)

            Button {
                increase()
            } label: {
                Image(systemName: "plus")
                    .frame(width: 16, height: 16)
                    .fontWeight(.bold)
                    .foregroundColor(canIncrease ? activeColor : inactiveColor)
                    .padding(16)
                    .accessibilityHidden(true)
            }
            .disabled(!canIncrease)
            .accessibilityLabel(LocalizedHelper.localized(forKey: "general.increase"))
            .buttonStyle(.borderless)
            .onTapGesture {
                Haptics.lightImpact()
            }
            .onChange(of: value, {
                AccessibilityHelpers.postPrioritizedAnnouncement(formattedValue, withPriority: .default)
            })
            .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 25, perform: {}, onPressingChanged: { isPressing in
                guard isRepeatOnHoldEnabled else { return }
                if isPressing {
                    startRepeating({
                        Task { @MainActor in
                            self.tryIncrease()
                        }
                    }, isFirst: true)
                } else {
                    stopRepeating()
                }
            })
        }
        .background(Color.Primary.blueSurfaceMinimal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(a11yLabel)
        .accessibilityAdjustableAction({ direction in
            switch direction {
                case .decrement:
                    decrease()
                case .increment:
                    increase()
                @unknown default:
                    print("n/a")
            }
        })
    }

    @MainActor
    private func tryIncrease() {
        if canIncrease {
            increase()
        }
    }

    @MainActor
    private func tryDecrease() {
        if canDecrease {
            decrease()
        }
    }

    @MainActor
    private func startRepeating(_ action: @escaping @Sendable () -> Void, isFirst: Bool = false) {
        if isFirst {
            accelerationStep = 0
        }

        stopRepeating()

        let interval = max(0.05, 0.3 * pow(0.85, Double(accelerationStep)))

        repeatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [self] _ in
            Task { @MainActor in
                if self.accelerationStep == 0 {
                    Haptics.lightImpact()
                }
                action()
                self.accelerationStep += 1
                self.startRepeating(action)
            }
        }
    }

    private func stopRepeating() {
        repeatTimer?.invalidate()
        repeatTimer = nil
    }
}

#Preview("VGRFlexibleStepper") {

    @Previewable @State var value: Double = 0

    let steps: [Double] = [0, 0.5] + Array(stride(from: 1.0, through: 99.0, by: 1.0))

    ScrollView {
        VGRShape(backgroundColor: Color.Elevation.background) {
            VStack(spacing: 40) {
                VGRFlexibleStepper(
                    value: $value,
                    steps: steps,
                    unitFormatter: { val in
                        val == 0 ? "handflator" : val <= 1 ? "handflata" : "handflator"
                    },
                    isRepeatOnHoldEnabled: true,
                    accessibilityUnitFormatter: { val in
                        val == 0 ? "handflator" : val <= 1 ? "handflata" : "handflator"
                    },
                    valueFormatter: { val in
                        if val == 0.5 {
                            return "0 - 1"
                        }
                        return String(format: "%.0f", val)
                    }
                )

                Text("Actual value: \(value)")
            }
            .padding(16)
        }
    }
}

#Preview("VGRFlexibleStepper (Int)") {
    @Previewable @State var count: Int = 0

    ScrollView {
        VGRShape(backgroundColor: Color.Elevation.background) {
            VStack(spacing: 40) {
                VGRFlexibleStepper(
                    value: $count,
                    steps: [0, 1, 2, 3, 4, 5],
                    unit: "items",
                    accessibilityUnit: "items"
                )

                // Or with dynamic unit
                VGRFlexibleStepper(
                    value: $count,
                    steps: [0, 1, 2, 3, 4, 5],
                    unitFormatter: { $0 == 1 ? "item" : "items" },
                    accessibilityUnitFormatter: { $0 == 1 ? "item" : "items" }
                )

                Text("Actual value: \(count)")
            }
            .padding(16)
        }
    }
}
