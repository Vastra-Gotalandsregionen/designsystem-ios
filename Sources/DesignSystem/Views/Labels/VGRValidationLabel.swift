import SwiftUI

/// En valideringsetikett som visar ett textmeddelande med ett valfritt varningsläge.
/// I standardläge visas texten i neutral stil. När `isWarning` är `true` visas en varningsikon
/// och texten färgas i `warningColor` (standard `Color.Status.errorText`) för att uppmärksamma
/// användaren på ett valideringsfel. Använd `warningColor` när varningen i sammanhanget
/// uttrycker en uppmaning snarare än ett fel — t.ex. för att matcha en omslutande
/// ``VGRList`` med en annan `borderColor`.
///
/// ### Användning
/// ```swift
/// // Standardläge — informativ text
/// VGRValidationLabel("Välj minst ett alternativ")
///
/// // Varningsläge — valideringsfel
/// VGRValidationLabel("Välj minst ett alternativ", isWarning: true)
///
/// // Varningsläge med anpassad färg — uppmaning snarare än fel
/// VGRValidationLabel("Välj en annan tid",
///                    isWarning: true,
///                    warningColor: Color.Primary.action)
/// ```
public struct VGRValidationLabel: View {
    let text: LocalizedStringKey
    let isWarning: Bool
    let warningColor: Color

    /// Initierar en `VGRValidationLabel` med angiven text och valfritt varningsläge.
    /// - Parameters:
    ///   - text: Den lokaliserade texten som visas i etiketten.
    ///   - isWarning: Anger om etiketten ska visas i varningsläge med felstil och ikon. Standard är `false`.
    ///   - warningColor: Färgen som används för text och ikon när `isWarning` är `true`.
    ///     Standard är `Color.Status.errorText`.
    public init(_ text: LocalizedStringKey,
                isWarning: Bool = false,
                warningColor: Color = Color.Status.errorText) {
        self.text = text
        self.isWarning = isWarning
        self.warningColor = warningColor
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill")
                .isVisible(isWarning)
                .accessibilityHidden(!isWarning)
                .accessibilityLabel("general.warning".localizedBundle)

            Text(text)
                .maxLeading()
        }
        .font(.footnoteRegular)
        .contentShape(Rectangle())
        .foregroundStyle(isWarning ? warningColor : Color.Neutral.text)
        .accessibilityElement(children: .combine)

    }
}

#Preview("VGRValidationLabel") {
    VStack(spacing: .Margins.medium) {
        VGRValidationLabel("Default state — no warning")
        VGRValidationLabel("Warning state — validation failed", isWarning: true)
        VGRValidationLabel("Warning state — custom color",
                           isWarning: true,
                           warningColor: Color.Primary.action)
    }
    .padding()
}
