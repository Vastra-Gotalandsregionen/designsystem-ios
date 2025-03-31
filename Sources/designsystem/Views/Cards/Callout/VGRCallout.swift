import SwiftUI

public protocol VGRCalloutVariantProtocol {
    associatedtype Body: View
    @MainActor func makeBody(configuration: VGRCallout.Configuration) -> Body
    
    typealias Configuration = VGRCallout.Configuration
}

public enum VGRCalloutVariant {
    case illustration(VGRIllustration)
    case icon(VGRIcon)
    case none
    
    func resolve() -> any VGRCalloutVariantProtocol {
        switch self {
        case .illustration(let illustration):
            return IllustrationCalloutVariant(illustration: illustration)
        case .icon(let icon):
            return IconCalloutVariant(icon: icon)
        case .none:
            return NoVisualCalloutVariant()
        }
    }
}

public struct VGRCallout: View {
    
    public struct Configuration {
        let header: AttributedString?
        let description: AttributedString
        let backgroundColor: Color
        let button: VGRButton?
        let dismiss: (() -> Void)?
    }
    
    private let configuration: Configuration
    private let variant: any VGRCalloutVariantProtocol
    
    public init(
        header: AttributedString? = nil,
        description: AttributedString,
        backgroundColor: Color = Color.Status.informationSurface,
        button: VGRButton? = nil,
        variant: VGRCalloutVariant = .none,
        dismiss: (() -> Void)? = nil
    ) {
        self.configuration = Configuration(
            header: header,
            description: description,
            backgroundColor: backgroundColor,
            button: button,
            dismiss: dismiss
        )
        self.variant = variant.resolve()
    }
    
    public var body: some View {
        AnyView(variant.makeBody(configuration: configuration))
    }
}

public struct IllustrationCalloutVariant: VGRCalloutVariantProtocol {
    let illustration: VGRIllustration
    
    @MainActor
    public func makeBody(configuration: VGRCallout.Configuration) -> some View {
        VStack (spacing: 16) {
            HStack (alignment: .top, spacing: 24) {
                
                HStack (alignment: .center) {
                    
                    illustration
                    
                    CalloutTextContent(configuration: configuration)
                }
                
                DismissButton(dismiss: configuration.dismiss)
                
            }
            
            configuration.button
            
        }
        .padding(16)
        .background(configuration.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .textCase(.none)
    }
}

public struct IconCalloutVariant: VGRCalloutVariantProtocol {
    let icon: VGRIcon
    
    @MainActor
    public func makeBody(configuration: VGRCallout.Configuration) -> some View {
        VStack (spacing: 16) {
            HStack (alignment: .top, spacing: 24) {
                
                icon
                
                CalloutTextContent(configuration: configuration)
                
                DismissButton(dismiss: configuration.dismiss)
                
            }
            
            configuration.button
            
        }
        .padding(16)
        .background(configuration.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .textCase(.none)
    }
}

public struct NoVisualCalloutVariant: VGRCalloutVariantProtocol {
    
    @MainActor
    public func makeBody(configuration: VGRCallout.Configuration) -> some View {
        VStack (spacing: 16) {
            HStack (alignment: .top, spacing: 24) {
                
                CalloutTextContent(configuration: configuration)
                
                DismissButton(dismiss: configuration.dismiss)
            }
            
            configuration.button
            
        }
        .padding(16)
        .background(configuration.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .textCase(.none)
    }
}

private struct CalloutTextContent: View {
    let configuration: VGRCallout.Configuration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let header = configuration.header {
                Text(header)
                    .font(.headline)
                    .foregroundStyle(Color.Neutral.text)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text(configuration.description)
                .font(.footnote)
                .foregroundStyle(Color.Neutral.text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DismissButton: View {
    let dismiss: (() -> Void)?
    
    var body: some View {
        if let dismiss {
            Button(action: dismiss) {
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "xmark")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(Color.Primary.action)
            }
        }
    }
}

#Preview {
    
    ScrollView {
        VGRShape (backgroundColor: Color.Primary.blueSurfaceMinimal) {
            
            Text("Designsystem: ")
                .padding()
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada. Ut eleifend, ex eget convallis suscipit.",
                button: VGRButton(label: "Knapptext", action: {
                    print("HEJ")
                }),
                variant: .icon(VGRIcon(assetName: "listsearch"))
            )
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada. Ut eleifend, ex eget convallis suscipit.",
                button: VGRButton(label: "Knapptext", action: {
                    print("HEJ")
                }),
                variant: .illustration(VGRIllustration(assetName: "illustration_presence")))
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada. Ut eleifend, ex eget convallis suscipit.",
                backgroundColor: Color.Status.warningSurface,
                button: VGRButton(label: "Knapptext", action: {
                    print("HEJ")
                })
            )
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada.",
                backgroundColor: Color.Status.warningSurface,
                button: VGRButton(label: "Knapptext", action: {
                    print("HEJ")
                }),
                variant: .illustration(VGRIllustration(assetName: "illustration_presence")))
            
            Text("Övriga varianter: ")
                .padding()
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada.",
                backgroundColor: Color.Status.warningSurface,
                button: VGRButton(label: "Läs mer", icon: Image(systemName: "heart")) {},
                variant: .illustration(VGRIllustration(assetName: "illustration_presenting")),
                dismiss: { print("Dismiss illustration") }
            )
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada.",
                button: VGRButton(label: "Visa mer", action: {}),
                variant: .icon(VGRIcon(assetName: "listsearch"))
            )
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada.",
                button: VGRButton(label: "OK", action: {}),
                dismiss: { print("Dismiss no visual") }
            )
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada.",
                button: VGRButton(label: "Inaktiv", isEnabled: .constant(false), action: {}),
                variant: .icon(VGRIcon(assetName: "listsearch"))
            )
            
            VGRCallout(
                header: try! AttributedString(markdown: "**Heading** med *blablabla*"),
                description: try! AttributedString(markdown: "Detta är en lång beskrivning med **Markdown**, *italic*, och [länk](https://vgr.se)."),
                button: VGRButton(label: "Fortsätt", icon: Image(systemName: "arrow.forward")) {},
                variant: .illustration(VGRIllustration(assetName: "illustration_presenting"))
            )
            
            VGRCallout(
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada."
            )
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada."
            )
            
            VGRCallout(
                header: "Heading",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada.",
                variant: .icon(VGRIcon(assetName: "chatbubble"))
            )
            
            VGRCallout(
                header: try! AttributedString(markdown: "Detta är en lång beskrivning med **Markdown**, *italic*, och [länk](https://vgr.se)."),
                description: try! AttributedString(markdown: "Detta är en lång beskrivning med **Markdown**, *italic*, och [länk](https://vgr.se)."),
                variant: .icon(VGRIcon(assetName: "chatbubble"))
            )
        }
    }
}
