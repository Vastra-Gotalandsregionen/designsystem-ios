import SwiftUI

struct VGRArticleTitleView: View {
    let element: VGRArticleElement

    var body: some View {
        Text(element.text)
            .font(titleFont)
            .fontWeight(titleWeight)
            .padding(.horizontal, VGRArticleSpacing.horizontal)
            .padding(.bottom, bottomPadding)
            .accessibilityAddTraits(.isHeader)
            .foregroundColor(Color.Neutral.text)
    }
    
    private var titleFont: Font {
        switch element.type {
            case .h1: return .title
            case .h2: return .title2
            case .h3: return .title3
            default: return .title3
        }
    }

    private var titleWeight: Font.Weight {
        switch element.type {
            case .h1: return .bold
            case .h2: return .semibold
            default: return .regular
        }
    }

    private var bottomPadding: CGFloat {
        switch element.type {
            case .h1: return VGRArticleSpacing.verticalMedium
            default: return VGRArticleSpacing.verticalSmall
        }
    }
}

#Preview("H1 Title") {
    VGRArticleTitleView(
        element: VGRArticleElement(
            type: .h1,
            text: "This is a Main Title (H1)",
        )
    )
}

#Preview("H2 Title") {
    VGRArticleTitleView(
        element: VGRArticleElement(
            type: .h2,
            text: "This is a Secondary Title (H2)",
        )
    )
}

#Preview("H3 Title") {
    VGRArticleTitleView(
        element: VGRArticleElement(
            type: .h3,
            text: "This is a Tertiary Title (H3)",
        )
    )
}
