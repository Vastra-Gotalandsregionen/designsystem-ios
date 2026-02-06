import SwiftUI

struct VGRContentInternalLinkView: View {
    let element: VGRContentElement
    @Environment(\.dismiss) private var dismiss

    /// Maps the backgroundColor string from JSON to a SwiftUI Color
    private var mappedBackgroundColor: Color? {
        switch element.backgroundColor {
        case "redSurfaceMinimal":
            return Color.Accent.redSurfaceMinimal
        case "orangeSurfaceMinimal":
            return Color.Accent.orangeSurfaceMinimal
        case "blueSurfaceMinimal":
            return Color.Primary.blueSurfaceMinimal
        case "greenSurfaceMinimal":
            return Color.Accent.greenSurfaceMinimal
        default:
            return nil
        }
    }

    var body: some View {
        if let internalArticle = element.internalArticle {
            if let bgColor = mappedBackgroundColor {
                VGRShape(backgroundColor: bgColor) {
                    internalLinkContent(for: internalArticle)
                }
                .padding(.top, VGRSpacing.verticalMedium)
            } else {
                internalLinkContent(for: internalArticle)
                    .padding(.top, VGRSpacing.verticalMedium)

            }
        }
    }

    @ViewBuilder
    private func internalLinkContent(for article: VGRContent) -> some View {
        NavigationLink {
            VGRContentScreen(content: article) {
                dismiss()
            }
        } label: {
            VGRCardView(
                sizeClass: .small,
                title: article.title,
                subtitle: article.subtitle,
                imageUrl: article.imageUrl,
                isNew: article.isNew
            )
            .padding(.horizontal, VGRSpacing.horizontal)
        }
        .buttonStyle(VGRCardButtonStyle())
        .accessibilityAddTraits(.isLink)
    }
}

#Preview("With Background") {
    let sampleArticle = VGRContent(
        id: "sample",
        title: "Sample Internal Article",
        subtitle: "Subtitle",
        type: .article,
        imageUrl: "placeholder",
        elements: [
            VGRContentElement(
                type: .h1,
                text: "Sample Internal Article"
            )
        ]
    )

    NavigationStack {
        ScrollView {
            VGRContentInternalLinkView(
                element: VGRContentElement(
                    type: .internalLink,
                    text: "Read related article",
                    internalArticle: sampleArticle,
                    backgroundColor: "redSurfaceMinimal"
                )
            )
        }
        .background(Color.Elevation.background)
    }
}

#Preview("Without Background") {
    let sampleArticle = VGRContent(
        id: "sample",
        title: "Sample Internal Article",
        subtitle: "Subtitle",
        type: .article,
        imageUrl: "placeholder",
        elements: [
            VGRContentElement(
                type: .h1,
                text: "Sample Internal Article"
            )
        ]
    )

    NavigationStack {
        ScrollView {
            VGRContentInternalLinkView(
                element: VGRContentElement(
                    type: .internalLink,
                    text: "Read related article",
                    internalArticle: sampleArticle
                )
            )
        }
        .background(Color.Elevation.background)
    }
}
