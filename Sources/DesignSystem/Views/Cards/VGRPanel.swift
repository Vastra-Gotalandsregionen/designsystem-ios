import SwiftUI

/// A rounded, leading-aligned card with a solid background. Wrap arbitrary
/// content to give it the design system's elevated panel treatment — used
/// for grouping related content inside a ``VGRSection`` or ``VGRContainer``.
///
/// The background defaults to ``Color/Elevation/elevation1`` but can be
/// overridden, e.g. to surface a status colour for an informational card.
public struct VGRPanel<Content: View>: View {
    private let content: Content
    private let backgroundColor: Color
    private let foregroundColor: Color

    /// Creates a panel that stacks its children vertically and applies the
    /// design system's padded, rounded-corner background.
    /// - Parameters:
    ///   - backgroundColor: The fill colour behind the content. Defaults to
    ///     ``Color/Elevation/elevation1``.
    ///   - foregroundColor: The foreground style applied to the content,
    ///     inherited by `Text` and SF Symbol images that don't override it.
    ///     Defaults to ``Color/Neutral/text``.
    ///   - content: A view builder that produces the panel's children.
    public init(
        backgroundColor: Color = Color.Elevation.elevation1,
        foregroundColor: Color = Color.Neutral.text,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.Margins.medium)
            .maxLeading()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .foregroundStyle(foregroundColor)
    }
}

#Preview {
    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRPanel {
                    Text("Hello, world")
                }

                VGRPanel {
                    Text("Domination")
                }

                VGRPanel(backgroundColor: Color.Status.informationSurface) {
                    Text("Custom background")
                }
            }
        }
    }
}
