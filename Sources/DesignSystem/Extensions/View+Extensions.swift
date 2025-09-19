import Foundation
import SwiftUI

public extension View {
    /// Conditionally shows or hides the view based on a Boolean value.
    ///
    /// - Parameter shouldShow: A Boolean value that determines whether the view is visible.
    ///   - `true`: The view is rendered and visible.
    ///   - `false`: An `EmptyView` is rendered instead, effectively hiding the view.
    ///
    /// - Returns: Either the original view (if `shouldShow` is `true`) or an `EmptyView`.
    @ViewBuilder
    func isVisible(_ shouldShow: Bool) -> some View {
        if shouldShow {
            self
        } else {
            EmptyView()
        }
    }
}
