import SwiftUI

/// A comprehensive article display screen that renders various article elements in a scrollable view.
///
/// `VGRContentScreen` provides a full-screen article reading experience with navigation controls,
/// accessibility features, and support for various article element types including text, images,
/// headings, links, and lists.
///
/// ## Features
/// - Dynamic navigation title based on article type
/// - Scrollable content with keyboard focus management
/// - Accessibility support with proper element grouping
/// - Toolbar with close button functionality
/// - Support for modal dismissal
///
/// ## Usage
/// ```swift
/// let content = VGRContent(...)
/// VGRContentScreen(content: content) {
///     // Handle dismissal
/// }
/// ```
///
/// ## Content Element Support
/// The screen automatically renders different element types through `VGRContentElementView`:
/// - `.image` - Article images with proper aspect ratio
/// - `.heading` - Date and read time metadata
/// - `.h1`, `.h2`, `.h3` - Title headers with varying typography
/// - `.subhead`, `.body` - Text content with appropriate styling
/// - `.link` - External links with system icons
/// - `.internalLink` - Navigation to other articles
/// - `.list` - Bulleted list items
/// - `.video`, `.internalVideoSelectorLink` - Placeholder for future video support
///
/// ## Accessibility
/// - Navigation title announced by screen readers
/// - Proper focus management for keyboard navigation
/// - Article content grouped for logical navigation
/// - Close button accessible via toolbar
///
/// ## Navigation
/// - Inline navigation bar with dynamic title
/// - Close button in trailing toolbar position
/// - Automatic focus management to prevent keyboard issues
public struct VGRContentScreen: View {
    @Environment(\.dismiss) private var dismiss

    /// The article data to display, containing all elements and metadata
    let content: VGRContent

    /// Optional custom dismissal action. If provided, this action will be called when the close button is tapped.
    /// If not provided, the default environment dismiss action will be used.
    var dismissAction: (() -> Void)? = nil

    /// Optional callback when feedback is submitted (for threshold articles with feedback elements)
    var onFeedbackSubmitted: ((VGRFeedbackResult) -> Void)? = nil

    /// Initialize the article screen with the given article and optional dismiss action.
    /// - Parameters:
    ///   - article: The `VGRContent` instance containing all content to display
    ///   - dismissAction: Optional closure to execute when the screen is dismissed
    ///   - onFeedbackSubmitted: Optional callback when feedback is submitted
    public init(
        content: VGRContent,
        dismissAction: (() -> Void)? = nil,
        onFeedbackSubmitted: ((VGRFeedbackResult) -> Void)? = nil
    ) {
        self.content = content
        self.dismissAction = dismissAction
        self.onFeedbackSubmitted = onFeedbackSubmitted
    }

    /// Focus state for managing keyboard navigation within the scroll view
    @FocusState private var focusedField: Field?

    /// Enumeration of focusable fields within the article screen
    private enum Field: Hashable {
        case scrollView
    }

    /// Computed navigation title based on the article type and content.
    /// Returns the article title for standard articles, or a localized type-specific title for other content types.
    var navigationTitle: String {
        content.type == .article ? content.title : "content.type.\(content.type).title".localizedBundle
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(content.elements.enumerated()), id: \.offset) { index, element in
                    VGRContentElementView(
                        element: element,
                        articleId: content.id,
                        dismissAction: dismissAction,
                        onFeedbackSubmitted: onFeedbackSubmitted
                    )
                }
            }
            .accessibilityElement(children: .contain)
        }
        .navigationDestination(for: WebViewTarget.self, destination: { target in
            /// This destination is used to open links in the in-app web browser
            WebView(urlString: target.url)
                .navigationTitle(target.title)
                .navigationBarTitleDisplayMode(.inline)
        })
        .background(Color.Elevation.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                VGRCloseButton(dismissAction: dismissAction)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedContent: VGRContent? = nil

    let articles = VGRContent.randomMultiple(count: 10)
    let sizes = (0..<10).map { _ in VGRCardSizeClass.allCases.randomElement()! }

    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(articles.enumerated()), id: \.offset) { index, article in
                    VGRCardButton(
                        sizeClass: sizes[index],
                        title: article.title,
                        subtitle: article.subtitle,
                        imageUrl: article.imageUrl,
                        isNew: article.isNew
                    ) {
                        selectedContent = article
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRContentScreen")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedContent) { article in
            NavigationStack {
                VGRContentScreen(content: article) {
                    selectedContent = nil
                }
            }
        }
    }
}

