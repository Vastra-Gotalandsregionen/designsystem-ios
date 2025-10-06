import SwiftUI

struct VGRContentTextView: View {
    let element: VGRContentElement

    var body: some View {
        Text(element.text)
            .font(textFont)
            .fontWeight(textWeight)
            .padding(.horizontal, VGRSpacing.horizontal)
            .padding(.bottom, VGRSpacing.verticalXLarge)
            .accessibilityAddTraits(.isStaticText)
            .foregroundColor(Color.Neutral.text)
            .accessibilityTextContentType(.narrative)
    }

    private var textFont: Font {
        switch element.type {
            case .subhead: return Font.headline.leading(.loose)
            case .body: return Font.body.leading(.loose)
            default: return Font.body.leading(.loose)
        }
    }

    private var textWeight: Font.Weight? {
        switch element.type {
            case .subhead: return .semibold
            default: return nil
        }
    }
}

#Preview("Subhead Text") {
    VGRContentTextView(
        element: VGRContentElement(
            type: .subhead,
            text: "This is a subheading with semibold weight",
        )
    )
}

#Preview("Body Text") {
    VGRContentTextView(
        element: VGRContentElement(
            type: .body,
            text: "This is body text content that would appear in an article. It uses regular font weight and loose line spacing for optimal readability.",
        )
    )
}
