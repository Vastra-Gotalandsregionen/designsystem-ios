import SwiftUI

/// Represents the background style of a callout shape.
/// - `information`: Uses the surface color for informational messages.
/// - `warning`: Uses the surface color for warning messages.
public enum CalloutShapeVariant {
    case information
    case warning
}

/// A container view that applies styling and background color based on the `CalloutShapeVariant`.
/// Used as the outer shell of a `VGRCallout` to give visual context (e.g. warning or informational background).
struct VGRCalloutShape<Content: View>: View {
    
    /// The visual style of the callout shape (information or warning).
    let variant: CalloutShapeVariant
    /// The inner content displayed within the shaped background.
    let content: Content
    
    /// Determines the background color based on the selected `CalloutShapeVariant`.
    var backgroundColor: Color {
        switch variant {
        case .information: return Color.Status.informationSurface
        case .warning: return Color.Status.warningSurface
        }
    }
    
    /// Creates a `VGRCalloutShape` with the given variant and inner content.
    /// - Parameters:
    ///   - variant: The shape variant (information or warning).
    ///   - content: A view builder providing the inner view content.
    init(
        variant: CalloutShapeVariant,
        @ViewBuilder _ content: () -> Content
    ) {
        self.variant = variant
        self.content = content()
    }
    
    /// Composes the view layout with padding, background, and shape styling.
    var body: some View {
        VStack (spacing: 16) {
            content
        }
        .padding(16)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .textCase(.none)
    }
}

#Preview {
    VGRShape {
        VGRCalloutShape(variant: .information) {
            VGRCalloutText(header: "Hello", description: "World")
        }
        VGRCalloutShape(variant: .warning) {
            VGRCalloutText(header: "Hello", description: "World")
        }
    }
}
