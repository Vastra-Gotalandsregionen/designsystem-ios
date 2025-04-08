import SwiftUI

/// A protocol defining a button variant's style.
/// Each conforming type provides a custom SwiftUI view based on the provided configuration.
public protocol VGRButtonVariantProtocol {
    associatedtype Body: View
    func makeBody(configuration: VGRButton.Configuration) -> Body
    
    typealias Configuration = VGRButton.Configuration
}

/// Enum representing available visual styles (variants) for a `VGRButton`.
public enum VGRButtonVariant {
    case primary
    case secondary
    case vertical
    case tertiary
    
    /// Resolves the enum case to a concrete implementation of `VGRButtonVariantProtocol`.
    func resolve() -> any VGRButtonVariantProtocol {
        switch self {
        case .primary:
            return PrimaryButtonStyle()
        case .secondary:
            return SecondaryButtonVariant()
        case .vertical:
            return VerticalButtonVariant()
        case .tertiary:
            return TertiaryButtonVariant()
        }
    }
}

/// A configurable button component supporting different styles (variants), optional icons, loading state, and accessibility features.
public struct VGRButton: View {
    
    /// Stores configuration details for rendering a `VGRButton`, including label, icon, state, and action.
    public struct Configuration {
        let label: String
        let icon: Image?
        let isEnabled: Bool
        let isLoading: Bool
        let accessibilityHint: String
        let action: () -> Void
    }
    
    private let configuration: Configuration
    private var variant: any VGRButtonVariantProtocol
    
    /// Creates a `VGRButton` instance.
    /// - Parameters:
    ///   - label: The button's text label.
    ///   - icon: An optional icon shown before the label.
    ///   - isEnabled: A binding to control the button's enabled state.
    ///   - isLoading: A binding to control the button's loading state.
    ///   - accessibilityHint: An accessibility hint describing the button's purpose.
    ///   - variant: The button's visual variant.
    ///   - action: The closure executed when the button is tapped.
    public init(
        label: String,
        icon: Image? = nil,
        isEnabled: Binding<Bool> = .constant(true),
        isLoading: Binding<Bool> = .constant(false),
        accessibilityHint: String = "",
        variant: VGRButtonVariant = .primary,
        action: @escaping () -> Void
    ) {
        self.configuration = Configuration(
            label: label,
            icon: icon,
            isEnabled: isEnabled.wrappedValue,
            isLoading: isLoading.wrappedValue,
            accessibilityHint: accessibilityHint,
            action: action
        )
        self.variant = variant.resolve()
    }
    
    /// Returns the styled button view by delegating to the selected variant.
    public var body: some View {
        AnyView(variant.makeBody(configuration: configuration))
            .accessibilityHint(configuration.accessibilityHint)
    }
}

public struct PrimaryButtonStyle: VGRButtonVariantProtocol {
    /// A primary style button.
    /// - Note: Use this style for the main action button with a prominent appearance.
    public func makeBody(configuration: VGRButton.Configuration) -> some View {
        Button(action: configuration.action) {
            ZStack {
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
                .opacity(configuration.isLoading ? 0 : 1)

                ProgressView()
                    .tint(Color.Neutral.textInverted)
                    .opacity(configuration.isLoading ? 1 : 0)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Color.Neutral.textInverted)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.Primary.action)
            .cornerRadius(16)
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .disabled(!configuration.isEnabled || configuration.isLoading)
    }
}

public struct SecondaryButtonVariant: VGRButtonVariantProtocol {
    /// A secondary style button.
    /// - Note: Use this style for secondary actions that are less prominent.
    public func makeBody(configuration: VGRButton.Configuration) -> some View {
        Button(action: configuration.action) {
            ZStack {
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
                .opacity(configuration.isLoading ? 0 : 1)
                
                ProgressView()
                    .tint(Color.Primary.action)
                    .opacity(configuration.isLoading ? 1 : 0)
                    .accessibilityHidden(true)
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
        .disabled(!configuration.isEnabled || configuration.isLoading)
    }
}

public struct VerticalButtonVariant: VGRButtonVariantProtocol {
    /// A vertical style button.
    /// - Note: Use this style for buttons that arrange content vertically, suitable for specific layouts.
    public func makeBody(configuration: VGRButton.Configuration) -> some View {
        Button(action: configuration.action) {
            ZStack {
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
                .opacity(configuration.isLoading ? 0 : 1)
                
                ProgressView()
                    .tint(Color.Neutral.text)
                    .opacity(configuration.isLoading ? 1 : 0)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Color.Neutral.text)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.Primary.blueSurfaceMinimal)
            .cornerRadius(16)
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .disabled(!configuration.isEnabled || configuration.isLoading)
    }
}

public struct TertiaryButtonVariant: VGRButtonVariantProtocol {
    /// A tertiary style button.
    /// - Note: Use this style for less emphasized actions, often used alongside primary and secondary buttons.
    public func makeBody(configuration: VGRButton.Configuration) -> some View {
        Button(action: configuration.action) {
            ZStack {
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
                .opacity(configuration.isLoading ? 0 : 1)
                
                ProgressView()
                    .tint(Color.Primary.action)
                    .opacity(configuration.isLoading ? 1 : 0)
                    .accessibilityHidden(true)
            }
            .foregroundColor(Color.Primary.action)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.Primary.blueSurfaceMinimal)
            .cornerRadius(12)
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .disabled(!configuration.isEnabled || configuration.isLoading)
    }
}

#Preview {
    
    @Previewable @State var isPrimaryEnabled: Bool = false
    @Previewable @State var isSecondaryEnabled: Bool = false
    @Previewable @State var isVerticalEnabled: Bool = false
    @Previewable @State var isTertiaryEnabled: Bool = false
    @Previewable @State var isLoading: Bool = true
    
    ScrollView {
        VGRShape(backgroundColor: Color.Elevation.background) {
            VStack(spacing: 16) {
                VGRButton(label: "Primary", action: {
                    isPrimaryEnabled.toggle()
                })
                
                VGRButton(label: "Primary With Icon", icon: Image(systemName: "heart"), variant: .primary) {
                    isLoading.toggle()
                }
                
                VGRButton(label: "Primary Disabled", icon: Image(systemName: "heart"), isEnabled: $isPrimaryEnabled, variant: .primary, action: {})
                
                VGRButton(label: "Primary Loading", icon: Image(systemName: "heart"), isLoading: $isLoading, variant: .primary, action: {
                    isLoading.toggle()
                })
                
                VGRButton(label: "Secondary", variant: .secondary, action: {
                    isSecondaryEnabled.toggle()
                })
                
                VGRButton(label: "Secondary With Icon", icon: Image( systemName: "heart"), variant: .secondary, action: {})
                
                VGRButton(label: "Secondary disabled", icon: Image(systemName: "heart"), isEnabled: $isSecondaryEnabled, variant: .secondary, action: {})
                
                VGRButton(label: "Secondary loading", icon: Image(systemName: "heart"), isLoading: $isLoading, variant: .secondary, action: {
                    isLoading.toggle()
                })
                
                VGRButton(label: "Vertical with Icon", icon: Image( systemName: "heart"), variant: .vertical) {
                    isVerticalEnabled.toggle()
                }
                
                VGRButton(label: "Vertical with icon disabled", icon: Image(systemName: "heart"), isEnabled: $isVerticalEnabled, variant: .vertical) {
                    print("Tapped with icon")
                }
                
                VGRButton(label: "Vertical Loading", icon: Image(systemName: "heart"), isLoading: $isLoading, variant: .vertical) {
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
                
                VGRButton(label: "Tertiary Loading", icon: Image(systemName: "heart"), isLoading: $isLoading, variant: .tertiary) {
                    print("Tapped with icon")
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 64)
        }
    }
}
