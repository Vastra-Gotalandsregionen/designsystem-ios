import SwiftUI

/// Primär inverterad knappvariant — används på färgad bakgrund.
/// Vit yta med actionfärgad text.
public struct VGRButtonV2PrimaryInvertedVariant: VGRButtonV2VariantProtocol {
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
                             Color.Neutral.text :
                                Color.Neutral.textVariant)
            .padding(.horizontal, configuration.size.padding)
            .padding(.vertical, configuration.size.verticalPadding)
            .applyFullWidth(configuration.fullWidth)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(configuration.isEnabled ? Color.Primary.actionInverted : Color.Neutral.disabled)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        }
        .buttonStyle(.plain)
        .allowsHitTesting(configuration.isEnabled)
    }
}

#Preview("PrimaryInverted") {
    @Previewable @State var isEnabled: Bool = false

    NavigationStack {
        VGRContainer {
            VGRShape(backgroundColor: Color.Primary.action) {

                VGRSection(header: "PrimaryInverted") {
                    VGRButtonV2("Spara", variant: .primaryInverted) { }

                    VGRButtonV2("Spara med ikon",
                                variant: .primaryInverted,
                                systemImage: "tray.and.arrow.down") { }
                }

                VGRSection(header: "Sizes") {
                    VGRButtonV2("Medium",
                                variant: .primaryInverted,
                                size: .medium,
                                systemImage: "tray.and.arrow.down") { }
                    VGRButtonV2("Small",
                                variant: .primaryInverted,
                                size: .small,
                                systemImage: "tray.and.arrow.down") { }
                }

                VGRSection(header: "Disabled") {
                    VGRList {
                        VGRToggleRow(title: "State", isOn: $isEnabled)
                    }

                    VGRButtonV2(isEnabled ? "Aktiverad" : "Inaktiverad",
                                variant: .primaryInverted,
                                isEnabled: $isEnabled) { }

                    VGRButtonV2(isEnabled ? "Aktiverad" : "Inaktiverad",
                                variant: .primaryInverted,
                                size: .medium,
                                isEnabled: $isEnabled,
                                systemImage: "tray.and.arrow.down") { }

                }
            }
        }
        .navigationTitle("PrimaryInverted")
    }
}
