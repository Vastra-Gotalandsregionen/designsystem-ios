import SwiftUI

public struct VGRCardButtonStyle: ButtonStyle {
    /// Creates a new content card button style.
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .rotation3DEffect(
                .degrees(configuration.isPressed ? 2 : 0),
                axis: (x: 1.0, y: 2.0, z: 0.0)
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
