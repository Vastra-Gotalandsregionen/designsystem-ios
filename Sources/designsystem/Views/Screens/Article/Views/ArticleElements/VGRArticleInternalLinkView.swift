import SwiftUI

struct VGRArticleInternalLinkView: View {
    let element: VGRArticleElement
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let internalArticle = element.internalArticle {
            NavigationLink {
                VGRArticleScreen(article: internalArticle) {
                    dismiss()
                }
            } label: {
                VGRArticleCardView(sizeClass: .small, article: internalArticle)
                    .padding(.horizontal, VGRArticleSpacing.horizontal)
            }
            .buttonStyle(VGRArticleCardButtonStyle())
        }
    }
}

#Preview {
    let sampleArticle = VGRArticle(
        id: "sample",
        title: "Sample Internal Article",
        subtitle: "Subtitle",
        type: .article,
        imageUrl: "placeholder",
        elements: [
            VGRArticleElement(
                type: .h1,
                text: "Sample Internal Article",
            )
        ]
    )

    NavigationStack {
        ScrollView {
            VGRArticleInternalLinkView(
                element: VGRArticleElement(
                    type: .internalLink,
                    text: "Read related article",
                    url: "https://www.gp.se",
                    internalArticle: sampleArticle
                )
            )
        }
    }
}
