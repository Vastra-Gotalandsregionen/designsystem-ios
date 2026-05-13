import Foundation

public extension CGFloat {

    /// Corner radius tokens used across the design system.
    enum Radius {
        /// `26 pt` — primary corner radius used for cards and most rounded surfaces.
        public static let mainRadius: CGFloat = 26

        /// `62 pt` — screen-level corner radius for full-screen containers.
        public static let screen: CGFloat = 62

        /// `38 pt` — large corner radius.
        public static let large38: CGFloat = 38

        /// `40 pt` — VGR-branded corner radius.
        public static let vgrCorner: CGFloat = 40

        /// `8 pt` — small corner radius.
        public static let smallSchema: CGFloat = 8
    }

    /// Spacing tokens used for padding, margins, and stack spacing.
    enum Margins {
        /// `32 pt` — extra-large spacing step.
        public static let xtraLarge: CGFloat = 32

        /// `24 pt` — large spacing step.
        public static let large: CGFloat = 24

        /// `16 pt` — medium spacing step. The default for most layouts.
        public static let medium: CGFloat = 16

        /// `12 pt` — small spacing step.
        public static let small: CGFloat = 12

        /// `8 pt` — extra-small spacing step.
        public static let xtraSmall: CGFloat = 8

        /// `16 pt` — horizontal inset used for safe-area edges.
        public static let safeArea: CGFloat = 16
    }

    /// Letter-spacing (tracking) tokens applied to text.
    enum Letterspacing {
        /// `0.2` — small tracking adjustment.
        public static let small: CGFloat = 0.2

        /// `0.0` — neutral tracking (no adjustment).
        public static let medium: CGFloat = 0.0
    }

}
