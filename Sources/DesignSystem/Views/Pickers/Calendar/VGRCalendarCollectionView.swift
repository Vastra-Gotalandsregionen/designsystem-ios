import UIKit
import SwiftUI

// MARK: - CalendarCollectionView


class VGRCalendarCollectionView: UICollectionView {


    override var scrollsToTop: Bool {
        get { return false }
        set {}
    }

    /// Prevent VoiceOver-triggered scrolling
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if UIAccessibility.isVoiceOverRunning {
            let delta = abs(contentOffset.y - self.contentOffset.y)
            /// Block large jumps (VoiceOver trying to scroll to off-screen element)
            /// Allow small scrolls (user swiping between elements)
            if delta > bounds.height {
                return
            }
        }

        super.setContentOffset(contentOffset, animated: animated)
    }
}
