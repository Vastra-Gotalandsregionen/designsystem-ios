import SwiftUI

/// A stateless capsule chip used for compact, toggleable options (filters, tags,
/// body part details, etc).
///
/// The chip is purely visual and reads both of its states from the environment:
/// selection via the design system's `.selected(_:)` modifier and enabled/disabled
/// via SwiftUI's standard `.disabled(_:)`. Selected chips render filled with a
/// leading checkmark; unselected chips render outlined, showing `symbol` if one
/// is provided.
///
/// For a tappable chip, use ``VGRChipButton`` which wraps this view and adds
/// button behavior.
///
/// ### Usage
/// ```swift
/// VGRChip("Hårbotten")
///     .selected(true)
///
/// VGRChip("Favoriter", symbol: "heart")
///
/// VGRChip("Ej tillgänglig")
///     .disabled(true)
/// ```
public struct VGRChip: View {

    /// The chip's text label.
    public var title: String

    /// Optional SF Symbol shown before the title when the chip is unselected.
    /// When selected, the symbol is replaced by a checkmark.
    public var symbol: String = ""

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isSelected) private var isSelected

    /// Creates a chip.
    /// - Parameters:
    ///   - title: The chip's text label.
    ///   - symbol: Optional SF Symbol name shown when the chip is unselected.
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
