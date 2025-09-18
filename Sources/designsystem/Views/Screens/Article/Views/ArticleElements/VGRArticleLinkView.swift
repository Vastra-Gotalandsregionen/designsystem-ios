import SwiftUI

struct VGRArticleLinkView: View {
    let element: VGRArticleElement

    private var url: URL? {
        return URL(string: element.url)
    }

    var body: some View {
        if let linkURL = url {
            Link(destination: linkURL) {
                Text(element.text)
                    .multilineTextAlignment(.leading)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .scaledToFit()
                    .padding(.leading, VGRArticleSpacing.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
            .fontWeight(.semibold)
            .foregroundStyle(Color.Primary.action)
            .padding(.horizontal, VGRArticleSpacing.horizontalLink)
            .padding(.bottom, VGRArticleSpacing.verticalXLarge)
        } else {
            Text("Invalid link \"\(element.text)\"")
                .multilineTextAlignment(.leading)
                .fontWeight(.semibold)
                .foregroundStyle(Color.Primary.action)
                .padding(.horizontal, VGRArticleSpacing.horizontalLink)
                .padding(.bottom, VGRArticleSpacing.verticalXLarge)
        }
    }
}

#Preview("Valid Link") {
    VGRArticleLinkView(
        element: VGRArticleElement(
            type: .link,
            text: "Visit Example Website",
            url: "https://example.com",
        )
    )
}

#Preview("Invalid Link") {
    VGRArticleLinkView(
        element: VGRArticleElement(
            type: .link,
            text: "Invalid Link Example",
            url: "not-a-valid-url",
        )
    )
}
