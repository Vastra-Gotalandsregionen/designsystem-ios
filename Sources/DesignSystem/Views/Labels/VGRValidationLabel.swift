import SwiftUI

/// En valideringsetikett som visar ett textmeddelande med ett valfritt varningsläge.
/// I standardläge visas texten i neutral stil. När `isWarning` är `true` visas en varningsikon
/// och texten färgas i felstil för att uppmärksamma användaren på ett valideringsfel.
///
/// ### Användning
/// ```swift
/// // Standardläge — informativ text
/// VGRValidationLabel("Välj minst ett alternativ")
///
/// // Varningsläge — valideringsfel
/// VGRValidationLabel("Välj minst ett alternativ", isWarning: true)
/// ```
public struct VGRValidationLabel: View {
    let text: LocalizedStringKey
    let isWarning: Bool

    /// Initierar en `VGRValidationLabel` med angiven text och valfritt varningsläge.
    /// - Parameters:
    ///   - text: Den lokaliserade texten som visas i etiketten.
    ///   - isWarning: Anger om etiketten ska visas i varningsläge med felstil och ikon. Standard är `false`.
    public init(_ text: LocalizedStringKey, isWarning: Bool = false) {
        self.text = text
        self.isWarning = isWarning
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill")
                .isVisible(isWarning)

            Text(text)
                .maxLeading()
        }
        .font(.footnoteRegular)
        .foregroundStyle(isWarning ? Color.Status.errorText : Color.Neutral.text)
    }
}

#Preview("VGRValidationLabel") {
    VStack(spacing: .Margins.medium) {
        VGRValidationLabel("Default state — no warning")
        VGRValidationLabel("Warning state — validation failed", isWarning: true)
    }
    .padding()
}
