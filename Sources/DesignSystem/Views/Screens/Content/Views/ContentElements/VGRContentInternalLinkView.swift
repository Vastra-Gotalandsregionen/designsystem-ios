import SwiftUI

struct VGRContentInternalLinkView: View {
    let element: VGRContentElement
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let internalArticle = element.internalArticle {
            NavigationLink {
                VGRContentScreen(content: internalArticle) {
                    dismiss()
                }
            } label: {
                VGRCardView(
                    sizeClass: .small,
                    title: internalArticle.title,
                    subtitle: internalArticle.subtitle,
                    imageUrl: internalArticle.imageUrl,
                    isNew: internalArticle.isNew
                )
                .padding(.horizontal, VGRSpacing.horizontal)
            }
            .buttonStyle(VGRCardButtonStyle())
            .accessibilityAddTraits(.isLink)
        }
    }
}

#Preview {
    let sampleArticle = VGRContent(
        id: "sample",
        title: "Sample Internal Article",
        subtitle: "Subtitle",
        type: .article,
        imageUrl: "placeholder",
        elements: [
            VGRContentElement(
                type: .h1,
                text: "Sample Internal Article",
            )
        ]
    )

    NavigationStack {
        ScrollView {
            VGRContentInternalLinkView(
                element: VGRContentElement(
                    type: .internalLink,
                    text: "Read related article",
                    url: "https://www.gp.se",
                    internalArticle: sampleArticle
                )
            )
        }
    }
}
