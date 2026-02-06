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


public extension View {
    /// Expands the view to take up the maximum available horizontal space
    /// and aligns its content to the leading edge.
    ///
    /// This is equivalent to applying:
    /// `frame(maxWidth: .infinity, alignment: .leading)`
    ///
    /// - Returns: A view that fills the available width and is leading-aligned.
    func maxLeading() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Expands the view to take up the maximum available horizontal space
    /// and aligns its content to the trailing edge.
    ///
    /// This is equivalent to applying:
    /// `frame(maxWidth: .infinity, alignment: .trailing)`
    ///
    /// - Returns: A view that fills the available width and is trailing-aligned.
    func maxTrailing() -> some View {
        self.frame(maxWidth: .infinity, alignment: .trailing)
    }
}
