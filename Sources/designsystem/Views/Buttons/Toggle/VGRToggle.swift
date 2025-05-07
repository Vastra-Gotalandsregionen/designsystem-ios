import SwiftUI

/// En anpassad toggle-komponent enligt VGR:s designsystem.
///
/// Visar en titel, valfri beskrivning och en toggle med anpassat utseende.
/// Komponenten är byggd för att passa in visuellt med andra VGR-komponenter.
///
/// Exempel:
/// ```swift
/// @State var isOn = false
///
/// VGRToggle(isOn: $isOn, text: "Aktivera notiser", description: "Få en påminnelse varje dag.")
/// ```
public struct VGRToggle: View {
    
    /// Bindning till togglens tillstånd.
    @Binding var isOn: Bool
    
    /// Titeln som visas till vänster om togglen.
    let title: String
    
    /// En valfri beskrivningstext under titeln.
    let description: String
    
    /// - Parameters:
     ///   - isOn: En bindning till en `Bool` som styr togglens tillstånd.
     ///   - text: Huvudtexten som visas i komponenten.
     ///   - description: En valfri beskrivning som visas under huvudtexten.
    public init(isOn: Binding<Bool>, text: String, description: String = "") {
        self._isOn = isOn
        self.title = text
        self.description = description
    }
    
    public var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.Neutral.text)
                
                if !description.isEmpty {
                    Text(description)
                        .foregroundStyle(Color.Neutral.text)
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Rectangle()
                .foregroundColor(isOn ? Color.Primary.action : Color.Neutral.textVariant)
                .frame(width: 51, height: 31)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(2)
                        .offset(x: isOn ? 10 : -10)
                        .animation(.easeOut(duration: 0.1), value: isOn)
                )
                .cornerRadius(20)
                .onTapGesture {
                    isOn.toggle()
                    Haptics.lightImpact() 
                }
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    @Previewable @State var isOn: Bool = false
    
    ScrollView {
        VGRShape {
            VStack (spacing: 32) {
                VGRToggle(isOn: $isOn, text: "Hej hopp")
                
                VGRToggle(isOn: $isOn, text: "Hej hopp", description: "Någon slags information")
            }
            .padding(.vertical, 32)
        }
    }
}
