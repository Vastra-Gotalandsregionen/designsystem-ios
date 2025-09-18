import SwiftUI

/// A comprehensive article display screen that renders various article elements in a scrollable view.
///
/// `VGRArticleScreen` provides a full-screen article reading experience with navigation controls,
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
/// let article = VGRArticle(...)
/// VGRArticleScreen(article: article) {
///     // Handle dismissal
/// }
/// ```
///
/// ## Article Element Support
/// The screen automatically renders different element types through `VGRArticleElementView`:
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
public struct VGRArticleScreen: View {
    @Environment(\.dismiss) private var dismiss

    /// The article data to display, containing all elements and metadata
    let article: VGRArticle

    /// Optional custom dismissal action. If provided, this action will be called when the close button is tapped.
    /// If not provided, the default environment dismiss action will be used.
    var dismissAction: (() -> Void)? = nil

    /// Initialize the article screen with the given article and optional dismiss action.
    /// - Parameters:
    ///   - article: The `VGRArticle` instance containing all content to display
    ///   - dismissAction: Optional closure to execute when the screen is dismissed
    public init(article: VGRArticle, dismissAction: (() -> Void)? = nil) {
        self.article = article
        self.dismissAction = dismissAction
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
        article.type == .article ? article.title : "article.type.\(article.type).title".localizedBundle
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(article.elements.enumerated()), id: \.offset) { index, element in
                    VGRArticleElementView(element: element, dismissAction: dismissAction)
                }
            }
            .accessibilityElement(children: .contain)
        }
        .onAppear {
            /// To get around issue of keyboard focus being stuck in navbar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .scrollView  
            }
        }
        .focused($focusedField, equals: .scrollView)
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
    @Previewable @State var selectedArticle: VGRArticle? = nil
    @Previewable @State var selectedNavigationArticle: VGRArticle? = nil

    let articles = VGRArticle.randomMultiple(count: 10)
    let sizes = (0..<10).map { _ in VGRArticleCardSizeClass.allCases.randomElement()! }

    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(articles.enumerated()), id: \.offset) { index, article in
                    VGRArticleCardButton(sizeClass: sizes[index], article: article) {
                        if index % 2 == 0 {
                            selectedNavigationArticle = article
                        } else {
                            selectedArticle = article
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRArticleScreen")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedNavigationArticle, destination: { article in
            VGRArticleScreen(article: article) {
                selectedNavigationArticle = nil
            }
        })
        .sheet(item: $selectedArticle) { article in
            NavigationStack {
                VGRArticleScreen(article: article) {
                    selectedArticle = nil
                }
            }
        }
    }
}

