import SwiftUI

/// A customizable shape container with configurable corner radii and styling.
///
/// `VGRShape` provides a flexible container view with rounded corners that can be customized
/// individually for each corner. It's designed to wrap content in a styled container with
/// consistent spacing and padding.
///
/// Example:
/// ```swift
/// VGRShape(bend: [.topLeading], radius: 40, padding: 16, spacing: 0) {
///     Text("Hello, world!")
///     Text("Additional content")
/// }
/// ```
///
/// - Note: The shape uses a `VStack` internally with `.leading` alignment.
public struct VGRShape<Content: View>: View {
    let content: Content
    var backgroundColor: Color = Color.Primary.blueSurfaceMinimal
    var bend: [Alignment]
    var radius: CGFloat = 40
    var padding: CGFloat = 16
    var spacing: CGFloat = 16

    /// Creates a new VGRShape container.
    ///
    /// - Parameters:
    ///   - bend: An array of alignments specifying which corners should be rounded. Defaults to `[.topLeading]`.
    ///   - backgroundColor: The background color of the shape. Defaults to `Color.Primary.blueSurfaceMinimal`.
    ///   - radius: The corner radius for rounded corners. Defaults to `40`.
    ///   - padding: The internal padding around the content. Defaults to `16`.
    ///   - spacing: The vertical spacing between content items in the internal VStack. Defaults to `16`.
    ///   - content: A view builder that creates the content to display inside the shape.
    public init(bend: [Alignment] = [.topLeading],
         backgroundColor: Color? = nil,
         radius: CGFloat = 40,
         padding: CGFloat = 16,
         spacing: CGFloat = 16,
         @ViewBuilder _ content: () -> Content) {

        self.bend = bend
        self.content = content()
        self.radius = radius
        self.padding = padding
        self.spacing = spacing
        if let bg = backgroundColor {
            self.backgroundColor = bg
        }

    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(padding)
        .background(backgroundColor)
        .clipShape(
            .rect(
                topLeadingRadius: bend.contains(.topLeading) ? radius : 0,
                bottomLeadingRadius: bend.contains(.bottomLeading) ? radius : 0,
                bottomTrailingRadius: bend.contains(.bottomTrailing) ? radius : 0,
                topTrailingRadius: bend.contains(.topTrailing) ? radius : 0
            )
        )
    }
}

#Preview {
    let alignments: [Alignment] = [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing]

    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(zip(alignments.indices, alignments)), id: \.0) { index, item in
                    VGRShape(bend: [item]) {
                        Text("Hello, world domination!")
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("VGRShape")
    }
}
