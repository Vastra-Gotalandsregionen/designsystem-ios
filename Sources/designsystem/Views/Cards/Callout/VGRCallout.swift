import SwiftUI

/// A callout view used to display informative or warning messages with optional icons, illustrations, and actions.
/// Supports different layout variants including plain, icon-based, and illustration-based appearances.
struct VGRCallout: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    /// Defines different visual styles for the callout, supporting information and warning types with optional icons or illustrations.
    public enum CalloutVariant {
        case information
        case informationWithIllustration(VGRIllustration)
        case informationWithIcon(VGRIcon)
        case warning
        case warningWithIllustration(VGRIllustration)
        case warningWithIcon(VGRIcon)
    }
    
    /// Maps the `CalloutVariant` to a corresponding `CalloutShapeVariant`.
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
    
    /// Initializes a `VGRCallout` with the given content and style.
    /// - Parameters:
    ///   - text: The main content text of the callout, including optional header and description.
    ///   - button: An optional action button shown beneath the text.
    ///   - variant: The visual variant of the callout (e.g. information, warning, with icon or illustration).
    ///   - dismiss: An optional closure called when the callout is dismissed.
    public init(text: VGRCalloutText,
                button: VGRButton? = nil,
                variant: CalloutVariant,
                dismiss: (() -> Void)? = nil) {
        self.variant = variant
        self.text = text
        self.button = button
        self.dismiss = dismiss
    }
    
    /// The main view body of the `VGRCallout`, rendered with appropriate shape and content layout.
    var body: some View {
        VGRCalloutShape(variant: shape) {
            
            content
            
            button
        }
    }
    
    /// The internal layout logic that adapts the callout's content based on its variant.
    @ViewBuilder
    var content: some View {
        switch variant {
        case .information, .warning:
            HStack(alignment: .top, spacing: 16) {
                text
                VGRCalloutDismissButton(dismiss: dismiss)
            }
            
        case .informationWithIcon(let icon), .warningWithIcon(let icon):
            HStack(alignment: .top, spacing: 16) {
                icon
                text
                VGRCalloutDismissButton(dismiss: dismiss)
            }
            
        case .informationWithIllustration(let illustration), .warningWithIllustration(let illustration):
            Group {
                if dynamicTypeSize >= .xxxLarge {
                    HStack(alignment: .top, spacing: 16) {
                        VStack (alignment: .leading) {
                            illustration
                            text
                        }
                        VGRCalloutDismissButton(dismiss: dismiss)
                    }
                } else {
                    HStack(alignment: .top, spacing: 16) {
                        HStack(alignment: .center, spacing: 16) {
                            illustration
                            text
                        }
                        VGRCalloutDismissButton(dismiss: dismiss)
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
    
    let illustration: VGRIllustration = VGRIllustration(assetName: "illustration_presence")

    
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
