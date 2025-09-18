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

    /// För att hantera tillstånd där komponenten är satt som .disabled(true)
    @Environment(\.isEnabled) private var isEnabled

    /// Skalbara mått, för att hantera uppskalning
    @ScaledMetric private var toggleContainerHeight: CGFloat = 31
    @ScaledMetric private var toggleContainerWidth: CGFloat = 51
    @ScaledMetric private var toggleContainerCornerRadius: CGFloat = 20
    @ScaledMetric private var toggleLeverOffset: CGFloat = 10
    @ScaledMetric private var toggleLeverPadding: CGFloat = 2

    private let disabledOpacity: CGFloat = 0.5

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
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(isEnabled ? 1 : disabledOpacity)

            Rectangle()
                .foregroundColor(isOn ? Color.Primary.action : Color.Neutral.textVariant)
                .opacity(isEnabled ? 1 : disabledOpacity)
                .frame(width: toggleContainerWidth, height: toggleContainerHeight)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(toggleLeverPadding)
                        .offset(x: isOn ? toggleLeverOffset : -toggleLeverOffset)
                        .animation(.easeOut(duration: 0.2), value: isOn)
                )
                .cornerRadius(toggleContainerCornerRadius)
                .onTapGesture {
                    isOn.toggle()
                    Haptics.lightImpact() 
                }
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isToggle)
        .accessibilityAddTraits(isOn ? .isSelected : [])
        .accessibilityRespondsToUserInteraction(true)
        .accessibilityLabel(title + (description.isEmpty ? "" : ", \(description)"))
        .accessibilityValue(
            LocalizedHelper.localized(forKey: isOn ? "general.on" : "general.off")
        )
        .accessibilityHint(
            LocalizedHelper.localized(
                forKey: "toggle.a11y.hint"
            ) + " " + LocalizedHelper.localized(
                forKey: isOn ? "general.off" : "general.on"
            )
        )
        .onTapGesture {
            guard isEnabled else { return }
            isOn.toggle()
            Haptics.lightImpact()
        }
        .accessibilityAction {
            guard isEnabled else { return }
            isOn.toggle()
            Haptics.lightImpact()
        }
    }
}

#Preview {
    @Previewable @State var isOn: Bool = false
    
    ScrollView {
        VGRShape {
            VStack (spacing: 32) {
                VGRToggle(isOn: $isOn, text: "Hej hopp")
                
                VGRToggle(isOn: $isOn, text: "Hej hopp", description: "Någon slags information")

                VGRToggle(isOn: $isOn, text: "Hej hopp", description: "Någon slags information igen")
                    .disabled(true)
            }
            .padding(.vertical, 32)
        }
    }
}
