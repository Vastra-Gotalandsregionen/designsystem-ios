import SwiftUI

/// A single row in a ``VGRSingleSelectionList``. Places the caller-supplied
/// label on the leading edge and a trailing checkmark that is shown only
/// when this row is the currently selected item. When the row is not
/// selected, no indicator is drawn — the trailing edge is empty. Kept as a
/// separate view so the parent's `body` stays small enough for the Swift
/// type checker to handle in reasonable time.
///
/// The checkmark explicitly opts out of implicit animations via
/// `.transaction { $0.animation = nil }` so reassigning selection inside a
/// `withAnimation { ... }` block in surrounding code does not animate the
/// indicator.
public struct VGRSingleSelectionListRow<Label: View>: View {

    @ScaledMetric private var symbolSize: CGFloat = 16

    let isSelected: Bool
    let toggle: () -> Void
    @ViewBuilder let label: () -> Label

    public var body: some View {
        Button(action: toggle) {
            HStack(spacing: .Margins.xtraSmall) {
                label()
                    .maxLeading()

                if isSelected {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: symbolSize, height: symbolSize)
                        .foregroundColor(Color.Primary.action)
                        .accessibilityHidden(true)
                        .transaction { $0.animation = nil }
                }
            }
            .padding(.horizontal, .Margins.medium)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    ScrollView {
        VGRSingleSelectionListRow(isSelected: true) {
            print("Toggle")
        } label: {
            Text("Label")
        }

        VGRDivider()

        VGRSingleSelectionListRow(isSelected: false) {
            print("Toggle 2")
        } label: {
            Text("Label 2")
        }
    }
}
