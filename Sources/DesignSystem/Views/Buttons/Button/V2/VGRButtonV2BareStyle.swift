import SwiftUI

/// Bar `ButtonStyle` utan default-chrome. Renderar bara label och en
/// liten opacity-puff vid press. All visuell hantering av enabled/
/// disabled lämnas till varianten — systemet lägger ingen dim på toppen.
struct VGRButtonV2BareStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}
