import SwiftUI

struct VGRContentLinkGroup: View {
    let element: VGRContentElement

    var body: some View {

        VStack(spacing: 0) {
            ForEach(Array(element.links.enumerated()), id: \.offset) { index, link in
                VGRTableRowDivider()
                    .isVisible(index != 0)

                Button {
                    // TODO(EA): Open in webview if .webviewLink
                    // TODO(EA): Open using system facilities (openURL) if other
                } label: {
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
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, VGRSpacing.horizontal)

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
    }
}
