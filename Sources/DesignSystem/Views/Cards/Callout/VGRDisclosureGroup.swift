import SwiftUI

public struct VGRDisclosureGroup<Content: View>: View {
    let title: String
    let icon: Image?
    let backgroundColor: Color
    let content: Content

    // Lokalt tillstånd som används om ingen extern binding anges
    @State private var internalExpanded: Bool = false

    // Valfri extern binding som kan styra om gruppen är expanderad
    private var externalExpanded: Binding<Bool>?

    // Om en extern binding finns används den, annars används det interna tillståndet
    private var isExpanded: Binding<Bool> {
        externalExpanded ?? $internalExpanded
    }

    public init(
        title: String,
        icon: Image? = nil,
        backgroundColor: Color = Color.Elevation.elevation1,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.content = content()
    }

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
                HStack (alignment: .center, spacing: 12) {
                    if let icon = icon {
                           icon
                               .resizable()
                               .scaledToFit()
                               .frame(width: 25, height: 25)
                               .foregroundStyle(Color.Neutral.text)
                       }
                    Text(title)
                        .foregroundStyle(Color.Neutral.text)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
        )
        .foregroundStyle(Color.Neutral.text)
        .accentColor(Color.Neutral.text)
        .padding(12)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
  
    }
}

#Preview {
    VStack(spacing: 20) {
        VGRDisclosureGroup(title: "Varför rekommenderas kontakt med vården?") {
            
            Text("När du anger värden i skattningen finns det svar som gör att du kommer att få detta meddelande.")
            VStack(alignment: .leading, spacing: 4) {
                Text("• Områden du angivit är något av följande: genitalier, ansikte, handflator, ytan mellan skinkorna, hårbotten, fotsulor.")
                Text("• Utbredning är 5 handflator eller fler.")
            }
        }
    }
    .padding()
    .background(Color.Primary.blueSurfaceMinimal)
}
