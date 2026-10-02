import SwiftUI

/// Toolbar button with a filled gear icon for opening settings.
/// Renders the SF Symbol in `Color.Primary.action` and exposes the localized
/// "general.settings" string as its accessibility label, since the icon has no visible text.
public struct VGRSettingsButton: View {
    private let action: () -> Void

    public init(
        action: @escaping () -> Void
    ) {
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "gearshape.fill")
                .foregroundStyle(Color.Primary.action)
        }
        .accessibilityLabel("general.settings".localizedBundle)
    }
}

#Preview {
    NavigationStack {
        Text("general.settings".localizedBundle)
            .navigationTitle("general.settings".localizedBundle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    VGRSettingsButton(action: {})
                }
            }
    }
}
