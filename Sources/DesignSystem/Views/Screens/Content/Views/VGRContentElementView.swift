import SwiftUI

struct VGRContentElementView: View {
    let element: VGRContentElement

    /// dismissAction can be passed to subsequent views if they need to control dismissal
    var dismissAction: (() -> Void)? = nil

    var body: some View {
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

            case .video, .internalVideoSelectorLink:
                /// TODO(EA): Implement support for video elements
                EmptyView()

            case .faq:
                EmptyView()

            @unknown default:
                Text("Unrecognizable content")
                    .padding(.horizontal, VGRContentSpacing.horizontal)
                    .padding(.bottom, VGRContentSpacing.verticalMedium)
        }
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
                
                // Internal link (if article data is available)
                VGRContentElementView(
                    element: VGRContentElement(
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
