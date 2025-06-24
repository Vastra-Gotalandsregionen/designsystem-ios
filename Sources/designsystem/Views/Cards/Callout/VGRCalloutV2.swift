import SwiftUI

struct VGRCalloutV2<Content: View>: View {
    
    enum ImageType {
        case none
        case icon
        case illustration
    }
    
    let header: String?
    let description: String
    let backgroundColor: Color
    let image: Image?
    let imageType: ImageType
    let dismiss: (() -> Void)?
    let content: () -> Content
    
    init(
        header: String? = nil,
        description: String,
        backgroundColor: Color = Color.Primary.blueSurfaceMinimal,
        image: Image? = nil,
        imageType: ImageType = .none,
        dismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.description = description
        self.backgroundColor = backgroundColor
        self.image = image
        self.imageType = imageType
        self.dismiss = dismiss
        self.content = content
    }
    
    init(
        header: String? = nil,
        description: String,
        backgroundColor: Color = Color.Primary.blueSurfaceMinimal,
        image: Image? = nil,
        imageType: ImageType = .none,
        dismiss: (() -> Void)? = nil
    ) where Content == EmptyView {
        self.header = header
        self.description = description
        self.backgroundColor = backgroundColor
        self.image = image
        self.imageType = imageType
        self.dismiss = dismiss
        self.content = { EmptyView() }
    }
    
    var imageSize: CGFloat {
        switch imageType {
        case .none, .icon:
            return 25
        case .illustration:
            return 100
        }
    }
    
    var body: some View {
        VGRCalloutShape(backgroundColor: backgroundColor) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                            .accessibilityHidden(true)
                    }
                    
                    VGRCalloutText(
                        header: header,
                        description: description
                    )
                    
                    if let dismiss {
                        VGRCalloutDismissButton(dismiss: dismiss)
                    }
                }
                
                content()
            }
        }
    }
}

#Preview {
    @Previewable @State var expanded1 = false
    @Previewable @State var expanded2 = false
    
    ScrollView {
        VStack(spacing: 32) {
            
            VGRCalloutV2(description: "Enklare varianten, enbart text")
            
            VGRCalloutV2(
                description: "Text med ikon",
                image: Image("chatbubble", bundle: .module))
            
            VGRCalloutV2(
                header: "Rubrik",
                description: "Text med större illustration och med titel",
                image: Image("illustration_presenting", bundle: .module),
                imageType: .illustration)
            
            VGRCalloutV2(
                header: "Rubrik",
                description: "Rubrik\nText\nIllustration\nAnnan bakgrundsfärg\nDismiss-knapp",
                backgroundColor: Color.Status.informationSurface,
                image: Image("illustration_presenting", bundle: .module),
                imageType: .illustration,
                dismiss: {
                    print("Dismiss")
                } ) {
                    VGRButton(label: "Knapp") {
                        print("Knapp")
                    }
                }
            
            VGRCalloutV2(
                header: "Rubrik",
                description: "Rubrik\nText\nIllustration\nAnnan bakgrundsfärg\nDismiss-knapp\nDisclosure/Accordion",
                backgroundColor: Color.Status.informationSurface,
                image: Image("illustration_presenting", bundle: .module),
                imageType: .illustration,
                dismiss: {
                    print("Dismiss")
                }
            ) {
                VStack(spacing: 0) {
                    DisclosureGroup("Visa mer", isExpanded: $expanded1) {
                        Text("Detta är innehåll i en öppen disclosure.")
                            .foregroundColor(Color.Neutral.text)
                    }
                    .disclosureGroupStyle(VGRDisclosureStyle())
                    .padding(16)
                    
                    DisclosureGroup("Avancerade inställningar", isExpanded: $expanded2) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Detalj 1")
                            Text("• Detalj 2")
                        }
                        .foregroundColor(Color.Neutral.text)
                    }
                    .disclosureGroupStyle(VGRDisclosureStyle())
                    .padding(16)
                }
                .background(Color.Elevation.elevation1)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
    }
}
