import SwiftUI

/// Definierar de olika tillstånden för en `VGRFlagLabel`.
/// Varje tillstånd styr standardfärger för bakgrund och förgrund samt standardikon.
public enum VGRFlagLabelState: String, Equatable, Identifiable, Hashable, Sendable {
    case success
    case warning
    case error
    case information

    public var id: String { self.rawValue }

    var backgroundColor: Color {
        switch self {
            case .success: return Color.Status.successSurface
            case .warning: return Color.Status.warningSurface
            case .error: return Color.Status.errorSurface
            case .information: return Color.Status.informationSurface
        }
    }

    var foregroundColor: Color {
        switch self {
            case .success: return Color.Status.successText
            case .warning: return Color.Status.warningText
            case .error: return Color.Status.errorText
            case .information: return Color.Status.informationText
        }
    }

    var defaultSymbolName: String {
        switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "xmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .information: return "minus.circle.fill"
        }
    }
}

/// En flagg-etikett som visar en text tillsammans med en symbol i en pillform.
/// Bakgrunds- och förgrundsfärg bestäms som standard av `state`, som även anger en standardikon.
/// Konsumenten kan valfritt ange en egen symbol samt egna förgrund- och bakgrundsfärger.
///
/// ### Användning
/// ```swift
/// VGRFlagLabel("Taget", state: .success)
/// VGRFlagLabel("Varning", state: .warning)
/// VGRFlagLabel("Error", state: .error)
/// VGRFlagLabel("Neutral") // information är default
/// VGRFlagLabel("Anpassad", symbolName: "star.fill", state: .success)
/// VGRFlagLabel("Lila",
///              foregroundColor: .Accent.purple,
///              backgroundColor: .Accent.purpleSurfaceMinimal)
/// ```
public struct VGRFlagLabel: View {
    @ScaledMetric private var iconSize: CGFloat = 10
    @ScaledMetric private var verticalSpacing: CGFloat = 2
    @ScaledMetric private var horizontalSpacing: CGFloat = .Margins.xtraSmall

    let text: LocalizedStringKey
    let symbolName: String
    let foregroundColor: Color
    let backgroundColor: Color

    /// Initierar en `VGRFlagLabel`.
    /// - Parameters:
    ///   - text: Den lokaliserade texten som visas i etiketten.
    ///   - symbolName: Valfri SF Symbol att visa. Om `nil` används standardikonen för `state`.
    ///   - state: Tillståndet som styr standardfärger och standardikon. Standard är `.information`.
    ///   - foregroundColor: Valfri förgrundsfärg som ersätter standardfärgen för `state`.
    ///   - backgroundColor: Valfri bakgrundsfärg som ersätter standardfärgen för `state`.
    public init(
        _ text: LocalizedStringKey,
        symbolName: String? = nil,
        state: VGRFlagLabelState = .information,
        foregroundColor: Color? = nil,
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.symbolName = symbolName ?? state.defaultSymbolName
        self.foregroundColor = foregroundColor ?? state.foregroundColor
        self.backgroundColor = backgroundColor ?? state.backgroundColor
    }

    public var body: some View {
        HStack(alignment: .center, spacing: verticalSpacing) {
            Image(systemName: symbolName)
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .accessibilityHidden(true)

            Text(text)
                .font(.captionSemibold)
                .lineLimit(1)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, horizontalSpacing)
        .padding(.vertical, verticalSpacing)
        .background(backgroundColor)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
    }
}

#Preview("VGRFlagLabel") {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "Status variants") {
                VGRFlagLabel("Taget", state: .success)
                VGRFlagLabel("Varning", state: .warning)
                VGRFlagLabel("Error", state: .error)
                VGRFlagLabel("Neutral")
                VGRFlagLabel("Custom symbol", symbolName: "star.fill", state: .success)
            }

            VGRSection(header: "Custom colors") {
                VGRFlagLabel("Purple",
                             symbolName: "arrowshape.up.fill",
                             foregroundColor: .Accent.purple,
                             backgroundColor: .Accent.purpleSurfaceMinimal)
                VGRFlagLabel("Cyan",
                             symbolName: "arrowshape.down.fill",
                             foregroundColor: .Accent.cyan,
                             backgroundColor: .Accent.cyanSurfaceMinimal)
            }
        }
        .navigationTitle("VGRFlagLabel")
        .navigationBarTitleDisplayMode(.inline)
    }
}
