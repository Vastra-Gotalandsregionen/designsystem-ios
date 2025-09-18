import SwiftUI

struct VGRArticleTextView: View {
    let element: VGRArticleElement

    var body: some View {
        Text(element.text)
            .font(textFont)
            .fontWeight(textWeight)
            .padding(.horizontal, VGRArticleSpacing.horizontal)
            .padding(.bottom, VGRArticleSpacing.verticalXLarge)
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
    VGRArticleTextView(
        element: VGRArticleElement(
            type: .subhead,
            text: "This is a subheading with semibold weight",
        )
    )
}

#Preview("Body Text") {
    VGRArticleTextView(
        element: VGRArticleElement(
            type: .body,
            text: "This is body text content that would appear in an article. It uses regular font weight and loose line spacing for optimal readability.",
        )
    )
}
