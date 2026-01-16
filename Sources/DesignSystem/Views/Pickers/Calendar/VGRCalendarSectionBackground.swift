import UIKit
import SwiftUI

/// A decoration view that provides a rounded background for each month section
final class VGRCalendarSectionBackground: UICollectionReusableView {

    /// Reuse identifier for decoration view registration
    static let reuseIdentifier = "VGRCalendarSectionBackground"

    /// Element kind identifier for the decoration view
    static let elementKind = "section-background"

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(Color.Elevation.elevation1)
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
