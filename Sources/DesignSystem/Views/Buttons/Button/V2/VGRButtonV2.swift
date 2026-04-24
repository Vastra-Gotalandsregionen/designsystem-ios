import SwiftUI

// MARK: - Size

/// Storlek på knappen. Påverkar font, padding och ikonens storlek.
/// Alla varianter respekterar samma storleksskala.
public enum VGRButtonV2Size: Equatable, Hashable, Sendable {
    case medium
    case small

    public var font: Font {
        switch self {
            case .medium: return .bodyRegular
            case .small:  return .subheadline
        }
    }

    public var padding: CGFloat {
        switch self {
            case .medium: return .Margins.medium
            case .small:  return .Margins.large
        }
    }

    public var verticalPadding: CGFloat {
        switch self {
            case .medium: return .Margins.small
            case .small:  return .Margins.xtraSmall
        }
    }

    public var iconSize: CGFloat {
        switch self {
            case .medium: return 20
            case .small:  return 14
        }
    }
}

// MARK: - Configuration

/// Datan som skickas till en variant när den ska rendera knappen.
/// Icon är typraderad (`AnyView`) så alla varianter kan ta emot samma
/// configuration oavsett vilken vy anroparen har skickat in.
public struct VGRButtonV2Configuration {
    public let label: String
    public let icon: AnyView
    public let isEnabled: Bool
    public let fullWidth: Bool
    public let size: VGRButtonV2Size
    public let accessibilityHint: String
    public let action: () -> Void

    public init(
        label: String,
        icon: AnyView,
        isEnabled: Bool,
        fullWidth: Bool = true,
        size: VGRButtonV2Size = .medium,
        accessibilityHint: String,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.size = size
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
}

// MARK: - Layout helper

/// Applicerar `.frame(maxWidth: .infinity, alignment:)` endast när
/// `isFullWidth` är `true`. Används av de inbyggda varianterna för att
/// respektera ``VGRButtonV2Configuration/fullWidth``.
extension View {
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
    ///     Om `false` hugger knappen sitt innehåll. Defaultar till `true`.
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
