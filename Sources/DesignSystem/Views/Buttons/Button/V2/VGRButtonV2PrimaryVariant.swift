import SwiftUI

/// Primär knappvariant — fylld actionfärg, centrerad headline, fyller bredden.
public struct VGRButtonV2PrimaryVariant: VGRButtonV2VariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon
                    .accessibilityHidden(true)

                Text(configuration.label)
                    .font(configuration.size.font)
            }
            .foregroundStyle(configuration.isEnabled ?
                             Color.Neutral.textInverted :
                                Color.Neutral.disabledVariant)
            .padding(.horizontal, configuration.size.padding)
            .padding(.vertical, configuration.size.verticalPadding)
            .applyFullWidth(configuration.fullWidth)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(configuration.isEnabled ? Color.Primary.action : Color.Neutral.disabled)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        }
        .buttonStyle(.plain)
        .allowsHitTesting(configuration.isEnabled)
    }
}

#Preview("Primary") {
    @Previewable @State var isEnabled: Bool = false

    NavigationStack {
        VGRContainer {
            VGRSection(header: "Primary") {
                VGRButtonV2("Spara") { }

                VGRButtonV2("Spara med ikon") { } icon: {
                    Image(systemName: "tray.and.arrow.down")
                }
            }

            VGRSection(header: "Disabled") {
                VGRList {
                    VGRToggleRow(title: "State", isOn: $isEnabled)
                }

                VGRButtonV2(isEnabled ? "Aktiverad" : "Inaktiverad", isEnabled: $isEnabled) { }
                VGRButtonV2(isEnabled ? "Aktiverad" : "Inaktiverad", isEnabled: $isEnabled) { } icon: {
                    Image(systemName: "tray.and.arrow.down")
                }
            }

            VGRSection(header: "Sizes") {
                VGRButtonV2("Medium", size: .medium, systemImage: "tray.and.arrow.down") { }
                VGRButtonV2("Small",  size: .small,  systemImage: "tray.and.arrow.down") { }
            }

            VGRSection(header: "systemImage") {
                VGRButtonV2("Ladda ner", systemImage: "square.and.arrow.down") { }
            }

            VGRSection(header: "Hug content (fullWidth: false)") {
                HStack(spacing: .Margins.small) {
                    VGRButtonV2("Spara", fullWidth: false) { }
                    VGRButtonV2("Small", size: .small, fullWidth: false) { }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Primary")
    }
}
