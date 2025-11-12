import SwiftUI

struct VGRContentTitleView: View {
    let element: VGRContentElement

    var body: some View {
        Text(element.text)
            .font(titleFont)
            .fontWeight(titleWeight)
            .padding(.horizontal, VGRSpacing.horizontal)
            .padding(.bottom, bottomPadding)
            .foregroundColor(Color.Neutral.text)
            .accessibilityAddTraits(.isHeader)
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
            case .h1: return VGRSpacing.verticalMedium
            default: return VGRSpacing.verticalSmall
        }
    }
}

#Preview("H1 Title") {
    VGRContentTitleView(
        element: VGRContentElement(
            type: .h1,
            text: "This is a Main Title (H1)",
        )
    )
}

#Preview("H2 Title") {
    VGRContentTitleView(
        element: VGRContentElement(
            type: .h2,
            text: "This is a Secondary Title (H2)",
        )
    )
}

#Preview("H3 Title") {
    VGRContentTitleView(
        element: VGRContentElement(
            type: .h3,
            text: "This is a Tertiary Title (H3)",
        )
    )
}
