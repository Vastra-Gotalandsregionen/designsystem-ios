import SwiftUI

/// En callout-vy som används för att visa informativa eller varningsmeddelanden med valfria ikoner, illustrationer och åtgärder.
/// Stöder olika layoutvarianter inklusive enkel, ikonbaserad och illustrationsbaserad presentation.
public struct VGRCallout: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    /// Definierar olika visuella stilar för callouten, stöder information och varning med valfria ikoner eller illustrationer.
    public enum CalloutVariant {
        case information
        case informationWithIllustration(VGRCalloutIllustration)
        case informationWithIcon(VGRIcon)
        case warning
        case warningWithIllustration(VGRCalloutIllustration)
        case warningWithIcon(VGRIcon)
    }
    
    /// Översätter `CalloutVariant` till motsvarande `CalloutShapeVariant`.
    var shape: CalloutShapeVariant {
        switch variant {
        case .information, .informationWithIllustration(_), .informationWithIcon(_):
            return .information
        case .warning, .warningWithIllustration(_), .warningWithIcon(_):
            return .warning
        }
    }
    
    let text: VGRCalloutText
    let button: VGRButton?
    let variant: CalloutVariant
    let dismiss: (() -> Void)?
    
    /// Initierar en `VGRCallout` med angivet innehåll och stil.
    /// - Parameters:
    ///   - text: Den huvudsakliga texten i callouten, inklusive valfri rubrik och beskrivning.
    ///   - button: En valfri åtgärdsknapp som visas under texten.
    ///   - variant: Den visuella varianten av callouten (t.ex. information, varning, med ikon eller illustration).
    ///   - dismiss: En valfri closure som anropas när callouten stängs.
    public init(text: VGRCalloutText,
                button: VGRButton? = nil,
                variant: CalloutVariant,
                dismiss: (() -> Void)? = nil) {
        self.variant = variant
        self.text = text
        self.button = button
        self.dismiss = dismiss
    }
    
    /// Den huvudsakliga vykroppen för `VGRCallout`, renderas med lämplig form och layout.
    public var body: some View {
        VGRCalloutShape(variant: shape) {
            
            content
            
            button
        }
    }
    
    /// Den interna layoutlogiken som anpassar calloutens innehåll beroende på vald variant.
    @ViewBuilder
    var content: some View {
        switch variant {
        case .information, .warning:
            HStack(alignment: .top, spacing: 16) {
                text
                if let dismiss = dismiss {
                    VGRCalloutDismissButton(dismiss: dismiss)
                }
            }
            
        case .informationWithIcon(let icon), .warningWithIcon(let icon):
            HStack(alignment: .top, spacing: 16) {
                icon
                text
                if let dismiss = dismiss {
                    VGRCalloutDismissButton(dismiss: dismiss)
                }
            }
            
        case .informationWithIllustration(let illustration), .warningWithIllustration(let illustration):
            Group {
                if dynamicTypeSize >= .xxxLarge {
                    HStack(alignment: .top, spacing: 16) {
                        VStack (alignment: .leading) {
                            illustration
                            text
                        }
                        if let dismiss = dismiss {
                            VGRCalloutDismissButton(dismiss: dismiss)
                        }
                    }
                } else {
                    HStack(alignment: .top, spacing: 16) {
                        HStack(alignment: .center, spacing: 16) {
                            illustration
                            text
                        }
                        if let dismiss = dismiss {
                            VGRCalloutDismissButton(dismiss: dismiss)
                        }
                    }
                }
            }
        }
    }
}

#Preview ("Information Callouts") {
    
    let description: VGRCalloutText = VGRCalloutText(description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada. Ut eleifend, ex eget convallis suscipit.")
    
    let descriptionWithHeader: VGRCalloutText = VGRCalloutText(header: "Lorem ipsum", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada. Ut eleifend, ex eget convallis suscipit.")
    
    let chatBubble: VGRIcon = VGRIcon(asset: "chatbubble")
    
    let button: VGRButton = VGRButton(label: "Action") {
        print("Hello")
    }
    
    let illustration: VGRCalloutIllustration = VGRCalloutIllustration(assetName: "illustration_presence")
    
    
    ScrollView {
        
        VGRShape (backgroundColor: Color.Primary.blueSurfaceMinimal) {
            
            VStack (spacing: 32) {
                
                VGRCallout(
                    text: description,
                    variant: .informationWithIcon(chatBubble)
                )
                
                VGRCallout(
                    text: descriptionWithHeader,
                    variant: .informationWithIcon(chatBubble)
                )
                
                VGRCallout(
                    text: descriptionWithHeader,
                    button: button, variant: .informationWithIllustration(illustration)) {
                        print("Dismiss")
                    }
                
                //MARK: Used without pre-initialized components
                VGRCallout(
                    text: VGRCalloutText(
                        header: "Akuta läkemedel",
                        description: "Du har lagt in att du har tagit akuta läkemedel fler dagar än rekommenderat."),
                    button: VGRButton(
                        label: "Läs mer",
                        action: {
                            print("Läs mer")
                        }),
                    variant: .informationWithIcon(VGRIcon(asset: "medicine")))
            }
        }
        
        VGRShape (backgroundColor: Color.Primary.blueSurfaceMinimal) {
            
            VStack (spacing: 32) {
                
                VGRCallout(
                    text: description,
                    variant: .warning
                )
                
                VGRCallout(
                    text: description,
                    variant: .warningWithIcon(chatBubble)
                )
                
                VGRCallout(
                    text: descriptionWithHeader,
                    variant: .warningWithIcon(chatBubble)
                )
                
                VGRCallout(
                    text: descriptionWithHeader,
                    button: button, variant: .warningWithIllustration(illustration)) {
                        print("Dismiss")
                    }
            }
        }
    }
}

#Preview ("Warning Callouts") {
    
    ScrollView {
        
        VGRShape (backgroundColor: Color.Primary.blueSurfaceMinimal) {
            
            VStack (spacing: 32) {
                
                VGRCallout(text: VGRCalloutText(
                    description: "Simplest version of the Callout-Component"),
                           variant: .warning
                )
                
                VGRCallout(text: VGRCalloutText(
                    description: "Simple noteview with a long descriptive text very interesting and a lot of text keep going yes very interesting and informative"),
                           variant: .warningWithIcon(VGRIcon(source: .asset(name: "chatbubble", bundle: .module)))
                )
                
                VGRCallout(text: VGRCalloutText(
                    header: "This is a header!",
                    description: "Same but with a header! Simple noteview with a long descriptive text very interesting and a lot of text keep going yes very interesting and informative"),
                           variant: .warningWithIcon(VGRIcon(source: .asset(name: "chatbubble", bundle: .module)))
                )
            }
        }
    }
}
