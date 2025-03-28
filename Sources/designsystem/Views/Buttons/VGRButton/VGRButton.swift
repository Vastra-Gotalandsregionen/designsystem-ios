import SwiftUI

public protocol VGRButtonVariantProtocol {
    associatedtype Body: View
    func makeBody(configuration: VGRButton.Configuration) -> Body
    
    typealias Configuration = VGRButton.Configuration
}

public enum VGRButtonVariant {
    case primary
    case secondary
    case vertical
    case tertiary
    
    func resolve() -> any VGRButtonVariantProtocol {
        switch self {
        case .primary:
            return PrimaryVGRButtonStyle()
        case .secondary:
            return SecondaryVGRButtonVariant()
        case .vertical:
            return VerticalButtonVariant()
        case .tertiary:
            return TertiaryVGRButtonVariant()
        }
    }
}

public struct VGRButton: View {
    
    public struct Configuration {
        let label: String
        let icon: Image?
        let isEnabled: Bool
        let accessibilityHint: String
        let action: () -> Void
    }
    
    private let configuration: Configuration
    private var variant: any VGRButtonVariantProtocol
    
    public init(
        label: String,
        icon: Image? = nil,
        isEnabled: Binding<Bool> = .constant(true),
        accessibilityHint: String = "",
        variant: VGRButtonVariant = .primary,
        action: @escaping () -> Void
    ) {
        self.configuration = Configuration(
            label: label,
            icon: icon,
            isEnabled: isEnabled.wrappedValue,
            accessibilityHint: accessibilityHint,
            action: action
        )
        self.variant = variant.resolve()
    }
    
    public var body: some View {
        AnyView(variant.makeBody(configuration: configuration))
            .accessibilityHint(configuration.accessibilityHint)
        
        //TODO: - Not sure if its a great idea to have a11yhint here, needs to be tested in device
    }
}

public struct PrimaryVGRButtonStyle: VGRButtonVariantProtocol {
    public func makeBody(configuration: VGRButton.Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: 8) {
                if let icon = configuration.icon {
                    icon
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color.Neutral.textInverted)
                        .accessibilityHidden(true)
                }
                Text(configuration.label)
                    .font(.headline)
            }
            .foregroundStyle(Color.Neutral.textInverted)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.Primary.action)
            .cornerRadius(16)
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .disabled(!configuration.isEnabled)
    }
}

public struct SecondaryVGRButtonVariant: VGRButtonVariantProtocol {
    public func makeBody(configuration: VGRButton.Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: 8) {
                if let icon = configuration.icon {
                    icon
                        .resizable()
                        .frame(width: 16, height: 16)
                        .accessibilityHidden(true)
                }
                Text(configuration.label)
                    .font(.headline)
            }
            .foregroundColor(Color.Primary.action)
            .padding()
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.Primary.action, lineWidth: 2)
            )
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .disabled(!configuration.isEnabled)
    }
}

public struct VerticalButtonVariant: VGRButtonVariantProtocol {
    public func makeBody(configuration: VGRButton.Configuration) -> some View {
        Button(action: configuration.action) {
            VStack(spacing: 8) {
                if let icon = configuration.icon {
                    icon
                        .resizable()
                        .frame(width: 16, height: 16)
                        .accessibilityHidden(true)
                }
                Text(configuration.label)
                    .font(.headline)
            }
            .foregroundStyle(Color.Neutral.text)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.Primary.blueSurfaceMinimal)
            .cornerRadius(16)
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .disabled(!configuration.isEnabled)
    }
}

public struct TertiaryVGRButtonVariant: VGRButtonVariantProtocol {
    public func makeBody(configuration: VGRButton.Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: 8) {
                if let icon = configuration.icon {
                    icon
                        .resizable()
                        .frame(width: 16, height: 16)
                        .accessibilityHidden(true)
                }
                Text(configuration.label)
                    .font(.headline)
            }
            .foregroundColor(Color.Primary.action)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.Primary.blueSurfaceMinimal)
            .cornerRadius(12)
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .disabled(!configuration.isEnabled)
    }
}

#Preview {
    
    @Previewable @State var isPrimaryEnabled: Bool = false
    @Previewable @State var isSecondaryEnabled: Bool = false
    @Previewable @State var isVerticalEnabled: Bool = false
    @Previewable @State var isTertiaryEnabled: Bool = false
    
    ScrollView {
        VGRShape(backgroundColor: Color.Elevation.background) {
            VStack(spacing: 16) {
                VGRButton(label: "Primary", action: {
                    isPrimaryEnabled.toggle()
                })
                
                VGRButton(label: "Primary With Icon", icon: Image(systemName: "heart"), variant: .primary) {
                    print("Tapped with icon")
                }
                
                VGRButton(label: "Primary Disabled", icon: Image(systemName: "heart"), isEnabled: $isPrimaryEnabled, variant: .primary, action: {})
                
                VGRButton(label: "Secondary", variant: .secondary, action: {
                    isSecondaryEnabled.toggle()
                })
                
                VGRButton(label: "Secondary With Icon", icon: Image( systemName: "heart"), variant: .secondary, action: {})
                
                VGRButton(label: "Secondary disabled", icon: Image(systemName: "heart"), isEnabled: $isSecondaryEnabled, variant: .secondary, action: {})
                
                
                VGRButton(label: "Vertical with Icon", icon: Image( systemName: "heart"), variant: .vertical) {
                    isVerticalEnabled.toggle()
                }
                
                VGRButton(label: "Vertical with icon disabled", icon: Image(systemName: "heart"), isEnabled: $isVerticalEnabled, variant: .vertical) {
                    print("Tapped with icon")
                }
                
                VGRButton(label: "Tertiary", variant: .tertiary) {
                    isTertiaryEnabled.toggle()
                }
                
                VGRButton(label: "Tertiary with icon", icon: Image(systemName: "heart"), variant: .tertiary) {
                    isTertiaryEnabled.toggle()
                }
                
                VGRButton(label: "Tertiary Disabled", icon: Image(systemName: "heart"), isEnabled: $isTertiaryEnabled, variant: .tertiary) {
                    print("Tapped with icon")
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 64)
        }
    }
}
