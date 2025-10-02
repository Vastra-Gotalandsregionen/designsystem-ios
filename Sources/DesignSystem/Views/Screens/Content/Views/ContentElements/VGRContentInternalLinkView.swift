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
                VGRContentCardView(sizeClass: .small, content: internalArticle)
                    .padding(.horizontal, VGRContentSpacing.horizontal)
            }
            .buttonStyle(VGRContentCardButtonStyle())
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
