import SwiftUI

/// Representerar bakgrundsstilen för en callout-form.
/// - `information`: Använder ytfärg för informationsmeddelanden.
/// - `warning`: Använder ytfärg för varningsmeddelanden.
public enum CalloutShapeVariant {
    case information
    case warning
}

/// En container-vy som applicerar stil och bakgrundsfärg baserat på `CalloutShapeVariant`.
/// Används som det yttre skalet i en `VGRCallout` för att ge visuell kontext (t.ex. varning eller information).
struct VGRCalloutShape<Content: View>: View {
    
    /// Den visuella stilen för callout-formen (information eller varning).
    let variant: CalloutShapeVariant
    /// Innehållet som visas inom den formade bakgrunden.
    let content: Content
    
    /// Bestämmer bakgrundsfärgen baserat på vald `CalloutShapeVariant`.
    var backgroundColor: Color {
        switch variant {
        case .information: return Color.Status.informationSurface
        case .warning: return Color.Status.warningSurface
        }
    }
    
    /// Skapar en `VGRCalloutShape` med angiven variant och innehåll.
    /// - Parameters:
    ///   - variant: Formvarianten (information eller varning).
    ///   - content: En vybyggare som tillhandahåller innehållet.
    init(variant: CalloutShapeVariant,
        @ViewBuilder _ content: () -> Content) {
        self.variant = variant
        self.content = content()
    }
    
    /// Komponerar vy-layouten med padding, bakgrund och formad stil.
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
