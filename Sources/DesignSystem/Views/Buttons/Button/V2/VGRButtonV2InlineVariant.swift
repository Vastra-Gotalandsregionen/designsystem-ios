import SwiftUI

/// Inline-knappvariant — inline-åtgärd i en lista. Leading-alignad
/// bodyRegular, elevation1-bakgrund. Callern styr ikonens färg.
public struct VGRButtonV2InlineVariant: VGRButtonV2VariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon.accessibilityHidden(true)
                Text(configuration.label)
                    .font(configuration.size.font)
                    .foregroundStyle(Color.Neutral.text)
            }
            .foregroundStyle(Color.Primary.action)
            .padding(.horizontal, configuration.size.padding)
            .padding(.vertical, configuration.size.verticalPadding + .Margins.small / 2)
            .applyFullWidth(configuration.fullWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(Color.Elevation.elevation1)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .buttonStyle(VGRButtonV2BareStyle())
        .disabled(!configuration.isEnabled)
    }
}

#Preview("Inline") {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "Inline (i lista)") {
                VGRList {
                    VGRListRow(title: "Morgon", subtitle: "08:00")
                    VGRListRow(title: "Kväll", subtitle: "20:00")
                    VGRButtonV2("Lägg till ny", variant: .inline) { } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.Status.successText)
                    }
                }

                VGRButtonV2("Lägg till ny", variant: .inline) { } icon: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.Status.successText)
                }
            }

            VGRSection(header: "Sizes") {
                VGRButtonV2("Medium", variant: .inline, size: .medium, systemImage: "plus.circle.fill") { }
                VGRButtonV2("Small",  variant: .inline, size: .small,  systemImage: "plus.circle.fill") { }
            }
        }
        .navigationTitle("Inline")
    }
}
