import SwiftUI

// MARK: - Configuration

/// Datan som skickas till en variant när den ska rendera knappen.
/// Icon är typraderad (`AnyView`) så alla varianter kan ta emot samma
/// configuration oavsett vilken vy anroparen har skickat in.
public struct VGRNewButtonConfiguration {
    public let label: String
    public let icon: AnyView
    public let isEnabled: Bool
    public let fullWidth: Bool
    public let accessibilityHint: String
    public let action: () -> Void

    public init(
        label: String,
        icon: AnyView,
        isEnabled: Bool,
        fullWidth: Bool = true,
        accessibilityHint: String,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
}

// MARK: - Layout helper

/// Applicerar `.frame(maxWidth: .infinity, alignment:)` endast när
/// `isFullWidth` är `true`. Används av de inbyggda varianterna för att
/// respektera ``VGRNewButtonConfiguration/fullWidth``.
fileprivate extension View {
    @ViewBuilder
    func applyFullWidth(_ isFullWidth: Bool, alignment: Alignment = .center) -> some View {
        if isFullWidth {
            frame(maxWidth: .infinity, alignment: alignment)
        } else {
            self
        }
    }
}

// MARK: - Protocol

/// Protokollet som varje variant implementerar. En variant är en typ
/// som tar en ``VGRNewButtonConfiguration`` och returnerar en vy.
///
/// Designsystemet levererar ett inbyggt set av varianter (se
/// ``VGRNewButtonVariant``), men externa moduler kan skapa egna genom
/// att conforma till protokollet och skicka in sin typ via init-varianten
/// som tar `any VGRNewButtonVariantProtocol`.
public protocol VGRNewButtonVariantProtocol {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body

    typealias Configuration = VGRNewButtonConfiguration
}

// MARK: - Variant enum

/// De inbyggda designsystem-godkända varianterna. Varje case resolveras
/// till en konkret typ som implementerar ``VGRNewButtonVariantProtocol``.
public enum VGRNewButtonVariant {
    /// Huvudåtgärd — fylld, framträdande.
    case primary

    /// Alternativ åtgärd — konturstil.
    case secondary

    /// Lågbetonad åtgärd — diskret bakgrund.
    case tertiary

    /// Inline-åtgärd i en list-kort (t.ex. "+ Lägg till ny" i en ``VGRList``).
    case quaternary

    /// Inline-destruktiv åtgärd i en list-kort.
    case destructive

    func resolve() -> any VGRNewButtonVariantProtocol {
        switch self {
        case .primary:     return VGRNewPrimaryVariant()
        case .secondary:   return VGRNewSecondaryVariant()
        case .tertiary:    return VGRNewTertiaryVariant()
        case .quaternary:  return VGRNewQuaternaryVariant()
        case .destructive: return VGRNewDestructiveVariant()
        }
    }
}

// MARK: - Built-in variants

/// Primär knappvariant — fylld actionfärg, centrerad headline, fyller bredden.
public struct VGRNewPrimaryVariant: VGRNewButtonVariantProtocol {
    public init() {}


    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon
                    .accessibilityHidden(true)
                Text(configuration.label)
                    .font(.headline)
            }
            .foregroundStyle(configuration.isEnabled ?
                             Color.Neutral.textInverted :
                                Color.Neutral.disabledVariant)
            .padding(.Margins.medium)
            .applyFullWidth(configuration.fullWidth)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(configuration.isEnabled ? Color.Primary.action : Color.Neutral.disabled)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        }
        .buttonStyle(.plain)
        .allowsHitTesting(configuration.isEnabled)
    }
}

/// Sekundär knappvariant — outlined actionfärg, centrerad headline.
public struct VGRNewSecondaryVariant: VGRNewButtonVariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon
                    .accessibilityHidden(true)

                Text(configuration.label)
                    .font(.headline)
            }
            .foregroundStyle(Color.Primary.action)
            .padding(.Margins.medium)
            .applyFullWidth(configuration.fullWidth)
            .overlay(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .strokeBorder(Color.Primary.action, lineWidth: 2)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!configuration.isEnabled)
    }
}

/// Tertiär knappvariant — diskret bakgrundsfyllnad, actionfärg på texten.
public struct VGRNewTertiaryVariant: VGRNewButtonVariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon
                    .accessibilityHidden(true)

                Text(configuration.label)
                    .font(.headline)
            }
            .foregroundStyle(Color.Primary.action)
            .padding(.Margins.medium)
            .applyFullWidth(configuration.fullWidth)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(Color.Primary.blueSurfaceMinimal)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!configuration.isEnabled)
    }
}

/// Quaternär knappvariant — inline-åtgärd i en lista. Leading-alignad
/// bodyRegular, elevation1-bakgrund. Callern styr ikonens färg.
public struct VGRNewQuaternaryVariant: VGRNewButtonVariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon.accessibilityHidden(true)
                Text(configuration.label)
                    .font(.bodyRegular)
                    .foregroundStyle(Color.Neutral.text)
            }
            .foregroundStyle(Color.Primary.action)
            .padding(.Margins.medium)
            .applyFullWidth(configuration.fullWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(Color.Elevation.elevation1)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!configuration.isEnabled)
    }
}

/// Destruktiv knappvariant — inline-åtgärd i en lista med röd text.
/// Semantiken "användaren är på väg att ta bort något" är inbyggd.
public struct VGRNewDestructiveVariant: VGRNewButtonVariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon.accessibilityHidden(true)
                Text(configuration.label).font(.bodyRegular)
            }
            .foregroundStyle(Color.Status.errorText)
            .padding(.Margins.medium)
            .applyFullWidth(configuration.fullWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(Color.Elevation.elevation1)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!configuration.isEnabled)
    }
}

// MARK: - Button

/// En protokoll-driven, komponerbar knapp. Basen äger de gemensamma
/// mekanikerna (action, enabled-state, accessibility) och delegerar
/// allt visuellt till varianten.
///
/// Callern styr ikonens utseende eftersom `Icon` är generisk över `View`
/// — på samma sätt som ``VGRListRow``. Varianten bestämmer placering och
/// avstånd men inte storlek eller färg på själva ikonen.
///
/// ### Usage
/// ```swift
/// VGRNewButton("Spara") { save() }
///
/// VGRNewButton("Avbryt", variant: .secondary) { cancel() }
///
/// VGRNewButton("Lägg till ny", variant: .quaternary) {
///     addNew()
/// } icon: {
///     Image(systemName: "plus.circle.fill")
///         .foregroundStyle(Color.Status.successText)
/// }
///
/// // Med en egen variant som implementerar VGRNewButtonVariantProtocol:
/// VGRNewButton("Special", customVariant: MyCustomVariant()) { ... }
/// ```
///
/// - Note: Under utveckling. Namnet `VGRNewButton` är tillfälligt —
///   kommer att ersätta ``VGRButton`` när migreringen är klar.
public struct VGRNewButton<Icon: View>: View {

    private let label: String
    private let variant: any VGRNewButtonVariantProtocol
    @Binding private var isEnabled: Bool
    private let fullWidth: Bool
    private let accessibilityHint: String
    private let action: () -> Void
    private let icon: Icon

    /// Skapar en knapp med en inbyggd variant.
    /// - Parameters:
    ///   - label: Knappens textetikett.
    ///   - variant: Visuell variant. Defaultar till `.primary`.
    ///   - isEnabled: Binding som styr om knappen är klickbar.
    ///   - fullWidth: Om `true` fyller knappen hela tillgängliga bredden.
    ///     Om `false` hugger knappen sitt innehåll. Defaultar till `true`.
    ///   - accessibilityHint: VoiceOver-hint som beskriver åtgärden.
    ///   - action: Closure som körs när knappen trycks.
    ///   - icon: Valfri ikon som vybyggare. Defaultar till tom vy.
    public init(
        _ label: String,
        variant: VGRNewButtonVariant = .primary,
        isEnabled: Binding<Bool> = .constant(true),
        fullWidth: Bool = true,
        accessibilityHint: String = "",
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.label = label
        self.variant = variant.resolve()
        self._isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.accessibilityHint = accessibilityHint
        self.action = action
        self.icon = icon()
    }

    /// Skapar en knapp med en egen variant som implementerar
    /// ``VGRNewButtonVariantProtocol``. Används när anropande kod behöver
    /// en specialvariant utanför designsystemets inbyggda set.
    /// - Parameters:
    ///   - label: Knappens textetikett.
    ///   - customVariant: En instans av en typ som uppfyller
    ///     ``VGRNewButtonVariantProtocol``.
    ///   - isEnabled: Binding som styr om knappen är klickbar.
    ///   - fullWidth: Om `true` fyller knappen hela tillgängliga bredden.
    ///     Om `false` hugger knappen sitt innehåll. Defaultar till `true`.
    ///   - accessibilityHint: VoiceOver-hint som beskriver åtgärden.
    ///   - action: Closure som körs när knappen trycks.
    ///   - icon: Valfri ikon som vybyggare. Defaultar till tom vy.
    public init(
        _ label: String,
        customVariant: any VGRNewButtonVariantProtocol,
        isEnabled: Binding<Bool> = .constant(true),
        fullWidth: Bool = true,
        accessibilityHint: String = "",
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.label = label
        self.variant = customVariant
        self._isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.accessibilityHint = accessibilityHint
        self.action = action
        self.icon = icon()
    }

    public var body: some View {
        let configuration = VGRNewButtonConfiguration(
            label: label,
            icon: AnyView(icon),
            isEnabled: isEnabled,
            fullWidth: fullWidth,
            accessibilityHint: accessibilityHint,
            action: action
        )
        AnyView(variant.makeBody(configuration: configuration))
            .accessibilityHint(accessibilityHint)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var isEnabled: Bool = false

    NavigationStack {
        VGRContainer {
            VGRSection(header: "Primary") {

                VGRNewButton("Spara") { }
                VGRNewButton("Spara med ikon") { } icon: {
                    Image(systemName: "tray.and.arrow.down")
                }
                HStack {
                    VGRNewButton(isEnabled ? "Aktiverad" : "Inaktiverad",
                                 isEnabled: $isEnabled) {

                    }

                    Toggle("", isOn: $isEnabled)
                        .labelsHidden()
                }

                VGRNewButton(isEnabled ? "Aktiverad" : "Inaktiverad",
                             isEnabled: $isEnabled) {
                } icon: {
                    Image(systemName: "tray.and.arrow.down")
                }

            }

            VGRSection(header: "Secondary") {
                VGRNewButton("Avbryt", variant: .secondary) { }
                VGRNewButton("Avbryt med ikon", variant: .secondary) { } icon: {
                    Image(systemName: "xmark")
                }
            }

            VGRSection(header: "Tertiary") {
                VGRNewButton("Visa mer", variant: .tertiary) { }
            }

            VGRSection(header: "Quaternary (inline i lista)") {
                VGRList {
                    VGRListRow(title: "Morgon", subtitle: "08:00")
                    VGRListRow(title: "Kväll", subtitle: "20:00")
                }

                VGRNewButton("Lägg till ny", variant: .quaternary) { } icon: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.Status.successText)
                }
            }

            VGRSection(header: "Destructive (inline i lista)") {
                VGRList {
                    VGRListRow(title: "Morgon", subtitle: "08:00")
                }

                VGRNewButton("Ta bort", variant: .destructive) { } icon: {
                    Image(systemName: "trash")
                }
            }

            VGRSection {
                VGRNewButton(isEnabled ? "Stäng av" : "Aktivera",
                             variant: .secondary) {
                    isEnabled.toggle()
                }
            }

            VGRSection(header: "Hug content (fullWidth: false)") {
                HStack(spacing: .Margins.small) {
                    VGRNewButton("Spara",
                                 fullWidth: false) { }

                    VGRNewButton("Avbryt",
                                 variant: .secondary,
                                 fullWidth: false) { }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("VGRNewButton")
    }
}
