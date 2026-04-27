import SwiftUI


// MARK: - Protocol

/// Protokollet som varje variant implementerar. En variant är en typ
/// som tar en ``VGRButtonV2Configuration`` och returnerar en vy.
///
/// Designsystemet levererar ett inbyggt set av varianter (se
/// ``VGRButtonV2Variant``), men externa moduler kan skapa egna genom
/// att conforma till protokollet och skicka in sin typ via init-varianten
/// som tar `any VGRButtonV2VariantProtocol`.
public protocol VGRButtonV2VariantProtocol {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body

    typealias Configuration = VGRButtonV2Configuration
}

// MARK: - Variant enum

/// De inbyggda designsystem-godkända varianterna. Varje case resolveras
/// till en konkret typ som implementerar ``VGRButtonV2VariantProtocol``.
public enum VGRButtonV2Variant {
    /// Huvudåtgärd — fylld, framträdande.
    case primary

    /// Huvudåtgärd på färgad yta — inverterade färger.
    case primaryInverted

    /// Alternativ åtgärd — konturstil.
    case secondary

    /// Alternativ åtgärd på färgad yta — inverterade färger.
    case secondaryInverted

    /// Inline-åtgärd i en list-kort (t.ex. "+ Lägg till ny" i en ``VGRList``).
    case inline

    /// Destruktiv åtgärd.
    case destructive

    /// Inline-destruktiv åtgärd i en list-kort.
    case destructiveInline

    func resolve() -> any VGRButtonV2VariantProtocol {
        switch self {
            case .primary:           return VGRButtonV2PrimaryVariant()
            case .primaryInverted:   return VGRButtonV2PrimaryInvertedVariant()
            case .secondary:         return VGRButtonV2SecondaryVariant()
            case .secondaryInverted: return VGRButtonV2SecondaryInvertedVariant()
            case .inline:            return VGRButtonV2InlineVariant()
            case .destructive:       return VGRButtonV2DestructiveVariant()
            case .destructiveInline: return VGRButtonV2DestructiveInlineVariant()
        }
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
/// VGRButtonV2("Spara") { save() }
///
/// VGRButtonV2("Avbryt", variant: .secondary) { cancel() }
///
/// VGRButtonV2("Lägg till ny", variant: .inline) {
///     addNew()
/// } icon: {
///     Image(systemName: "plus.circle.fill")
///         .foregroundStyle(Color.Status.successText)
/// }
///
/// // Med en egen variant som implementerar VGRButtonV2VariantProtocol:
/// VGRButtonV2("Special", customVariant: MyCustomVariant()) { ... }
/// ```
///
/// - Note: Under utveckling. Kommer att ersätta ``VGRButton`` när migreringen är klar.
public struct VGRButtonV2<Icon: View>: View {

    private let label: String
    private let variant: any VGRButtonV2VariantProtocol
    @Binding private var isEnabled: Bool
    private let fullWidth: Bool
    private let size: VGRButtonV2Size
    private let accessibilityHint: String
    private let systemImage: String?
    private let action: () -> Void
    private let icon: Icon

    /// Skapar en knapp med en inbyggd variant.
    /// - Parameters:
    ///   - label: Knappens textetikett.
    ///   - variant: Visuell variant. Defaultar till `.primary`.
    ///   - size: Storleksskala. Defaultar till `.medium`.
    ///   - isEnabled: Binding som styr om knappen är klickbar.
    ///   - fullWidth: Om `true` fyller knappen hela tillgängliga bredden.
    ///     Om `false` hugger knappen sitt innehåll. Defaultar till `true`.
    ///   - accessibilityHint: VoiceOver-hint som beskriver åtgärden.
    ///   - systemImage: Valfritt SF Symbol-namn. Om satt ersätter det
    ///     `icon`-vybyggaren och skalas enligt `size.iconSize`.
    ///   - action: Closure som körs när knappen trycks.
    ///   - icon: Valfri ikon som vybyggare. Defaultar till tom vy. Ignoreras
    ///     när `systemImage` är satt.
    public init(
        _ label: String,
        variant: VGRButtonV2Variant = .primary,
        size: VGRButtonV2Size = .medium,
        isEnabled: Binding<Bool> = .constant(true),
        fullWidth: Bool = true,
        accessibilityHint: String = "",
        systemImage: String? = nil,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.label = label
        self.variant = variant.resolve()
        self._isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.size = size
        self.accessibilityHint = accessibilityHint
        self.systemImage = systemImage
        self.action = action
        self.icon = icon()
    }

    /// Skapar en knapp med en egen variant som implementerar
    /// ``VGRButtonV2VariantProtocol``. Används när anropande kod behöver
    /// en specialvariant utanför designsystemets inbyggda set.
    /// - Parameters:
    ///   - label: Knappens textetikett.
    ///   - customVariant: En instans av en typ som uppfyller
    ///     ``VGRButtonV2VariantProtocol``.
    ///   - size: Storleksskala. Defaultar till `.medium`.
    ///   - isEnabled: Binding som styr om knappen är klickbar.
    ///   - fullWidth: Om `true` fyller knappen hela tillgängliga bredden.
    ///     Om `false` omsluter knappen sitt innehåll. Defaultar till `true`.
    ///   - accessibilityHint: VoiceOver-hint som beskriver åtgärden.
    ///   - systemImage: Valfritt SF Symbol-namn. Om satt ersätter det
    ///     `icon`-vybyggaren och skalas enligt `size.iconSize`.
    ///   - action: Closure som körs när knappen trycks.
    ///   - icon: Valfri ikon som vybyggare. Defaultar till tom vy. Ignoreras
    ///     när `systemImage` är satt.
    public init(
        _ label: String,
        customVariant: any VGRButtonV2VariantProtocol,
        size: VGRButtonV2Size = .medium,
        isEnabled: Binding<Bool> = .constant(true),
        fullWidth: Bool = true,
        accessibilityHint: String = "",
        systemImage: String? = nil,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.label = label
        self.variant = customVariant
        self._isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.size = size
        self.accessibilityHint = accessibilityHint
        self.systemImage = systemImage
        self.action = action
        self.icon = icon()
    }

    private var resolvedIcon: AnyView {
        if let systemImage {
            return AnyView(
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.iconSize, height: size.iconSize)
                    .accessibilityHidden(true)
            )
        }
        return AnyView(icon)
    }

    public var body: some View {
        let configuration = VGRButtonV2Configuration(
            label: label,
            icon: resolvedIcon,
            isEnabled: isEnabled,
            fullWidth: fullWidth,
            size: size,
            accessibilityHint: accessibilityHint,
            action: action
        )
        AnyView(variant.makeBody(configuration: configuration))
            .accessibilityHint(accessibilityHint)
    }
}

// MARK: - Preview

#Preview("All variants") {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "Primary") {
                VGRButtonV2("Medium", variant: .primary, size: .medium, systemImage: "tray.and.arrow.down") { }
                VGRButtonV2("Small",  variant: .primary, size: .small,  systemImage: "tray.and.arrow.down") { }
            }

            VGRSection(header: "Secondary") {
                VGRButtonV2("Medium", variant: .secondary, size: .medium, systemImage: "xmark") { }
                VGRButtonV2("Small",  variant: .secondary, size: .small,  systemImage: "xmark") { }
            }

            VGRSection(header: "Inline") {
                VGRButtonV2("Medium", variant: .inline, size: .medium, systemImage: "plus.circle.fill") { }
                VGRButtonV2("Small",  variant: .inline, size: .small,  systemImage: "plus.circle.fill") { }
            }

            VGRSection(header: "Destructive") {
                VGRButtonV2("Medium", variant: .destructive, size: .medium, systemImage: "trash") { }
                VGRButtonV2("Small",  variant: .destructive, size: .small,  systemImage: "trash") { }
            }

            VGRSection(header: "DestructiveInline") {
                VGRButtonV2("Medium", variant: .destructiveInline, size: .medium, systemImage: "trash") { }
                VGRButtonV2("Small",  variant: .destructiveInline, size: .small,  systemImage: "trash") { }
            }

            VGRShape(backgroundColor: Color.Primary.action) {
                VGRSection(header: "PrimaryInverted") {
                    VGRButtonV2("Medium", variant: .primaryInverted, size: .medium, systemImage: "tray.and.arrow.down") { }
                    VGRButtonV2("Small",  variant: .primaryInverted, size: .small,  systemImage: "tray.and.arrow.down") { }
                }

                VGRSection(header: "SecondaryInverted") {
                    VGRButtonV2("Medium", variant: .secondaryInverted, size: .medium, systemImage: "xmark") { }
                    VGRButtonV2("Small",  variant: .secondaryInverted, size: .small,  systemImage: "xmark") { }
                }
            }
        }
        .navigationTitle("VGRButtonV2")
        .navigationBarTitleDisplayMode(.inline)
    }
}
