import SwiftUI
/// A layout that arranges its subviews in a grid with a fixed number of equally wide columns.
///
/// Every column gets the same width. Each row is as tall as its tallest subview, so cards of
/// different heights line up neatly. Subviews are placed left to right, row by row.
///
/// - Note: The layout fills the width it is offered. If no width is proposed, it sizes
///   itself after the widest subview.
public struct VGRGridLayout: Layout {
    /// The number of columns. Values below `1` are treated as `1`.
    public var columns: Int
    /// The spacing between columns.
    public var horizontalSpacing: CGFloat
    /// The spacing between rows.
    public var verticalSpacing: CGFloat

    /// Creates a grid layout with separate spacing per axis.
    ///
    /// - Parameters:
    ///   - columns: The number of columns. Defaults to `2`.
    ///   - horizontalSpacing: The spacing between columns. Defaults to `.Margins.medium`.
    ///   - verticalSpacing: The spacing between rows. Defaults to `.Margins.medium`.
    public init(
        columns: Int = 2,
        horizontalSpacing: CGFloat = .Margins.medium,
        verticalSpacing: CGFloat = .Margins.medium
    ) {
        self.columns = columns
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    /// Creates a grid layout with the same spacing on both axes.
    ///
    /// - Parameters:
    ///   - columns: The number of columns. Defaults to `2`.
    ///   - spacing: The spacing between columns and rows.
    public init(columns: Int = 2, spacing: CGFloat) {
        self.init(
            columns: columns,
            horizontalSpacing: spacing,
            verticalSpacing: spacing
        )
    }

    /// The number of columns, with a minimum of one column.
    private var columnCount: Int { max(1, columns) }

    /// Calculates the size required to fit all subviews within the layout.
    ///
    /// Uses the proposed width when it is finite. Otherwise, calculates a width
    /// based on the widest ideal subview size, the number of columns and the
    /// horizontal spacing.
    ///
    /// Calculates each row's height based on its tallest subview and includes
    /// the vertical spacing between rows.
    ///
    /// - Parameters:
    ///   - proposal: The proposed size for the layout.
    ///   - subviews: The subviews to arrange.
    ///   - cache: The layout cache, which is unused.
    /// - Returns: The size required to fit all subviews, or `.zero` if there are none.
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let totalWidth: CGFloat
        if let proposed = proposal.width, proposed.isFinite {
            totalWidth = proposed
        } else {
            let widestIdeal =
                subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
            totalWidth =
                widestIdeal * CGFloat(columnCount) + horizontalSpacing
                * CGFloat(columnCount - 1)
        }

        let heights = rowHeights(
            for: subviews,
            columnWidth: columnWidth(for: totalWidth)
        )
        let totalHeight =
            heights.reduce(0, +) + verticalSpacing
            * CGFloat(max(0, heights.count - 1))
        return CGSize(width: totalWidth, height: totalHeight)
    }

    /// Positions all subviews in rows and columns within the specified bounds.
    ///
    /// Each subview is placed at the top-leading corner of its allocated frame.
    /// The height of each row is determined by its tallest subview.
    ///
    /// - Parameters:
    ///   - bounds: The rectangle available for the layout.
    ///   - proposal: The proposed size for the layout.
    ///   - subviews: The subviews to position.
    ///   - cache: The layout cache, which is unused.
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard !subviews.isEmpty else { return }

        let width = columnWidth(for: bounds.width)
        let heights = rowHeights(for: subviews, columnWidth: width)

        var y = bounds.minY
        for (row, height) in heights.enumerated() {
            for column in 0..<columnCount {
                let index = row * columnCount + column
                guard index < subviews.count else { break }

                let x =
                    bounds.minX + CGFloat(column) * (width + horizontalSpacing)
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: width, height: height)
                )
            }
            y += height + verticalSpacing
        }
    }

    /// Calculates the width allocated to each column.
    ///
    /// Subtracts the total horizontal spacing from the available width
    /// before dividing the remaining width equally between the columns.
    ///
    /// - Parameter totalWidth: The total width available for the layout.
    /// - Returns: The width allocated to each column, or zero if the
    ///   available width is smaller than the required spacing.
    private func columnWidth(for totalWidth: CGFloat) -> CGFloat {
        let gaps = horizontalSpacing * CGFloat(columnCount - 1)
        return max(0, (totalWidth - gaps) / CGFloat(columnCount))
    }

    /// Calculates the height of each row based on its tallest subview.
    ///
    /// Groups subviews into rows according to the number of columns.
    /// Each subview is measured using the specified column width and an
    /// unspecified height.
    ///
    /// - Parameters:
    ///   - subviews: The subviews to measure.
    ///   - columnWidth: The width allocated to each subview.
    /// - Returns: An array containing the height of each row.
    private func rowHeights(for subviews: Subviews, columnWidth: CGFloat)
        -> [CGFloat]
    {
        stride(from: 0, to: subviews.count, by: columnCount).map { start in
            let end = min(start + columnCount, subviews.count)
            return subviews[start..<end]
                .map {
                    $0.sizeThatFits(
                        ProposedViewSize(width: columnWidth, height: nil)
                    ).height
                }
                .max() ?? 0
        }
    }
}

#Preview {
    ScrollView {
        VGRGridLayout(columns: 2, spacing: .Margins.medium) {
            ForEach(1...5, id: \.self) { index in
                Text(
                    index.isMultiple(of: 2)
                        ? "Kort \(index)\nmed två rader" : "Kort \(index)"
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.Margins.medium)
                .background(
                    Color.Primary.blueSurfaceMinimal,
                    in: RoundedRectangle(cornerRadius: .Radius.mainRadius)
                )
            }
        }
        .padding(.Margins.medium)
    }
}
