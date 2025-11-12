import SwiftUI

struct WebViewTarget: Hashable {
    let title: String
    let url: String

    init(_ title: String, _ url: String) {
        self.title = title
        self.url = url
    }
}

struct VGRContentLinkGroup: View {
    let element: VGRContentElement

    var body: some View {

        VStack(spacing: 0) {
            ForEach(Array(element.links.enumerated()), id: \.offset) { index, link in
                VGRDivider()
                    .isVisible(index != 0)
                    .accessibilityHidden(true)

                if link.type == .webviewLink {
                    NavigationLink(value: WebViewTarget(link.subtitle, link.url)) {
                        LinkBody(link: link)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\("content.link.web".localized): \(link.text) \(link.subtitle)")
                    .accessibilityAddTraits(.isLink)

                } else {

                    Link(destination: URL(string: link.url)!) {
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
        .padding(.horizontal, VGRSpacing.horizontal)
        .padding(.bottom, VGRSpacing.verticalMedium)
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
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
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
