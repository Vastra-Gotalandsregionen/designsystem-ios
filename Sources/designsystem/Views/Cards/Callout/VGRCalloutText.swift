import SwiftUI

/// En vy som visar stylad callout-text med valfri rubrik och obligatorisk beskrivning.
/// Används i `VGRCallout` för att presentera informativa eller varningsmeddelanden.
public struct VGRCalloutText: View {
    /// En valfri attributerad rubrik som visas överst i callouten.
    /// En obligatorisk attributerad beskrivning som visas under rubriken.
    public let header: AttributedString?
    public let description: AttributedString
    
    /// Skapar en `VGRCalloutText`-vy.
    /// - Parameters:
    ///   - header: Valfri rubrik stylad som en rubriktext.
    ///   - description: Obligatorisk beskrivning stylad som fotnot.
    public init(header: AttributedString? = nil,
                description: AttributedString) {
        self.header = header
        self.description = description
    }
    
    /// Komponerar den visuella layouten för rubriken och beskrivningen.
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let header = header {
                Text(header)
                    .font(.headline)
                    .foregroundStyle(Color.Neutral.text)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text(description)
                .font(.footnote)
                .foregroundStyle(Color.Neutral.text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    
    let markdown = """
ℹ️ **Information**

Läs vår [integritetspolicy](https://example.com) innan du fortsätter.  
**Observera:** Denna åtgärd är permanent. ⚠️
"""
    
    let markdownAlternative = """
**Så här gör du:**  

1. Öppna Inställningar  
2. Klicka på Sekretess  
3. Aktivera alternativet  

_Tips:_ Du kan alltid återställa detta senare.
"""
    
    let attributed = try? AttributedString(
        markdown: markdown,
        options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
    
    let attributedAlternative = try? AttributedString(
        markdown: markdownAlternative,
        options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        
    let text: VGRCalloutText = VGRCalloutText(
        header: try! AttributedString(markdown: "_Header_"),
        description: attributedAlternative!)
    
    ScrollView {
        VGRShape {
            VStack(spacing: 32) {
                VGRCalloutShape(variant: .information) {
                    VGRCalloutText(header: "Hello", description: "World")
                }
                VGRCalloutShape(variant: .warning) {
                    VGRCalloutText(header: "Hello", description: "World")
                }
                
                VGRCallout(text: text, button: VGRButton(label: "Tap meee", action: {
                    print("Tapped")
                }), variant: .informationWithIllustration(VGRIllustration(assetName: "illustration_presence"))) {
                    print("Dismissed")
                }
                
                VGRCalloutShape(variant: .information) {
                    let header: AttributedString = {
                        var string = AttributedString("Bold Header")
                        string.font = .system(size: 18, weight: .bold)
                        return string
                    }()
                    
                    let description: AttributedString = {
                        var string = AttributedString("This is a description with ")
                        var strong = AttributedString("mixed styles")
                        strong.foregroundColor = .blue
                        strong.underlineStyle = .single
                        return string + strong + AttributedString(".")
                    }()
                    
                    VGRCalloutText(header: header, description: description)
                }
                VGRCalloutShape(variant: .warning) {
                    let header: AttributedString = {
                        var string = AttributedString("⚠️ Attention")
                        string.font = .system(size: 16, weight: .semibold)
                        return string
                    }()
                    
                    let description: AttributedString = {
                        var string = AttributedString("Please read the ")
                        var keyword = AttributedString("guidelines")
                        keyword.foregroundColor = Color.Status.errorText
                        keyword.font = .body.bold()
                        return string + keyword + AttributedString(" carefully.")
                    }()
                    
                    VGRCalloutText(header: header, description: description)
                }
                
                VGRCalloutShape(variant: .warning) {
                    
                    VGRCalloutText(description: attributed!)
                    
                }
                
                VGRCalloutShape (variant: .information) {
                    VGRCalloutText(description: attributedAlternative!)
                }
            }
            .padding()
        }
    }
}
