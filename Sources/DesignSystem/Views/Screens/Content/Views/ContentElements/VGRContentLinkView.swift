import SwiftUI

/// Renders a single standalone link (`.link`) element as a tappable card.
///
/// The card shows the link text with an optional URL title (`urlTitle`, falling back to the
/// raw URL) and a chevron. Tapping opens the URL externally via ``VGRContentLinkOpener``,
/// which posts `contentLinkNotSupported`/`contentLinkOpenFailed` notifications on failure
/// so consuming apps can track failed opens (see `VGRContentScreen` documentation).
///
/// If `element.url` cannot be parsed into a `URL`, an inline "Invalid link" message is
/// rendered instead of the card.
///
/// ## Accessibility
/// - The card is announced as a link (`.isLink`)
/// - The chevron icon is hidden from assistive technologies
struct VGRContentLinkView: View {
    /// The `.link` content element to render. Uses `text`, `url` and `urlTitle`.
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
            Button {
                VGRContentLinkOpener.open(linkURL)
            } label: {
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
                    .padding(.leading, .Margins.medium)
                    .foregroundStyle(Color.Primary.action)
                    .accessibilityHidden(true)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityAddTraits(.isLink)
            .padding(.horizontal, .Margins.medium)
            .padding(.vertical, .Margins.small)
            .background(Color.Elevation.elevation1)
            .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .padding(.bottom, .Margins.xtraLarge)
            .padding(.horizontal, .Margins.medium)

        } else {
            Text("Invalid link \"\(element.text)\"")
                .multilineTextAlignment(.leading)
                .fontWeight(.semibold)
                .foregroundStyle(Color.Primary.action)
                .padding(.horizontal, .Margins.xtraLarge)
                .padding(.bottom, .Margins.xtraLarge)
                .accessibilityAddTraits(.isStaticText)
        }
    }
}

#Preview("Valid Link") {
    NavigationStack {
        VGRContainer {

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
