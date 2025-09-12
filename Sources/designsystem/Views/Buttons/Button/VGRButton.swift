import SwiftUI

/// Ett protokoll som definierar en knappvariants stil.
/// Varje typ som implementerar detta protokoll tillhandahåller en anpassad SwiftUI-vy baserat på given konfiguration.
public protocol VGRButtonVariantProtocol {
    associatedtype Body: View
    func makeBody(configuration: VGRButton.Configuration) -> Body
    
    typealias Configuration = VGRButton.Configuration
}

/// Enum som representerar tillgängliga visuella stilar (varianter) för en `VGRButton`.
public enum VGRButtonVariant {
    case primary
    case secondary
    case vertical
    case tertiary
    case listRow
    case listRowDestructive
    
    /// Returnerar en konkret implementation av `VGRButtonVariantProtocol` baserat på enum-fallet.
    func resolve() -> any VGRButtonVariantProtocol {
        switch self {
        case .primary:             return PrimaryButtonStyle()
        case .secondary:           return SecondaryButtonVariant()
        case .vertical:            return VerticalButtonVariant()
        case .tertiary:            return TertiaryButtonVariant()
        case .listRow:             return ListRowButtonVariant(intent: .enable)
        case .listRowDestructive:  return ListRowButtonVariant(intent: .destructive)
        }
    }
}

/// En konfigurerbar knappkomponent som stödjer olika stilar (varianter), valfria ikoner, laddningstillstånd och tillgänglighetsfunktioner.
public struct VGRButton: View {
    
    /// Innehåller konfigurationsdetaljer för att rendera en `VGRButton`, inklusive label, ikon, tillstånd och åtgärd.
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
    
    /// Skapar en `VGRButton`-instans.
    /// - Parameters:
    ///   - label: Knappens textetikett.
    ///   - icon: En valfri ikon som visas före etiketten.
    ///   - isEnabled: En binding som styr om knappen är aktiv.
    ///   - isLoading: En binding som styr om knappen visar laddning.
    ///   - accessibilityHint: En tillgänglighetshjälptext som beskriver knappens syfte.
    ///   - variant: Knappens visuella variant.
    ///   - action: Closure som körs när knappen trycks.
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
    
    /// Returnerar den stylade knappvyn genom att delegera till den valda varianten.
    public var body: some View {
        AnyView(variant.makeBody(configuration: configuration))
            .accessibilityHint(configuration.accessibilityHint)
    }
}

public struct PrimaryButtonStyle: VGRButtonVariantProtocol {
    /// En primär stil knapp.
    /// - Note: Använd denna stil för huvudsakliga åtgärder med framträdande utseende.
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
    /// En sekundär stil knapp.
    /// - Note: Använd denna stil för sekundära åtgärder som är mindre framträdande.
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
    /// En vertikal stil knapp.
    /// - Note: Använd denna stil för knappar som arrangerar innehåll vertikalt, lämplig för specifika layouter.
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
    /// En tertiär stil knapp.
    /// - Note: Använd denna stil för mindre betonade åtgärder, ofta använda tillsammans med primära och sekundära knappar.
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

/// En list-rad stil knapp.
/// - Note: Använd denna variant i listor, formulär eller tabeller där en rad ska agera som en tryckbar åtgärd.
public struct ListRowButtonVariant: VGRButtonVariantProtocol {
    public enum Intent { case enable, destructive }
    let intent: Intent
    
    init(intent: Intent = .enable) {
        self.intent = intent
    }
    
    public func makeBody(configuration: VGRButton.Configuration) -> some View {
        let tint: Color = (intent == .destructive) ? Color.Status.errorText : Color.Primary.action
        
        return Button(action: configuration.action) {
            ZStack {
                HStack(spacing: 8) {
                    if let icon = configuration.icon {
                        icon.resizable().frame(width: 16, height: 16).accessibilityHidden(true)
                    }
                    Text(configuration.label).font(.headline)
                }
                .opacity(configuration.isLoading ? 0 : 1)
                
                ProgressView()
                    .tint(tint)
                    .opacity(configuration.isLoading ? 1 : 0)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(tint)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.Elevation.elevation1)
            .cornerRadius(16)
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
                
                VGRButton(
                    label: "Lägg till läkemedel",
                    icon: Image(systemName: "pills.circle"),
                    variant: .listRow) {
                        print("Beepboop")
                    }
                
                VGRButton(
                    label: "Ta bort något",
                    icon: Image(systemName: "pills.circle"),
                    variant: .listRowDestructive) {
                        print("Beepboop")
                    }
                
                VGRButton(label: "Primär", action: {
                    isPrimaryEnabled.toggle()
                })
                
                VGRButton(label: "Primär med ikon", icon: Image(systemName: "heart"), variant: .primary) {
                    isLoading.toggle()
                }
                
                VGRButton(label: "Primär inaktiverad", icon: Image(systemName: "heart"), isEnabled: $isPrimaryEnabled, variant: .primary, action: {})
                
                VGRButton(label: "Primär laddning", icon: Image(systemName: "heart"), isLoading: $isLoading, variant: .primary, action: {
                    isLoading.toggle()
                })
                
                VGRButton(label: "Sekundär", variant: .secondary, action: {
                    isSecondaryEnabled.toggle()
                })
                
                VGRButton(label: "Sekundär med ikon", icon: Image(systemName: "heart"), variant: .secondary, action: {})
                
                VGRButton(label: "Sekundär inaktiverad", icon: Image(systemName: "heart"), isEnabled: $isSecondaryEnabled, variant: .secondary, action: {})
                
                VGRButton(label: "Sekundär laddning", icon: Image(systemName: "heart"), isLoading: $isLoading, variant: .secondary, action: {
                    isLoading.toggle()
                })
                
                VGRButton(label: "Vertikal med ikon", icon: Image(systemName: "heart"), variant: .vertical) {
                    isVerticalEnabled.toggle()
                }
                
                VGRButton(label: "Vertikal med ikon inaktiverad", icon: Image(systemName: "heart"), isEnabled: $isVerticalEnabled, variant: .vertical) {
                    print("Tryckt med ikon")
                }
                
                VGRButton(label: "Vertikal laddning", icon: Image(systemName: "heart"), isLoading: $isLoading, variant: .vertical) {
                    print("Tryckt med ikon")
                }
                
                VGRButton(label: "Tertiär", variant: .tertiary) {
                    isTertiaryEnabled.toggle()
                }
                
                VGRButton(label: "Tertiär med ikon", icon: Image(systemName: "heart"), variant: .tertiary) {
                    isTertiaryEnabled.toggle()
                }
                
                VGRButton(label: "Tertiär inaktiverad", icon: Image(systemName: "heart"), isEnabled: $isTertiaryEnabled, variant: .tertiary) {
                    print("Tryckt med ikon")
                }
                
                VGRButton(label: "Tertiär laddning", icon: Image(systemName: "heart"), isLoading: $isLoading, variant: .tertiary) {
                    print("Tryckt med ikon")
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 64)
        }
    }
}
