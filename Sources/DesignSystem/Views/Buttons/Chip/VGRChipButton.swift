import SwiftUI

/// An interactive wrapper around ``VGRChip``.
///
/// The chip visual reads its selected state from the environment, so callers can
/// either drive selection externally via the `.selected(_:)` modifier and react in
/// `action`, or hand the button a `Binding<Bool>` and let it toggle itself.
///
/// ### Usage
/// ```swift
/// /// Externally driven selection (e.g. membership in a Set)
/// VGRChipButton("Öron") {
///     toggle("head.ears")
/// }
/// .selected(selection.contains("head.ears"))
///
/// /// Self-toggling via binding
/// VGRChipButton("Hårbotten", isSelected: $showsScalp)
/// ```
public struct VGRChipButton: View {

    private let title: String
    private let symbol: String
    private let isSelected: Binding<Bool>?
    private let action: () -> Void

    /// Creates a chip button whose selected state is provided from the outside
    /// using the `.selected(_:)` modifier.
    /// - Parameters:
    ///   - title: The chip's text label.
    ///   - symbol: Optional SF Symbol shown when the chip is unselected.
    ///   - action: Closure executed when the chip is tapped.
    public init(_ title: String, symbol: String = "", action: @escaping () -> Void) {
        self.title = title
        self.symbol = symbol
        self.isSelected = nil
        self.action = action
    }

    /// Creates a self-toggling chip button bound to a boolean.
    /// - Parameters:
    ///   - title: The chip's text label.
    ///   - symbol: Optional SF Symbol shown when the chip is unselected.
    ///   - isSelected: Binding toggled on every tap.
    ///   - action: Optional closure executed after the binding is toggled.
    public init(_ title: String, symbol: String = "", isSelected: Binding<Bool>, action: @escaping () -> Void = {}) {
        self.title = title
        self.symbol = symbol
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        if let isSelected {
            button.selected(isSelected.wrappedValue)
        } else {
            button
        }
    }

    private var button: some View {
        Button {
            isSelected?.wrappedValue.toggle()
            action()
        } label: {
            VGRChip(title, symbol: symbol)
        }
        .buttonStyle(.plain)
        .transaction { $0.animation = nil }
    }
}

#Preview {
    @Previewable @State var isSelected: Bool = false
    @Previewable @State var selection: Set<String> = ["Nacke"]

    let parts = ["Hårbotten", "I ansiktet", "Nacke", "Hals", "Öron", "Ögon", "Annan detalj"]

    NavigationStack {
        VGRContainer {
            VGRSection(header: "Binding") {
                VGRFlowLayout {
                    VGRChipButton("Label", isSelected: $isSelected)

                    VGRChipButton("Label", symbol: "heart", isSelected: $isSelected)

                    VGRChipButton("Label", isSelected: $isSelected)
                        .disabled(true)
                }
            }

            VGRSection(header: "Action + selected(_:)") {
                VGRFlowLayout {
                    ForEach(parts, id: \.self) { part in
                        VGRChipButton(part) {
                            selection.formSymmetricDifference([part])
                        }
                        .selected(selection.contains(part))
                    }
                }
            }
        }
        .navigationTitle("VGRChipButton")
        .navigationBarTitleDisplayMode(.inline)
    }
}
