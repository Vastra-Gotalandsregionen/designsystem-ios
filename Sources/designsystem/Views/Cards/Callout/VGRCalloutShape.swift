import SwiftUI

/// En container-vy som applicerar stil och bakgrundsfärg baserat på `CalloutShapeVariant`.
/// Används som det yttre skalet i en `VGRCallout` för att ge visuell kontext (t.ex. varning eller information).
struct VGRCalloutShape<Content: View>: View {
    
    /// Bakgrundsfärgen för komponenten
    let backgroundColor: Color
    /// Innehållet som visas inom den formade bakgrunden.
    let content: Content
    
    /// Skapar en `VGRCalloutShape` med angiven variant och innehåll.
    /// - Parameters:
    ///   - variant: Formvarianten (information eller varning).
    ///   - content: En vybyggare som tillhandahåller innehållet.
    init(backgroundColor: Color,
         @ViewBuilder _ content: () -> Content) {
        self.backgroundColor = backgroundColor
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
        VGRCalloutShape(backgroundColor: Color.Primary.blueSurfaceMinimal) {
            VGRCalloutText(header: "Hello", description: "World")
        }
        VGRCalloutShape(backgroundColor: Color.Accent.purpleSurfaceMinimal) {
            VGRCalloutText(header: "Hello", description: "World")
        }
    }
}
