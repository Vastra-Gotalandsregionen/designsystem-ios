import SwiftUI

public struct VGRButtonV2VerticalPrimaryVariant: VGRButtonV2VariantProtocol {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            VStack(spacing: .Margins.xtraSmall) {
                configuration.icon.accessibilityHidden(true)
                Text(configuration.label).font(configuration.size.font)
            }
            .foregroundStyle(Color.Neutral.text)
            .padding(.horizontal, configuration.size.padding)
            .padding(.vertical, configuration.size.verticalPadding)
            .applyFullWidth(configuration.fullWidth, alignment: .center)
            .multilineTextAlignment(.center)
            .background(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .fill(Color.Neutral.dividerVariant)
            )
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .opacity(configuration.isEnabled ? 1 : 0.5)
        }
        .buttonStyle(VGRButtonV2BareStyle())
        .disabled(!configuration.isEnabled)
    }
}

#Preview("VerticalPrimary") {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "VerticalPrimary (Horizontal layout)") {
                HStack {
                    VGRButtonV2("Extra dos", variant: .verticalPrimary) { } icon: {
                        Image(systemName: "pill")
                    }
                    VGRButtonV2("Extra dos", variant: .verticalPrimary) { } icon: {
                        Image(systemName: "pill")
                    }
                    VGRButtonV2("Extra dos", variant: .verticalPrimary) { } icon: {
                        Image(systemName: "pill")
                    }
                    VGRButtonV2("Extra dos", variant: .verticalPrimary) { } icon: {
                        Image(systemName: "pill")
                    }
                }
            }

            VGRSection(header: "Sizes") {
                VGRButtonV2("Small", variant: .verticalPrimary, size: .small) { } icon: {
                    Image(systemName: "pill")
                }
                VGRButtonV2("Medium", variant: .verticalPrimary,
                            size: .medium) { } icon: {
                    Image(systemName: "pill")
                }
            }
        }
        .navigationTitle("VerticalPrimary")
    }
}
