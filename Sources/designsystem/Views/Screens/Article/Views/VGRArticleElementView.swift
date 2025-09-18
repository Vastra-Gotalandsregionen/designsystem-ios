import SwiftUI

struct VGRArticleElementView: View {
    let element: VGRArticleElement

    /// dismissAction can be passed to subsequent views if they need to control dismissal
    var dismissAction: (() -> Void)? = nil

    var body: some View {
        switch element.type {
            case .image:
                VGRArticleImageView(element: element)

            case .heading:
                VGRArticleHeadingView(element: element)

            case .h1, .h2, .h3:
                VGRArticleTitleView(element: element)

            case .subhead, .body:
                VGRArticleTextView(element: element)

            case .link:
                VGRArticleLinkView(element: element)

            case .internalLink:
                VGRArticleInternalLinkView(element: element)

            case .list:
                VGRArticleListView(element: element)

            case .video, .internalVideoSelectorLink:
                /// TODO(EA): Implement support for video elements
                EmptyView()

            @unknown default:
                Text("Unrecognizable content")
                    .padding(.horizontal, VGRArticleSpacing.horizontal)
                    .padding(.bottom, VGRArticleSpacing.verticalMedium)
        }
    }
}

#Preview("All Element Types") {
    let linkedArticle = VGRArticle.random()

    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Image element
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .image,
                        url: "placeholder",
                    )
                )
                
                // Heading element with date and read time
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .heading,
                        readTime: "5 min",
                        date: "2024-01-15",
                    )
                )
                
                // H1 Title
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .h1,
                        text: "Main Article Title",
                    )
                )
                
                // Subheading
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .subhead,
                        text: "This is a subheading with important information",
                    )
                )
                
                // Body text
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .body,
                        text: "This is body text content that would appear in an article. It demonstrates the standard paragraph formatting with proper line spacing and padding.",
                    )
                )
                
                // H2 Title
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .h2,
                        text: "Secondary Section Title",
                    )
                )
                
                // More body text
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .body,
                        text: "Another paragraph of body text to show how content flows between different sections.",
                    )
                )
                
                // List element
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .list,
                        list: [
                            "First list item with some explanatory text",
                            "Second list item that might be longer to demonstrate wrapping",
                            "Third list item",
                            "Fourth item to show multiple entries"
                        ],
                    )
                )
                
                // H3 Title
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .h3,
                        text: "Subsection Title",
                    )
                )
                
                // External link
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .link,
                        text: "Learn more on our website",
                        url: "https://example.com",
                    )
                )
                
                // Internal link (if article data is available)
                VGRArticleElementView(
                    element: VGRArticleElement(
                        type: .internalLink,
                        text: "Related Article",
                        internalArticle: linkedArticle
                    )
                )
            }
        }
        .background(Color.Elevation.background)
    }
}
