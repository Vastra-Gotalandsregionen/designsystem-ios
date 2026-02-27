import SwiftUI

struct VGRContentLinkView: View {
    let element: VGRContentElement

    private var url: URL? {
        return URL(string: element.url)
    }

    private var icon: String {
        "chevron.right"
    }

    private var urlTitle: String {
        return element.urlTitle.isEmpty ? element.url : element.urlTitle
    }

    var body: some View {
        if let linkURL = url {
            Link(destination: linkURL) {
                VStack {
                    Text(element.text)
                        .font(.bodyRegular)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(urlTitle)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: icon)
                    .scaledToFit()
                    .padding(.leading, VGRSpacing.horizontal)
                    .foregroundStyle(Color.Primary.action)
                    .accessibilityHidden(true)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityAddTraits(.isLink)
            .padding(.horizontal, VGRSpacing.horizontal)
            .padding(.vertical, VGRSpacing.verticalMedium)
            .background(Color.Elevation.elevation1)
            .clipShape(RoundedRectangle(cornerRadius: VGRRadius.mainRadius))
            .padding(.bottom, VGRSpacing.verticalXLarge)

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
            VStack(spacing: 16) {
                VGRContentLinkView(
                    element: VGRContentElement(
                        type: .link,
                        text: "Visit Example Website",
                        url: "https://example.com",
                    )
                )

                VGRContentLinkView(
                    element: VGRContentElement(
                        type: .link,
                        text: "Visit Example Website",
                        url: "https://example.com",
                        urlTitle: "example.com"
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
            .padding(.horizontal, VGRSpacing.horizontal)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRContentLinkView")
        .navigationBarTitleDisplayMode(.inline)
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
