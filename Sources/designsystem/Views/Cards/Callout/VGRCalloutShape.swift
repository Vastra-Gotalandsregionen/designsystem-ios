import SwiftUI

/// En container-vy som applicerar stil och bakgrundsfärg baserat på `CalloutShapeVariant`.
/// Används som det yttre skalet i en `VGRCallout` för att ge visuell kontext (t.ex. varning eller information).
public struct VGRCalloutShape<Content: View>: View {

    /// Bakgrundsfärgen för komponenten
    let backgroundColor: Color

    /// Innehållet som visas inom den formade bakgrunden.
    let content: Content
    
    /// Skapar en `VGRCalloutShape` med angiven variant och innehåll.
    /// - Parameters:
    ///   - variant: Formvarianten (information eller varning).
    ///   - content: En vybyggare som tillhandahåller innehållet.
    public init(backgroundColor: Color = Color.Status.informationSurface,
                @ViewBuilder _ content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    /// Komponerar vy-layouten med padding, bakgrund och formad stil.
    public var body: some View {
        VStack(spacing: 16) {
            content
        }
        .padding(16)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .textCase(.none)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                VGRCalloutShape {
                    Text("Hello, `plain` **VGRCalloutShape**, world!")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote).fontWeight(.regular)

                    VGRButton(label: "Action", variant: .secondary) {
                        print("Action pressed")
                    }
                }
                .padding(.horizontal, 16)

                VGRCalloutShape(backgroundColor: Color.Status.warningSurface) {
                    Text("Hello, `plain` **VGRCalloutShape**, world!")
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VGRButton(
                        label: "Ändra inställningar",
                        icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
                        variant: .primary
                    ) {
                        print("Action pressed")
                    }
                }
                .padding(.horizontal, 16)

                VGRShape {
                    VGRCalloutShape(backgroundColor: Color.Primary.blueSurfaceMinimal) {
                        VGRCalloutText(header: "Hello", description: "World")
                    }
                    VGRCalloutShape(backgroundColor: Color.Accent.limeSurface) {
                        VGRCalloutText(header: "Hello", description: "World")
                    }
                }
            }
        }
        .navigationTitle("VGRCalloutShape")
        .navigationBarTitleDisplayMode(.inline)
    }
}
