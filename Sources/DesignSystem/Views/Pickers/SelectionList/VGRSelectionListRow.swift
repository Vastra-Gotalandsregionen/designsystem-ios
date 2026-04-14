import SwiftUI


/// A single row in a ``VGRSelectionList``. Renders the checkmark indicator and
/// wraps the caller-supplied label in a tappable button. Kept as a separate
/// view so the parent's `body` stays small enough for the Swift type checker
/// to handle in reasonable time.
///
/// The checkmark explicitly opts out of implicit animations via
/// `.transaction { $0.animation = nil }` so toggling selection inside a
/// `withAnimation { ... }` block in surrounding code does not animate the
/// indicator.
public struct VGRSelectionListRow<Label: View>: View {

    @ScaledMetric private var symbolSize: CGFloat = 16

    let isSelected: Bool
    let toggle: () -> Void
    @ViewBuilder let label: () -> Label

    public var body: some View {
        Button(action: toggle) {
            HStack(spacing: .Margins.xtraSmall) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: symbolSize, height: symbolSize)
                    .foregroundColor(Color.Primary.action)
                    .accessibilityHidden(true)
                    .transaction { $0.animation = nil }

                label()
            }
            .maxLeading()
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
        VGRSelectionListRow(isSelected: true) {
            print("Toggle")
        } label: {
            Text("Label")
        }

        VGRDivider()

        VGRSelectionListRow(isSelected: false) {
            print("Toggle 2")
        } label: {
            Text("Label 2")
        }
    }

}
