import SwiftUI

public struct VGRDisclosureGroup<Content: View>: View {
    let title: String
    let icon: Image
    let backgroundColor: Color
    let content: Content

    @State private var isExpanded: Bool = false

    public init(
        title: String,
        icon: Image = Image(systemName: "info.circle"),
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
            isExpanded: $isExpanded,
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
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color.Neutral.text)
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
