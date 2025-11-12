import SwiftUI

struct VGRContentLinkView: View {
    let element: VGRContentElement

    private var url: URL? {
        return URL(string: element.url)
    }

    private var icon: String {
        if element.type == .link {
            return "rectangle.portrait.and.arrow.right"
        }

        return "chevron.right"
    }

    var body: some View {
        if let linkURL = url {
            Link(destination: linkURL) {
                Text(element.text)
                    .multilineTextAlignment(.leading)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: icon)
                    .scaledToFit()
                    .padding(.leading, VGRSpacing.horizontal)
                    .accessibilityHidden(true)
            }
            .buttonStyle(PlainButtonStyle())
            .fontWeight(.semibold)
            .foregroundStyle(Color.Primary.action)
            .padding(.horizontal, VGRSpacing.horizontalLink)
            .padding(.bottom, VGRSpacing.verticalXLarge)
            .accessibilityAddTraits(.isLink)

        } else {
            Text("Invalid link \"\(element.text)\"")
                .multilineTextAlignment(.leading)
                .fontWeight(.semibold)
                .foregroundStyle(Color.Primary.action)
                .padding(.horizontal, VGRSpacing.horizontalLink)
                .padding(.bottom, VGRSpacing.verticalXLarge)
                .accessibilityAddTraits(.isStaticText)
        }
    }
}

#Preview("Valid Link") {
    NavigationStack {
        ScrollView {
            VGRContentLinkView(
                element: VGRContentElement(
                    type: .link,
                    text: "Visit Example Website",
                    url: "https://example.com",
                )
            )

            VGRContentLinkView(
                element: VGRContentElement(
                    type: .webviewLink,
                    text: "Visit Example Website",
                    url: "https://example.com",
                )
            )
        }
        .navigationTitle("VGRContentLinkView")
    }
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
