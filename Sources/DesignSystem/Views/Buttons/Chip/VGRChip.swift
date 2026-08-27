import SwiftUI

public struct VGRChip: View {

    public var title: String
    public var symbol: String = ""

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isSelected) private var isSelected

    public init(_ title: String, symbol: String = "") {
        self.title = title
        self.symbol = symbol
    }

    var backgroundColor: Color { isSelected ? (isEnabled ? .Primary.action : .Neutral.disabledVariant) : .clear }

    var textColor: Color { !isEnabled ? .Neutral.disabled : (isSelected ? .Neutral.textInverted : .Primary.action) }

    var borderColor: Color { isSelected ? .clear : (!isEnabled ? .Neutral.disabled : .Neutral.divider) }

    var imageSymbol: String { isSelected ? "checkmark" : symbol }

    var hasSymbol: Bool { !imageSymbol.isEmpty }

    public var body: some View {
        HStack(spacing: .Margins.xtraSmall / 2) {
            Image(systemName: imageSymbol)
                .isVisible(hasSymbol)
                .accessibilityHidden(true)

            Text(title)
                .font(.subheadline)
        }
        .padding(.horizontal, .Margins.medium)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .foregroundStyle(textColor)
        .cornerRadius(.Radius.mainRadius)
        .overlay {
            RoundedRectangle(cornerRadius: .Radius.mainRadius)
                .strokeBorder(borderColor, style: .init(lineWidth: 1))
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRFlowLayout {
                    VGRChip("Label")

                    VGRChip("Label", symbol: "heart")

                    VGRChip("Label", symbol: "heart")
                        .disabled(true)

                    VGRChip("Label")
                        .selected(true)

                    VGRChip("Label", symbol: "heart")
                        .selected(true)

                    VGRChip("Label")
                        .disabled(true)
                        .selected(true)
                }
            }
        }
        .navigationTitle("VGRChip")
        .navigationBarTitleDisplayMode(.inline)
    }
}
