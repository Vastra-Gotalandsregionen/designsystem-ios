import SwiftUI

/// Sekundär inverterad knappvariant — outlined för färgad bakgrund.
/// Transparent yta med vit kontur och vit text.
public struct VGRButtonV2SecondaryInvertedVariant: VGRButtonV2VariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon
                    .accessibilityHidden(true)

                Text(configuration.label)
                    .font(configuration.size.font)
            }
            .foregroundStyle(
                configuration.isEnabled ? Color.Primary.actionInverted : Color.Neutral.disabled
            )
            .padding(.horizontal, configuration.size.padding)
            .padding(.vertical, configuration.size.verticalPadding)
            .applyFullWidth(configuration.fullWidth)
            .overlay(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .strokeBorder(configuration.isEnabled ? Color.Primary.actionInverted : Color.Neutral.disabled,
                                  lineWidth: 2)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        }
        .buttonStyle(VGRButtonV2BareStyle())
        .disabled(!configuration.isEnabled)
    }
}

#Preview("SecondaryInverted") {
    @Previewable @State var isEnabled: Bool = false

    NavigationStack {
        VGRContainer {
            VGRShape(backgroundColor: Color.Primary.action) {

                VGRSection(header: "SecondaryInverted") {
                    VGRButtonV2("Avbryt", variant: .secondaryInverted) { }

                    VGRButtonV2("Avbryt med ikon",
                                variant: .secondaryInverted,
                                systemImage: "xmark") { }
                }

                VGRSection(header: "Sizes") {
                    VGRButtonV2("Medium",
                                variant: .secondaryInverted,
                                size: .medium,
                                systemImage: "xmark") { }
                    VGRButtonV2("Small",
                                variant: .secondaryInverted,
                                size: .small,
                                systemImage: "xmark") { }
                }

                VGRSection(header: "Disabled") {
                    VGRList {
                        VGRToggleRow(title: "State", isOn: $isEnabled)
                    }

                    VGRButtonV2(isEnabled ? "Aktiverad" : "Inaktiverad",
                                variant: .secondaryInverted) { }
                        .disabled(!isEnabled)
                }
            }

        }
        .navigationTitle("SecondaryInverted")
    }
}
