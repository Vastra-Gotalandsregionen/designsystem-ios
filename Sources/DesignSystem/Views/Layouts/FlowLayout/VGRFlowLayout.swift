import SwiftUI

/// A `Layout` that arranges its subviews left-to-right, wrapping onto a new
/// row whenever the next subview would overflow the available width.
///
/// Each subview is measured at its ideal size (`sizeThatFits(.unspecified)`)
/// and placed in reading order. When a subview no longer fits on the current
/// row the layout starts a new row beneath the tallest subview of the
/// previous one, so rows of mixed-height content stay clear of each other.
///
/// Spacing is configurable per axis: ``horizontalSpacing`` separates items on
/// the same row and ``verticalSpacing`` separates the rows. Both default to
/// the design system's `Margins` scale so flow layouts stay visually
/// consistent with the rest of the package.
///
/// Use it for content of unknown or variable count that should wrap fluidly —
/// tag clouds, chip collections, or filter pills.
///
/// ### Usage
/// ```swift
/// VGRFlowLayout {
///     ForEach(tags, id: \.self) { tag in
///         Text(tag)
///             .padding(.horizontal, 12)
///             .padding(.vertical, 6)
///             .background(.blue.opacity(0.2))
///             .clipShape(Capsule())
///     }
/// }
///
/// // Independent spacing per axis
/// VGRFlowLayout(horizontalSpacing: 8, verticalSpacing: 12) { ... }
///
/// // Same spacing on both axes
/// VGRFlowLayout(spacing: 10) { ... }
/// ```
public struct VGRFlowLayout: Layout {
    /// Horizontal spacing between items on the same row.
    public var horizontalSpacing: CGFloat = .Margins.xtraSmall

    /// Vertical spacing between rows.
    public var verticalSpacing: CGFloat = .Margins.small

    /// Creates a flow layout with independent horizontal and vertical spacing.
    /// - Parameters:
    ///   - horizontalSpacing: The spacing between items on the same row.
    ///     Defaults to `.Margins.xtraSmall`.
    ///   - verticalSpacing: The spacing between rows. Defaults to
    ///     `.Margins.small`.
    public init(horizontalSpacing: CGFloat = .Margins.xtraSmall,
                verticalSpacing: CGFloat = .Margins.small) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    /// Creates a flow layout that applies the same spacing horizontally and
    /// vertically.
    /// - Parameter spacing: The spacing applied between items on a row and
    ///   between rows.
    public init(spacing: CGFloat) {
        self.horizontalSpacing = spacing
        self.verticalSpacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize,
                             subviews: Subviews,
                             cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }

            rowHeight = max(rowHeight, size.height)
            x += size.width + horizontalSpacing
        }

        return CGSize(
            width: maxWidth,
            height: y + rowHeight
        )
    }

    public func placeSubviews(in bounds: CGRect,
                              proposal: ProposedViewSize,
                              subviews: Subviews,
                              cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )

            x += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}


#Preview {
    let tags: [String] = [
        "Swift",
        "SwiftUI",
        "UIKit",
        "Combine",
        "Core Data",
        "CloudKit",
        "iOS",
        "macOS",
        "watchOS",
        "tvOS",
        "Xcode",
        "App Store",
        "WidgetKit",
        "HealthKit",
        "MapKit",
        "StoreKit",
        "ARKit",
        "RealityKit",
        "Vision",
        "Core ML",
        "Machine Learning",
        "Accessibility",
        "Localization",
        "Networking",
        "URLSession",
        "Concurrency",
        "Async/Await",
        "Actors",
        "Testing",
        "CI/CD",
        "Git",
        "GitHub",
        "Docker",
        "Kubernetes",
        "PostgreSQL",
        "Redis",
        "GraphQL",
        "REST API",
        "Firebase",
        "Analytics"
    ]

    NavigationStack {
        VGRContainer {
            VGRFlowLayout {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.Primary.action)
                        .foregroundStyle(Color.Neutral.textInverted)
                        .clipShape(Capsule())

                }
            }
            .border(.red, width: 1)
            .padding()
        }
        .navigationTitle("VGRFlowLayout")
        .navigationBarTitleDisplayMode(.inline)
    }
}
