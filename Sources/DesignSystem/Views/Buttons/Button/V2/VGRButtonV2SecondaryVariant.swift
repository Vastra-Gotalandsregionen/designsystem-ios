import SwiftUI

/// Sekundär knappvariant — outlined actionfärg, centrerad headline.
public struct VGRButtonV2SecondaryVariant: VGRButtonV2VariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon
                    .accessibilityHidden(true)

                Text(configuration.label)
                    .font(configuration.size.font)
            }
            .foregroundStyle(configuration.isEnabled ? Color.Primary.action : Color.Neutral.disabled)
            .padding(.horizontal, configuration.size.padding)
            .padding(.vertical, configuration.size.verticalPadding)
            .applyFullWidth(configuration.fullWidth)
            .overlay(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .strokeBorder(configuration.isEnabled ? Color.Primary.action : Color.Neutral.disabled,
                                  lineWidth: 2)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        }
        .buttonStyle(.plain)
        .disabled(!configuration.isEnabled)
    }
}

#Preview("Secondary") {
    @Previewable @State var isEnabled: Bool = false

    NavigationStack {
        VGRContainer {
            VGRSection(header: "Secondary") {
                VGRButtonV2("Spara", variant: .secondary) { }

                VGRButtonV2("Spara med ikon", variant: .secondary) { } icon: {
                    Image(systemName: "tray.and.arrow.down")
                }
            }

            VGRSection(header: "Disabled") {
                VGRList {
                    VGRToggleRow(title: "State", isOn: $isEnabled)
                }

                VGRButtonV2(isEnabled ? "Aktiverad" : "Inaktiverad",
                            variant: .secondary,
                            isEnabled: $isEnabled) { }
                VGRButtonV2(isEnabled ? "Aktiverad" : "Inaktiverad",
                            variant: .secondary,
                            isEnabled: $isEnabled) { } icon: {
                    Image(systemName: "tray.and.arrow.down")
                }
            }

            VGRSection(header: "Sizes") {
                VGRButtonV2("Medium", variant: .secondary, size: .medium, systemImage: "xmark") { }
                VGRButtonV2("Small",  variant: .secondary, size: .small,  systemImage: "xmark") { }
            }

            VGRSection(header: "systemImage") {
                VGRButtonV2("Avbryt", variant: .secondary, systemImage: "xmark.circle") { }
            }

            VGRSection(header: "Hug content (fullWidth: false)") {
                HStack(spacing: .Margins.small) {
                    VGRButtonV2("Spara", variant: .secondary, fullWidth: false) { }
                    VGRButtonV2("Small", variant: .secondary, size: .small, fullWidth: false) { }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Secondary")
    }
}
