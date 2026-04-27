import SwiftUI

/// Tonal knappvariant — tonad actionfärg på mjuk surface, centrerad headline, fyller bredden.
public struct VGRButtonV2TonalVariant: VGRButtonV2VariantProtocol {
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
                             Color.Primary.action :
                                Color.Neutral.disabled)
            .padding(.horizontal, configuration.size.padding)
            .padding(.vertical, configuration.size.verticalPadding)
            .applyFullWidth(configuration.fullWidth)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(
                        configuration.isEnabled ? Color.Primary.blueSurfaceMinimal : Color.Neutral.disabledVariant
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        }
        .buttonStyle(VGRButtonV2BareStyle())
        .allowsHitTesting(configuration.isEnabled)
    }
}

#Preview("Tonal") {
    @Previewable @State var isEnabled: Bool = false

    NavigationStack {
        VGRContainer {
            VGRSection(header: "Tonal") {
                VGRButtonV2("Spara", variant: .tonal) { }

                VGRButtonV2("Spara med ikon", variant: .tonal) { } icon: {
                    Image(systemName: "tray.and.arrow.down")
                }
            }

            VGRSection(header: "Disabled") {
                VGRList {
                    VGRToggleRow(title: "State", isOn: $isEnabled)
                }

                VGRButtonV2(isEnabled ? "Aktiverad" : "Inaktiverad",
                            variant: .tonal) { }
                    .disabled(!isEnabled)
                VGRButtonV2(isEnabled ? "Aktiverad" : "Inaktiverad",
                            variant: .tonal) { } icon: {
                    Image(systemName: "tray.and.arrow.down")
                }
                .disabled(!isEnabled)
            }

            VGRSection(header: "Sizes") {
                VGRButtonV2("Medium", variant: .tonal, size: .medium, systemImage: "tray.and.arrow.down") { }
                VGRButtonV2("Small",  variant: .tonal, size: .small,  systemImage: "tray.and.arrow.down") { }
            }

            VGRSection(header: "systemImage") {
                VGRButtonV2("Ladda ner", variant: .tonal, systemImage: "square.and.arrow.down") { }
            }

            VGRSection(header: "Hug content (fullWidth: false)") {
                HStack(spacing: .Margins.small) {
                    VGRButtonV2("Spara", variant: .tonal, fullWidth: false) { }
                    VGRButtonV2(
                        "Small",
                        variant: .tonal,
                        size: .small,
                        fullWidth: false,
                        systemImage: "gearshape"
                    ) {

                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Tonal")
    }
}
