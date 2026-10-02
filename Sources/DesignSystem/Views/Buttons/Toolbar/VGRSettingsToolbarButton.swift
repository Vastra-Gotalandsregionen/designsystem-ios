import SwiftUI

public struct VGRSettingsToolbarButton<SheetContent: View>: View {
    private let iconColor: Color
    private let accessibilityLabel: String
    private let onOpen: (() -> Void)?
    private let content: () -> SheetContent

    @State private var isSettingsVisible = false

    public init(
        iconColor: Color = Color.Primary.action,
        accessibilityLabel: String,
        onOpen: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SheetContent
    ) {
        self.iconColor = iconColor
        self.accessibilityLabel = accessibilityLabel
        self.onOpen = onOpen
        self.content = content
    }

    public var body: some View {
        Button {
            isSettingsVisible.toggle()
        } label: {
            Image(systemName: "gearshape.fill")
                .foregroundStyle(iconColor)
        }
        .sheet(isPresented: $isSettingsVisible) {
            content()
                .interactiveDismissDisabled()
                .tint(Color.Primary.action)
        }
        .onChange(of: isSettingsVisible) { _, isVisible in
            if isVisible { onOpen?() }
        }
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    VGRSettingsToolbarButton(
        accessibilityLabel: "Inställningar",
        onOpen: { print("Öppnad") }
    ) {
        Text("Inställningar")
    }
}
