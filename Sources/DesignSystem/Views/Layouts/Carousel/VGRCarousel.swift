import SwiftUI

/// A horizontally scrollable, view-aligned carousel where all cards
/// have the same width and height.
///
/// The card width is a fraction of the carousel's available width
/// (`itemWidthFraction`), allowing the layout to adapt to different
/// screen sizes and orientations.
///
/// The height is determined by the tallest card, allowing content such
/// as multiline text and Dynamic Type to expand naturally.
///
/// The carousel does not apply a background, allowing the surrounding
/// view's background to remain visible.
public struct VGRCarousel<Content: View>: View {

    private let spacing: CGFloat
    private let horizontalMargin: CGFloat
    private let itemWidthFraction: CGFloat
    private let content: Content

    /// - Parameters:
    ///   - itemWidthFraction: The width of each card as a fraction of
    ///     the carousel's available width. Values below 0.5 show more
    ///     than two cards at once, while values around 0.5 typically
    ///     allow part of the next card to remain visible.
    ///   - spacing: The spacing between cards.
    ///   - horizontalMargin: The margin before the first card and
    ///     after the last card.
    ///   - content: The cards to display in the carousel.
    public init(
        itemWidthFraction: CGFloat = 0.5,
        spacing: CGFloat = .Margins.medium,
        horizontalMargin: CGFloat = .Margins.medium,
        @ViewBuilder content: () -> Content
    ) {
        precondition(
            itemWidthFraction > 0 && itemWidthFraction <= 1,
            "itemWidthFraction must be greater than 0 and less than or equal to 1."
        )

        self.itemWidthFraction = itemWidthFraction
        self.spacing = spacing
        self.horizontalMargin = horizontalMargin
        self.content = content()
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                content
                    .containerRelativeFrame(.horizontal) { length, _ in
                        length * itemWidthFraction
                    }
                    .frame(maxHeight: .infinity)
            }
            .scrollTargetLayout()
            .fixedSize(horizontal: false, vertical: true)
        }
        .contentMargins(.horizontal, horizontalMargin, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled()
    }
}

#Preview {
    VGRCarousel {
        ForEach(0..<5) { index in
            VStack(alignment: .leading) {
                Circle().fill(.purple.opacity(0.3)).frame(width: 44, height: 44)
                Text(index == 2 ? "Avslappning för kropp och sinne" : "Kort \(index + 1)")
                    .font(.headline)
                Spacer(minLength: 16)
                Text("15 minuter").font(.footnote)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    .padding(.vertical)
    .background(Color.gray.opacity(0.3))
}
