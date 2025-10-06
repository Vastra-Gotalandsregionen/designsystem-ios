import SwiftUI

struct VGRContentLinkView: View {
    let element: VGRContentElement

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
                    .padding(.leading, VGRSpacing.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
            .fontWeight(.semibold)
            .foregroundStyle(Color.Primary.action)
            .padding(.horizontal, VGRSpacing.horizontalLink)
            .padding(.bottom, VGRSpacing.verticalXLarge)
        } else {
            Text("Invalid link \"\(element.text)\"")
                .multilineTextAlignment(.leading)
                .fontWeight(.semibold)
                .foregroundStyle(Color.Primary.action)
                .padding(.horizontal, VGRSpacing.horizontalLink)
                .padding(.bottom, VGRSpacing.verticalXLarge)
        }
    }
}

#Preview("Valid Link") {
    VGRContentLinkView(
        element: VGRContentElement(
            type: .link,
            text: "Visit Example Website",
            url: "https://example.com",
        )
    )
}

#Preview("Invalid Link") {
    VGRContentLinkView(
        element: VGRContentElement(
            type: .link,
            text: "Invalid Link Example",
            url: "not-a-valid-url",
        )
    )
}
