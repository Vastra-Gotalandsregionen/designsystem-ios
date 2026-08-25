import SwiftUI

/// Navigation destination value for links opened in an in-app web view.
///
/// Pushed onto the navigation stack when a `.webviewLink` row is tapped; the hosting
/// screen resolves it with `.navigationDestination(for: WebViewTarget.self)`.
struct WebViewTarget: Hashable {
    let title: String
    let url: String

    init(_ title: String, _ url: String) {
        self.title = title
        self.url = url
    }
}

/// Renders a `.linkGroup` element as a rounded card of link rows separated by dividers.
///
/// Each row shows the link text, a subtitle, and a trailing icon, and behaves according
/// to its type:
/// - `.webviewLink` - pushes a ``WebViewTarget`` onto the navigation stack, opening the
///   URL in an in-app web view (chevron icon)
/// - any other type - opens the URL externally via ``VGRContentLinkOpener``, which posts
///   `contentLinkNotSupported`/`contentLinkOpenFailed` notifications on failure so
///   consuming apps can track failed opens (external-link icon)
///
/// ## Accessibility
/// - Each row is a single accessibility element announced as a link, prefixed with
///   "web link" or "external link" followed by the link text and subtitle
/// - Dividers and row icons are hidden from assistive technologies
struct VGRContentLinkGroup: View {
    /// The `.linkGroup` content element whose `links` are rendered as rows.
    let element: VGRContentElement

    var body: some View {

        VStack(spacing: 0) {
            ForEach(Array(element.links.enumerated()), id: \.offset) { index, link in
                VGRDivider()
                    .isVisible(index != 0)

                if link.type == .webviewLink {
                    NavigationLink(value: WebViewTarget(link.subtitle, link.url)) {
                        LinkBody(link: link)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\("content.link.web".localized): \(link.text) \(link.subtitle)")
                    .accessibilityAddTraits(.isLink)

                } else {

                    Button {
                        if let url = URL(string: link.url) {
                            VGRContentLinkOpener.open(url)
                        } else {
                            print("Invalid URL: \"\(link.url)\"")
                        }
                    } label: {
                        LinkBody(link: link)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\("content.link.external".localized): \(link.text) \(link.subtitle)")
                    .accessibilityAddTraits(.isLink)
                }
            }
        }
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, .Margins.medium)
        .padding(.bottom, .Margins.small)
        .accessibilityElement(children: .contain)
    }

    private struct LinkBody: View {
        let link: VGRContentElement

        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(link.text)
                        .font(.bodyMedium)
                    Text(link.subtitle)
                        .font(.footnoteRegular)
                }
                .foregroundStyle(Color.Neutral.text)
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: link.type == .webviewLink ? "chevron.right" : "rectangle.portrait.and.arrow.right")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.Primary.action)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, .Margins.small)
            .padding(.horizontal, .Margins.medium)
            .contentShape(Rectangle())
        }
    }
}

#Preview {

    NavigationStack {
        ScrollView {
            VGRContentLinkGroup(
                element: VGRContentElement(
                    type: .linkGroup,
                    links: [
                        VGRContentElement(
                            type: .webviewLink,
                            text: "Öppna webben",
                            url: "https://www.medicininstruktioner.se",
                            subtitle: "www.medicininstruktioner.se",
                        ),
                        VGRContentElement(
                            type: .link,
                            text: "Ladda ner Appen",
                            url: "https://another-example.com",
                            subtitle: "Medicininstruktioner på AppStore",
                        )
                    ]
                )
            )

            VGRContentLinkGroup(
                element: VGRContentElement(
                    type: .linkGroup,
                    links: [
                        VGRContentElement(
                            type: .webviewLink,
                            text: "Öppna webben",
                            url: "https://www.medicininstruktioner.se",
                            subtitle: "www.medicininstruktioner.se",
                        ),
                    ]
                )
            )
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRContentLinkView")
        .navigationDestination(for: WebViewTarget.self) { target in
            WebView(urlString: target.url)
                .navigationTitle(target.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
