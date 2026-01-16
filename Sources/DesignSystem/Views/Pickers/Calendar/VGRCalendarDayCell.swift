import UIKit
import SwiftUI

/// A collection view cell that displays a calendar day
/// Uses UIHostingConfiguration for optimal performance
final class VGRCalendarDayCell: UICollectionViewCell {

    /// Reuse identifier for cell registration
    static let reuseIdentifier = "VGRCalendarDayCell"

    /// The index key for this cell's date
    private(set) var indexKey: VGRCalendarIndexKey?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configures the cell with a type-erased SwiftUI view
    func configure(
        indexKey: VGRCalendarIndexKey,
        content: AnyView
    ) {
        self.indexKey = indexKey

        contentConfiguration = UIHostingConfiguration {
            content
        }
        .margins(.all, 0)
        .background(.clear)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        indexKey = nil
    }
}
