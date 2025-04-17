import SwiftUI

/// En återanvändbar stepper-komponent som låter användaren öka eller minska ett numeriskt värde.
/// Stödjer valfri feedback och långtryck med accelererande upprepning.
public struct VGRStepper : View {
    
    @State private var repeatTimer: Timer?
    @State private var accelerationStep: Int = 0
    
    /// En bindning till det numeriska värdet som ska justeras.
    @Binding var value: Double
    
    /// Stegvärdet som ökar eller minskar värdet.
    let step: Double
    /// Tillåtet spann för värdet.
    let range: ClosedRange<Double>
    /// Enhetstext som visas efter värdet.
    var unit: String = ""
    /// Om långtryck med accelererande upprepning är aktiverat.
    let isRepeatOnHoldEnabled: Bool
    /// Tillgänglighetsenhet som läses upp av VoiceOver.
    var accessibilityUnit: String = ""
    
    var activeColor: Color = Color.Primary.action
    var inactiveColor: Color = Color.Primary.action.opacity(0.1)
    
    /// Ökar det aktuella värdet med stegvärdet.
    private func increase() {
        if self.value < range.upperBound {
            self.value = self.value + self.step
        }
    }
    
    /// Minskar det aktuella värdet med stegvärdet.
    private func decrease() {
        if self.value > range.lowerBound {
            self.value -= self.step
        }
    }
    
    private var canIncrease: Bool {
        self.value < range.upperBound
    }
    
    private var canDecrease: Bool {
        self.value > range.lowerBound
    }
    
    private var a11ylabel: String {
        return "\(self.value.formatted()) \(self.accessibilityUnit)"
    }
    
    /// Skapar en ny instans av `VGRStepper`.
    /// - Parameters:
    ///   - value: En bindning till det numeriska värdet som ska justeras.
    ///   - step: Stegvärdet som ökar eller minskar värdet.
    ///   - range: Tillåtet spann för värdet.
    ///   - unit: Enhetstext som visas efter värdet.
    ///   - isRepeatOnHoldEnabled: Om långtryck med accelererande upprepning är aktiverat.
    ///   - accessibilityUnit: Tillgänglighetsenhet som läses upp av VoiceOver.
    public init(value: Binding<Double>, step: Double, range: ClosedRange<Double>, unit: String, isRepeatOnHoldEnabled: Bool = false, accessibilityUnit: String) {
        self._value = value
        self.step = step
        self.range = range
        self.unit = unit
        self.isRepeatOnHoldEnabled = isRepeatOnHoldEnabled
        self.accessibilityUnit = accessibilityUnit
    }
    
    /// Innehåller visuell representation av stepper-komponenten.
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
                performHapticFeedback()
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
            
            Text("\(value.formatted()) \(unit)")
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
                performHapticFeedback()
            }
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
        .accessibilityLabel(a11ylabel)
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
    
    /// Utför haptisk feedback när användaren trycker på knapparna.
    func performHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Försöker öka värdet om det är möjligt.
    @MainActor
    private func tryIncrease() {
        if canIncrease {
            increase()
        }
    }
    
    /// Försöker minska värdet om det är möjligt.
    @MainActor
    private func tryDecrease() {
        if canDecrease {
            decrease()
        }
    }
    
    /// Startar upprepning av en åtgärd med accelererande intervall.
    /// - Parameters:
    ///   - action: Åtgärden som ska upprepas.
    ///   - isFirst: Om det är första gången åtgärden startas.
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
                    self.performHapticFeedback()
                }
                action()
                self.accelerationStep += 1
                self.startRepeating(action)
            }
        }
    }
    
    /// Stoppar upprepning av åtgärden.
    private func stopRepeating() {
        repeatTimer?.invalidate()
        repeatTimer = nil
    }
}

#Preview("StepperView") {
    
    @Previewable @State var value1: Double = 1.5
    @Previewable @State var value2: Double = 1.0
    @Previewable @State var value3: Double = 5
    
    ScrollView {
        VGRShape (backgroundColor: Color.Elevation.background) {
            VStack (spacing: 40) {
                VGRStepper(value: $value1, step: 0.5, range: 0 ... 5, unit: "x 1 g", accessibilityUnit: "gånger 1 gram")
                
                VGRStepper(value: $value2, step: 1.0, range: 0 ... 100, unit: "handflator", isRepeatOnHoldEnabled: true, accessibilityUnit: "handflator")
                
                VGRStepper(value: $value3, step: 5, range: 0 ... 25, unit: "x 1 g", accessibilityUnit: "gånger 1 gram")
                
            }
            .padding(16)
        }
    }
}
