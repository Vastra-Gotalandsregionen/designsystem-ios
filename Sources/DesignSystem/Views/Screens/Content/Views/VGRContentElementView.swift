import SwiftUI

struct VGRContentElementView: View {
    let element: VGRContentElement

    /// dismissAction can be passed to subsequent views if they need to control dismissal
    var dismissAction: (() -> Void)? = nil

    var body: some View {
        Group {
            switch element.type {
                case .image:
                    VGRContentImageView(element: element)

                case .heading:
                    VGRContentHeadingView(element: element)

                case .h1, .h2, .h3:
                    VGRContentTitleView(element: element)

                case .subhead, .body:
                    VGRContentTextView(element: element)

                case .link:
                    VGRContentLinkView(element: element)

                case .internalLink:
                    VGRContentInternalLinkView(element: element)

                case .list:
                    VGRContentListView(element: element)

                case .ordered:
                    VGRContentListView(element: element, isOrdered: true)

                case .video:
                    VGRContentVideoView(element: element)

                case .internalVideoSelectorLink:
                    /// TODO Implement support for video selector link elements
                    EmptyView()

                case .faq:
                    EmptyView()

                case .webviewLink:
                    VGRContentLinkView(element: element)

                case .linkGroup:
                    VGRContentLinkGroup(element: element)

                @unknown default:
                    Text("Unrecognizable content")
                        .padding(.horizontal, VGRSpacing.horizontal)
                        .padding(.bottom, VGRSpacing.verticalMedium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("All Element Types") {
    let linkedArticle = VGRContent.random()

    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Image element
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .image,
                        url: "placeholder",
                    )
                )
                
                // Heading element with date and read time
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .heading,
                        readTime: "5 min",
                        date: "2024-01-15",
                    )
                )
                
                // H1 Title
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .h1,
                        text: "Main Article Title",
                    )
                )
                
                // Subheading
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .subhead,
                        text: "This is a subheading with important information",
                    )
                )
                
                // Body text
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .body,
                        text: "This is body text content that would appear in an article. It demonstrates the standard paragraph formatting with proper line spacing and padding.",
                    )
                )
                
                // H2 Title
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .h2,
                        text: "Secondary Section Title",
                    )
                )
                
                // More body text
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .body,
                        text: "Another paragraph of body text to show how content flows between different sections.",
                    )
                )
                
                // List element
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .list,
                        list: [
                            "First list item with some explanatory text",
                            "Second list item that might be longer to demonstrate wrapping",
                            "Third list item",
                            "Fourth item to show multiple entries"
                        ],
                    )
                )
                .border(.red, width: 1)

                // Link group
                VGRContentElementView(
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
                .border(.red, width: 1)

                // H3 Title
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .h3,
                        text: "Subsection Title",
                    )
                )
                
                // External link
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .link,
                        text: "Learn more on our website",
                        url: "https://example.com",
                    )
                )

                // Webview link
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .webviewLink,
                        text: "Learn more on our website",
                        url: "https://example.com",
                    )
                )

                // Internal link (if article data is available)
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .internalLink,
                        text: "Related Article",
                        internalArticle: linkedArticle
                    )
                )

                // Video elements
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .video,
                        title: "Del 1:",
                        subtitle: "Vad är psoriasis?",
                        readTime: "3 minuter",
                        videoUrl: "https://player.vgregion.se/mobilapp1/smil:mc1/Y93sDHAABx5AnnK6V8uyEJ_iWRmspME7rM5UHSTvWcxFr/master.smil/playlist.m3u8",
                        videoId: "preview-video-1"
                    )
                )

                VGRContentElementView(
                    element: VGRContentElement(
                        type: .video,
                        title: "Del 2:",
                        subtitle: "Behandling och egenvård",
                        readTime: "5 minuter",
                        videoUrl: "https://player.vgregion.se/mobilapp1/smil:mc1/Hx5WiFEdNRwBinJhiUcqBn_bihwAfXDtaczHmBzJFgD46/master.smil/playlist.m3u8",
                        videoId: "preview-video-2"
                    )
                )
            }
        }
        .background(Color.Elevation.background)
    }
}
