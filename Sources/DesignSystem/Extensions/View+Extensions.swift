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
    /// and aligns its content in the center.
    ///
    /// This is equivalent to applying:
    /// `frame(maxWidth: .infinity, alignment: .center)`
    ///
    /// - Returns: A view that fills the available width and is center-aligned.
    func maxCentered() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
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

public extension View {
    /// Overlays the view with a rounded, error-colored border to signal a warning or invalid state.
    ///
    /// The border defaults to `Color.Status.errorText` with a 2pt stroke
    /// and matches the design system's main corner radius (`.Radius.mainRadius`).
    /// When `isVisible` is `false`, no border is drawn.
    ///
    /// - Parameter isVisible: A Boolean value that determines whether the warning border is shown.
    ///   - `true`: The border is rendered on top of the view.
    ///   - `false`: No border is rendered.
    ///
    /// - Returns: A view overlaid with a conditional warning border.
    func warningBorder(_ isVisible: Bool) -> some View {
        self.roundedBorder(isVisible, borderColor: Color.Status.errorText, lineWidth: 2)
    }

    /// Overlays the view with a configurable rounded border that matches the
    /// design system's main corner radius (`.Radius.mainRadius`). A general-purpose
    /// counterpart to ``warningBorder(_:)`` for non-warning use cases.
    ///
    /// - Parameter isVisible: A Boolean value that determines whether the border is shown.
    ///   - `true`: The border is rendered on top of the view.
    ///   - `false`: No border is rendered.
    /// - Parameter borderColor: The color of the border. Defaults to `Color.Neutral.divider`.
    /// - Parameter lineWidth: The stroke width of the border. Defaults to `1`.
    ///
    /// - Returns: A view overlaid with a conditional rounded border.
    func roundedBorder(
        _ isVisible: Bool = true,
        borderColor: Color = Color.Neutral.divider,
        lineWidth: CGFloat = 1
    ) -> some View {
        self.overlay {
            RoundedRectangle(cornerRadius: .Radius.mainRadius)
                .strokeBorder(borderColor, lineWidth: lineWidth)
                .isVisible(isVisible)
        }
    }
}


public extension View {
    /// Applicerar `.frame(maxWidth: .infinity, alignment:)` endast när
    /// `isFullWidth` är `true`.
    @ViewBuilder
    func applyFullWidth(_ isFullWidth: Bool, alignment: Alignment = .center) -> some View {
        if isFullWidth {
            frame(maxWidth: .infinity, alignment: alignment)
        } else {
            self
        }
    }
}
