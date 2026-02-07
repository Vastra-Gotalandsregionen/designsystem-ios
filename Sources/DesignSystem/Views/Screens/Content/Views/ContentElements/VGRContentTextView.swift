import SwiftUI

struct VGRContentTextView: View {
    let element: VGRContentElement

    var body: some View {
        Text(element.text)
            .font(textFont)
            .fontWeight(textWeight)
            .padding(.horizontal, VGRSpacing.horizontal)
            .padding(.bottom, VGRSpacing.verticalXLarge)
            .foregroundColor(Color.Neutral.text)
            .accessibilityTextContentType(.narrative)
            .accessibilityAddTraits(.isStaticText)
    }

    private var textFont: Font {
        switch element.type {
            case .footnote:  return Font.footnote.leading(.loose)
            case .subhead: return Font.headline.leading(.loose)
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

#Preview {
    ScrollView {
        VStack {
            VStack(alignment: .leading) {
                VGRContentTextView(
                    element: VGRContentElement(
                        type: .subhead,
                        text: "This is a subheading with semibold weight",
                    )
                )
                .maxLeading()

                VGRContentTextView(
                    element: VGRContentElement(
                        type: .body,
                        text: "This is body text content that would appear in an article. It uses regular font weight and loose line spacing for optimal readability.",
                    )
                )
                .maxLeading()

                VGRContentTextView(
                    element: VGRContentElement(
                        type: .footnote,
                        text: "This is footnote text content that would appear in an article. It uses footnote font weight and loose line spacing for optimal readability.",
                    )
                )
                .maxLeading()
            }
        }
        .padding()
    }
}
