import SwiftUI

/// Destruktiv inline-knappvariant — inline-åtgärd i en lista med röd text.
/// Semantiken "användaren är på väg att ta bort något" är inbyggd.
public struct VGRButtonV2DestructiveInlineVariant: VGRButtonV2VariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon.accessibilityHidden(true)
                Text(configuration.label).font(configuration.size.font)
            }
            .foregroundStyle(Color.Status.errorText)
            .padding(.horizontal, configuration.size.padding)
            .padding(.vertical, configuration.size.verticalPadding)
            .applyFullWidth(configuration.fullWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(Color.Elevation.elevation1)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!configuration.isEnabled)
    }
}

#Preview("DestructiveInline") {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "Destructive (inline i lista)") {
                VGRList {
                    VGRListRow(title: "Morgon", subtitle: "08:00")
                    VGRButtonV2("Ta bort", variant: .destructiveInline) { } icon: {
                        Image(systemName: "trash")
                    }
                }

                VGRButtonV2("Ta bort", variant: .destructiveInline) { } icon: {
                    Image(systemName: "trash")
                }
            }

            VGRSection(header: "Sizes") {
                VGRButtonV2("Medium", variant: .destructiveInline, size: .medium, systemImage: "trash") { }
                VGRButtonV2("Small",  variant: .destructiveInline, size: .small,  systemImage: "trash") { }
            }
        }
        .navigationTitle("DestructiveInline")
    }
}
