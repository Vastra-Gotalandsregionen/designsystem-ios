import SwiftUI

struct VGRContentElementView<CustomView: View>: View {
    let element: VGRContentElement

    /// The article ID this element belongs to (used for feedback tracking)
    var articleId: String = ""

    /// dismissAction can be passed to subsequent views if they need to control dismissal
    var dismissAction: (() -> Void)? = nil

    /// Callback when feedback is submitted (only used for feedback elements)
    var onFeedbackSubmitted: ((VGRFeedbackResult) -> Void)? = nil

    /// Callback when an action callout button is tapped, passes the actionId
    var onActionCallout: ((String) -> Void)? = nil

    /// Callback when a video is selected in a video selector element, passes the selected video
    var onVideoSelected: ((VGRVideo) -> Void)? = nil
    /// Optional custom view rendered when the element type is `.custom`
    let customElementView: (VGRContentElement) -> CustomView

    init(element: VGRContentElement,
         articleId: String = "",
         dismissAction: (() -> Void)? = nil,
         onFeedbackSubmitted: ((VGRFeedbackResult) -> Void)? = nil,
         onActionCallout: ((String) -> Void)? = nil,
         onVideoSelected: ((VGRVideo) -> Void)? = nil,
         @ViewBuilder customElementView: @escaping (VGRContentElement) -> CustomView) {
        self.element = element
        self.articleId = articleId
        self.dismissAction = dismissAction
        self.onFeedbackSubmitted = onFeedbackSubmitted
        self.onActionCallout = onActionCallout
        self.onVideoSelected = onVideoSelected
        self.customElementView = customElementView
    }

    init(element: VGRContentElement, articleId: String = "",
         dismissAction: (() -> Void)? = nil,
         onFeedbackSubmitted: ((VGRFeedbackResult) -> Void)? = nil,
         onActionCallout: ((String) -> Void)? = nil,
         onVideoSelected: ((VGRVideo) -> Void)? = nil)
        where CustomView == EmptyView {
        self.element = element
        self.articleId = articleId
        self.dismissAction = dismissAction
        self.onFeedbackSubmitted = onFeedbackSubmitted
        self.onActionCallout = onActionCallout
        self.onVideoSelected = onVideoSelected
        self.customElementView = { _ in EmptyView() }
    }

    var body: some View {
        Group {
            switch element.type {
                case .image:
                    VGRContentImageView(element: element)

                case .heading:
                    VGRContentHeadingView(element: element)

                case .h1, .h2, .h3:
                    VGRContentTitleView(element: element)

                case .subhead, .body, .footnote:
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
                    VGRContentVideoSelectorView(
                        element: element,
                        onVideoSelected: onVideoSelected
                    )

                case .faq:
                    EmptyView()

                case .feedback:
                    VGRContentFeedbackView(
                        element: element,
                        articleId: articleId,
                        onFeedbackSubmitted: onFeedbackSubmitted
                    )

                case .actionCallout:
                    VGRContentActionCalloutView(
                        element: element,
                        onAction: {
                            onActionCallout?(element.actionId)
                        },
                        dismissAction: dismissAction
                    )

                case .webviewLink:
                    VGRContentLinkView(element: element)

                case .linkGroup:
                    VGRContentLinkGroup(element: element)
                
                case .custom:
                    customElementView(element)

                @unknown default:
                    Text("Unrecognizable content")
                        .padding(.horizontal, VGRSpacing.horizontal)
                        .padding(.bottom, VGRSpacing.verticalMedium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityRespondsToUserInteraction()
    }
}

#Preview("All Element Types") {
    let linkedArticle = VGRContent.random()

    let videoFeed = VGRContent(
        title: "Videoklipp",
        subtitle: "Korta filmer om psoriasis",
        type: .videofeed,
        imageUrl: "",
        elements: [
            VGRContentElement(
                type: .video,
                title: "Del 1:",
                subtitle: "Vad är psoriasis?",
                readTime: "3 minuter",
                videoUrl: "https://player.vgregion.se/mobilapp1/smil:mc1/Y93sDHAABx5AnnK6V8uyEJ_iWRmspME7rM5UHSTvWcxFr/master.smil/playlist.m3u8",
                videoId: "preview-selector-video-1"
            ),
            VGRContentElement(
                type: .video,
                title: "Del 2:",
                subtitle: "Behandling och egenvård",
                readTime: "5 minuter",
                videoUrl: "https://player.vgregion.se/mobilapp1/smil:mc1/Hx5WiFEdNRwBinJhiUcqBn_bihwAfXDtaczHmBzJFgD46/master.smil/playlist.m3u8",
                videoId: "preview-selector-video-2"
            )
        ]
    )

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

                // Video selector link, pointing at an already resolved video feed
                VGRContentElementView(
                    element: VGRContentElement(
                        type: .internalVideoSelectorLink,
                        internalArticle: videoFeed
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
            }
        }
        .background(Color.Elevation.background)
    }
}
