import UIKit

/// A simple placeholder cell for days outside the current month
/// Uses pure UIKit for maximum performance
final class VGRCalendarPlaceholderCell: UICollectionViewCell {

    /// Reuse identifier for cell registration
    static let reuseIdentifier = "VGRCalendarPlaceholderCell"

    /// Minimum height matching the day cell's base height
    private static let minimumHeight: CGFloat = 44

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Self.minimumHeight)
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        CGSize(width: targetSize.width, height: Self.minimumHeight)
    }
}
