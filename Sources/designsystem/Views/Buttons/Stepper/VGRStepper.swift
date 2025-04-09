import SwiftUI

public struct VGRStepper : View {
    @Binding var value: Double
    
    let step: Double
    let range: ClosedRange<Double>
    var unit: String = ""
    var accessibilityUnit: String = ""
    
    var activeColor: Color = Color.Primary.action
    var inactiveColor: Color = Color.Primary.action.opacity(0.1)
    
    private func increase() {
        if self.value < range.upperBound {
            self.value = self.value + self.step
            self.feedback()
        }
    }
    
    private func decrease() {
        if self.value > range.lowerBound {
            self.value -= self.step
            self.feedback()
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
    
    public init(value: Binding<Double>, step: Double, range: ClosedRange<Double>, unit: String, accessibilityUnit: String) {
        self._value = value
        self.step = step
        self.range = range
        self.unit = unit
        self.accessibilityUnit = accessibilityUnit
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
            .accessibilityLabel("general.decrease")
            .buttonStyle(.borderless)
            
            Text("\(value.formatted()) \(unit)")
                .font(.body)
                .fontWeight(.bold)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.Neutral.text)
            
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
            .accessibilityLabel("general.increase")
            .buttonStyle(.borderless)
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
    
    func feedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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
                
                VGRStepper(value: $value2, step: 1.0, range: 0 ... 100, unit: "handflator", accessibilityUnit: "hanftlaror")
                
                VGRStepper(value: $value3, step: 5, range: 0 ... 25, unit: "x 1 g", accessibilityUnit: "gånger 1 gram")
                
            }
            .padding(16)
        }
    }
}
