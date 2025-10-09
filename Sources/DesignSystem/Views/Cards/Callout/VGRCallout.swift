import SwiftUI

/// En callout-vy som används för att visa informativa eller varningsmeddelanden med valfria ikoner, illustrationer och åtgärder.
/// Stöder olika layoutvarianter inklusive enkel, ikonbaserad och illustrationsbaserad presentation.
///

@available(*, deprecated, renamed: "VGRCalloutV2")
public struct VGRCallout: View {

    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    /// Definierar olika visuella stilar för callouten, stöder information och varning med valfria ikoner eller illustrationer.
    public enum CalloutVariant {
        case regular
        case illustration(VGRCalloutIllustration)
        case icon(VGRIcon)
    }
    
    let text: VGRCalloutText
    let button: VGRButton?
    let disclosureGroup: AnyView?
    let backgroundColor: Color
    let variant: CalloutVariant
    let dismiss: (() -> Void)?
    
    /// Initierar en `VGRCallout` med angivet innehåll och stil.
    /// - Parameters:
    ///   - text: Den huvudsakliga texten i callouten, inklusive valfri rubrik och beskrivning.
    ///   - button: En valfri åtgärdsknapp som visas under texten.
    ///   - variant: Den visuella varianten av callouten (t.ex. information, varning, med ikon eller illustration).
    ///   - dismiss: En valfri closure som anropas när callouten stängs.
    public init(
        text: VGRCalloutText,
        button: VGRButton? = nil,
        disclosureGroup: AnyView? = nil,
        backgroundColor: Color = Color.Status.informationSurface,
        variant: CalloutVariant,
        dismiss: (() -> Void)? = nil
    ) {
        self.text = text
        self.button = button
        self.disclosureGroup = disclosureGroup
        self.backgroundColor = backgroundColor
        self.variant = variant
        self.dismiss = dismiss
    }
    
    /// Den huvudsakliga vykroppen för `VGRCallout`, renderas med lämplig form och layout.
    public var body: some View {
        VGRCalloutShape(backgroundColor: backgroundColor) {
            
            content
            
            disclosureGroup
            
            button
        }
    }
    
    /// Den interna layoutlogiken som anpassar calloutens innehåll beroende på vald variant.
    @ViewBuilder
    var content: some View {
        switch variant {
        case .regular:
            HStack(alignment: .top, spacing: 16) {
                text
                if let dismiss = dismiss {
                    VGRCalloutDismissButton(dismiss: dismiss)
                }
            }
            
        case .icon(let icon):
            HStack(alignment: .top, spacing: 16) {
                icon
                text
                if let dismiss = dismiss {
                    VGRCalloutDismissButton(dismiss: dismiss)
                }
            }
            
        case .illustration(let illustration):
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

//MARK: This component is deprecated - Preview is commented out to reduce number of unescessary Xcode-warnings in the project.

//#Preview ("Information Callouts") {
//    
//    let description: VGRCalloutText = VGRCalloutText(description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada. Ut eleifend, ex eget convallis suscipit.")
//    
//    let descriptionWithHeader: VGRCalloutText = VGRCalloutText(header: "Lorem ipsum", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada. Ut eleifend, ex eget convallis suscipit.")
//    
//    let chatBubble: VGRIcon = VGRIcon(asset: "chatbubble")
//    
//    let button: VGRButton = VGRButton(label: "Action") {
//        print("Hello")
//    }
//    
//    let illustration: VGRCalloutIllustration = VGRCalloutIllustration(assetName: "illustration_presence")
//    
//    
//    ScrollView {
//        
//        VGRShape (backgroundColor: Color.Primary.blueSurfaceMinimal) {
//            
//            VStack (spacing: 32) {
//                
//                VGRCallout(
//                    text: description,
//                    variant: .icon(chatBubble)
//                )
//                
//                VGRCallout(
//                    text: descriptionWithHeader,
//                    variant: .icon(chatBubble)
//                )
//                
//                VGRCallout(
//                    text: description,
//                    disclosureGroup: AnyView(
//                        VGRDisclosureGroup(title: "Mer info") {
//                            Text("Blablablablalbalbal")
//                        }
//                    ),
//                    variant: .icon(chatBubble)
//                )
//                
//                VGRCallout(
//                    text: descriptionWithHeader,
//                    button: button, variant: .illustration(illustration)) {
//                        print("Dismiss")
//                    }
//                
//                //MARK: Used without pre-initialized components
//                VGRCallout(
//                    text: VGRCalloutText(
//                        header: "Akuta läkemedel",
//                        description: "Du har lagt in att du har tagit akuta läkemedel fler dagar än rekommenderat."),
//                    button: VGRButton(
//                        label: "Läs mer",
//                        action: {
//                            print("Läs mer")
//                        }),
//                    variant: .icon(VGRIcon(asset: "medicine")))
//            }
//        }
//        
//        VGRShape (backgroundColor: Color.Primary.blueSurfaceMinimal) {
//            
//            VStack (spacing: 32) {
//                
//                VGRCallout(
//                    text: description,
//                    variant: .regular
//                )
//                
//                VGRCallout(
//                    text: description,
//                    variant: .icon(chatBubble)
//                )
//                
//                VGRCallout(
//                    text: descriptionWithHeader,
//                    variant: .icon(chatBubble)
//                )
//                
//                VGRCallout(
//                    text: descriptionWithHeader,
//                    button: button, variant: .illustration(illustration)) {
//                        print("Dismiss")
//                    }
//            }
//        }
//    }
//}
//
//#Preview ("Warning Callouts") {
//    
//    ScrollView {
//        
//        VGRShape (backgroundColor: Color.Primary.blueSurfaceMinimal) {
//            
//            VStack (spacing: 32) {
//                
//                VGRCallout(text: VGRCalloutText(
//                    description: "Simplest version of the Callout-Component"),
//                           variant: .regular
//                )
//                
//                VGRCallout(text: VGRCalloutText(
//                    description: "Simple noteview with a long descriptive text very interesting and a lot of text keep going yes very interesting and informative"),
//                           variant: .icon(VGRIcon(source: .asset(name: "chatbubble", bundle: .module)))
//                )
//                
//                VGRCallout(text: VGRCalloutText(
//                    header: "This is a header!",
//                    description: "Same but with a header! Simple noteview with a long descriptive text very interesting and a lot of text keep going yes very interesting and informative"),
//                           variant: .icon(VGRIcon(source: .asset(name: "chatbubble", bundle: .module)))
//                )
//            }
//        }
//    }
//}
