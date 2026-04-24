import SwiftUI

/// Definierar de olika tillstånden för en `VGRFlagLabel`.
/// Varje tillstånd styr standardfärger för bakgrund och förgrund samt standardikon.
public enum VGRFlagLabelState {
    case success
    case warning
    case error
    case information

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
/// Bakgrunds- och förgrundsfärg bestäms av `state`, som även anger en standardikon.
/// Konsumenten kan valfritt ange en egen symbol som ersätter standardikonen.
///
/// ### Användning
/// ```swift
/// VGRFlagLabel("Taget", state: .success)
/// VGRFlagLabel("Varning", state: .warning)
/// VGRFlagLabel("Error", state: .error)
/// VGRFlagLabel("Neutral") // information är default
/// VGRFlagLabel("Anpassad", symbolName: "star.fill", state: .success)
/// ```
public struct VGRFlagLabel: View {
    @ScaledMetric private var iconSize: CGFloat = 10
    @ScaledMetric private var verticalSpacing: CGFloat = 2
    @ScaledMetric private var horizontalSpacing: CGFloat = .Margins.xtraSmall

    let text: LocalizedStringKey
    let symbolName: String
    let state: VGRFlagLabelState

    /// Initierar en `VGRFlagLabel`.
    /// - Parameters:
    ///   - text: Den lokaliserade texten som visas i etiketten.
    ///   - symbolName: Valfri SF Symbol att visa. Om `nil` används standardikonen för `state`.
    ///   - state: Tillståndet som styr färgsättning och standardikon. Standard är `.information`.
    public init(
        _ text: LocalizedStringKey,
        symbolName: String? = nil,
        state: VGRFlagLabelState = .information
    ) {
        self.text = text
        self.symbolName = symbolName ?? state.defaultSymbolName
        self.state = state
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
        .foregroundStyle(state.foregroundColor)
        .padding(.horizontal, horizontalSpacing)
        .padding(.vertical, verticalSpacing)
        .background(state.backgroundColor)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
    }
}

#Preview("VGRFlagLabel") {
    NavigationStack {
        VGRContainer {
            VStack(alignment: .leading, spacing: .Margins.medium) {
                VGRFlagLabel("Taget", state: .success)
                VGRFlagLabel("Varning", state: .warning)
                VGRFlagLabel("Error", state: .error)
                VGRFlagLabel("Neutral")
                VGRFlagLabel("Custom symbol", symbolName: "star.fill", state: .success)
            }
            .padding()
        }
        .navigationTitle("VGRFlagLabel")
        .navigationBarTitleDisplayMode(.inline)
    }
}
