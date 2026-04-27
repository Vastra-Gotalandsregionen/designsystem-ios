import SwiftUI

/// Destruktiv knappvariant — röd bakgrund med inverterad text.
/// Semantiken "användaren är på väg att ta bort något" är inbyggd.
public struct VGRButtonV2DestructiveVariant: VGRButtonV2VariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack(spacing: .Margins.xtraSmall) {
                configuration.icon.accessibilityHidden(true)
                Text(configuration.label)
                    .font(configuration.size.font)
            }
            .foregroundStyle(Color.Neutral.textInverted)
            .padding(.horizontal, configuration.size.padding)
            .padding(.vertical, configuration.size.verticalPadding)
            .applyFullWidth(configuration.fullWidth, alignment: .center)
            .background(Color.Status.errorText)
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!configuration.isEnabled)
    }
}

#Preview("Destructive") {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "Destructive") {
                VGRButtonV2("Ta bort", variant: .destructive) { }

                VGRButtonV2("Ta bort", variant: .destructive) { } icon: {
                    Image(systemName: "trash")
                }
            }

            VGRSection(header: "Sizes") {
                VGRButtonV2("Medium", variant: .destructive, size: .medium, systemImage: "trash") { }
                VGRButtonV2("Small",  variant: .destructive, size: .small,  systemImage: "trash") { }
            }
        }
        .navigationTitle("Destructive")
    }
}
