import SwiftUI

/// En  wrapper kring `DisclosureGroup` med stöd för:
/// - Titel och valfri ikon i labeln
/// - Bakgrundsfärg enligt designsystem
/// - Antingen internt eller externt styrt expanderingstillstånd
///
/// Användning (internt tillstånd):
/// ```swift
/// VGRDisclosureGroup(title: "Mer info") {
///     Text("Detaljer…")
/// }
/// ```
///
/// Användning (externt tillstånd):
/// ```swift
/// @State var isOpen = false
/// VGRDisclosureGroup(title: "Avancerat", isExpanded: $isOpen) {
///     Text("Inställningar…")
/// }
/// ```
public struct VGRDisclosureGroup<Content: View>: View {

    /// Titel som visas i labeln.
    let title: String

    /// Valfri ikon som visas till vänster om titeln.
    let icon: Image?

    /// Bakgrundsfärg för hela komponenten.
    let backgroundColor: Color

    /// Innehållet som visas när gruppen är expanderad.
    let content: Content

    // MARK: - Expansionstillstånd

    /// Lokalt tillstånd som används om ingen extern binding anges.
    @State private var internalExpanded: Bool = false

    /// Valfri extern binding för att styra om gruppen är expanderad.
    private var externalExpanded: Binding<Bool>?

    /// Aktuell binding för expandering: använder extern binding om den finns, annars internt state.
    private var isExpanded: Binding<Bool> {
        externalExpanded ?? $internalExpanded
    }

    // MARK: - Init

    /// Skapar en `VGRDisclosureGroup`.
    ///
    /// - Parameters:
    ///   - title: Texten som visas i labeln.
    ///   - icon: (Valfritt) Ikon som visas till vänster om titeln.
    ///   - backgroundColor: Bakgrundsfärg för komponenten. Default är `Color.Elevation.elevation1`.
    ///   - isExpanded: (Valfritt) Extern binding för expandering. Om `nil` används internt state.
    ///   - content: Innehållet som visas när gruppen är expanderad.
    public init(
        title: String,
        icon: Image? = nil,
        backgroundColor: Color = Color.Elevation.elevation1,
        isExpanded: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.externalExpanded = isExpanded
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        DisclosureGroup(
            isExpanded: isExpanded,
            content: {
                VStack(alignment: .leading, spacing: 8) {
                    content
                }
                .padding(.top, 8)
                .font(.subheadline)
                .foregroundStyle(Color.Neutral.text)
            },
            label: {
                HStack(alignment: .center, spacing: 12) {
                    if let icon = icon {
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(Color.Neutral.text)
                    }

                    Text(title)
                        .font(.bodyMedium)
                        .foregroundStyle(Color.Neutral.text)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
        )
        .foregroundStyle(Color.Neutral.text)
        .padding(12)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .disclosureGroupStyle(VGRDisclosureStyle())
    }
}

#Preview {

    @Previewable @State var isExpanded: Bool = false

    VStack(spacing: 20) {
        VGRDisclosureGroup(title: "Varför rekommenderas kontakt med vården?", icon: Image(systemName: "info.circle")) {
            Text("När du anger värden i skattningen finns det svar som gör att du kommer att få detta meddelande.")
            VStack(alignment: .leading, spacing: 4) {
                Text("• Områden du angivit är något av följande: genitalier, ansikte, handflator, ytan mellan skinkorna, hårbotten, fotsulor.")
                Text("• Utbredning är 5 handflator eller fler.")
            }
        }

        VGRButton(label: "External trigger ") {
            isExpanded.toggle()
        }

        VGRDisclosureGroup(
            title: "External expansion",
            isExpanded: $isExpanded
        ) {
            Text("När du anger värden i skattningen finns det svar som gör att du kommer att få detta meddelande.")
            VStack(alignment: .leading, spacing: 4) {
                Text("• Områden du angivit är något av följande: genitalier, ansikte, handflator, ytan mellan skinkorna, hårbotten, fotsulor.")
                Text("• Utbredning är 5 handflator eller fler.")
            }
        }

        VGRDisclosureGroup(title: "Hello, world domination") {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
        }
    }
    .padding()
    .background(Color.Primary.blueSurfaceMinimal)
}
