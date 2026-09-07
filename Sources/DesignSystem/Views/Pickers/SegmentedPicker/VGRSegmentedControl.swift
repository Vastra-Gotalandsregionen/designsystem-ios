import Foundation
import SwiftUI

/// A capsule-shaped segmented control that displays a horizontal list of selectable items.
///
/// Visually distinct from ``VGRSegmentedPicker``: the container is a fully rounded capsule
/// with a thin border, and the selected item renders as a filled capsule with a leading
/// checkmark, similar to ``VGRChip``.
///
/// This component supports both scrollable and fixed layouts depending on the number of items
/// and the specified non-scrollable count.
///
/// - Features:
///   - Capsule container with chip-style filled selection including a checkmark.
///   - Supports scrollable and fixed layouts.
///   - Customizable item width, display text, and accessibility identifiers.
///
/// - Usage:
/// ```swift
/// // Fixed segmented control with two items
/// VGRSegmentedControl(items: ["One", "Two"], selectedItem: $selected)
///
/// // Non-scrollable segmented control with five items
/// VGRSegmentedControl(items: items, nonScrollableItemCount: 5, selectedItem: $selected)
/// ```
public struct VGRSegmentedControl<Item: Hashable>: View {

    /// The array of items to display in the segmented control.
    let items: [Item]

    /// The number of items that should be displayed without scrolling (fixed layout).
    let nonScrollableItemCount: Int

    /// The ideal width for each item in the control.
    let itemIdealWidth: CGFloat

    /// A closure that returns the display text for a given item.
    let displayText: (Item) -> String

    /// A closure that returns the accessibility identifier for a given item.
    let accessibilityId: (Item) -> String

    /// The currently selected item, bound to an external state.
    @Binding var selectedItem: Item?

    /// Creates a `VGRSegmentedControl` with customizable items, layout, and display options.
    ///
    /// - Parameters:
    ///   - items: The array of items to display.
    ///   - nonScrollableItemCount: The number of items to display without scrolling (default is 5).
    ///   - itemIdealWidth: The ideal width for each item (default is 100).
    ///   - selectedItem: A binding to the currently selected item.
    ///   - displayText: A closure that returns the display string for each item.
    ///   - accessibilityId: A closure that returns the accessibility identifier for each item (default returns the string representation).
    public init(items: [Item],
                nonScrollableItemCount: Int = 5,
                itemIdealWidth: CGFloat = 100,
                selectedItem: Binding<Item?>,
                displayText: @escaping (Item) -> String,
                accessibilityId: @escaping (Item) -> String = { "\($0)" }) {
        self.items = items
        self.nonScrollableItemCount = nonScrollableItemCount
        self.itemIdealWidth = itemIdealWidth
        self.displayText = displayText
        self.accessibilityId = accessibilityId
        self._selectedItem = selectedItem
    }

    public var body: some View {
        VGRBaseSegmentedControlView(items,
                                    nonScrollableItemCount: nonScrollableItemCount,
                                    insets: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4),
                                    selectedItem: $selectedItem) { item, selected in
            HStack(spacing: .Margins.xtraSmall / 2) {
                if selected {
                    Image(systemName: "checkmark")
                        .accessibilityHidden(true)
                }

                Text(displayText(item))
                    .lineLimit(1)
            }
            .font(.subheadline)
            .fontWeight(selected ? .semibold : .regular)
            .frame(idealWidth: itemIdealWidth, maxWidth: .infinity)
            .padding(.horizontal, .Margins.small)
            .padding(.vertical, .Margins.xtraSmall)
            .background(
                Capsule()
                    .fill(selected ? Color.Primary.action : Color.clear)
            )
            .foregroundStyle(selected ? Color.Neutral.textInverted : Color.Neutral.text)
            .accessibilityAddTraits(selected ? .isSelected : [])
            .accessibilityIdentifier(accessibilityId(item))

        }.background(
            Capsule()
                .fill(Color.Elevation.elevation1)
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.Neutral.border, lineWidth: 1)
        )
    }
}

/// Convenience initializer for `VGRSegmentedControl` when the item type is `String`.
///
/// Simplifies initialization for string arrays, automatically using the string itself
/// for display text and accessibility identifiers.
extension VGRSegmentedControl where Item == String {
    public init(items: [String],
                nonScrollableItemCount: Int = 5,
                itemIdealWidth: CGFloat = 100,
                selectedItem: Binding<String?>) {
        self.init(items: items,
                  nonScrollableItemCount: nonScrollableItemCount,
                  itemIdealWidth: itemIdealWidth,
                  selectedItem: selectedItem,
                  displayText: { $0 },
                  accessibilityId: { $0 })
    }
}

#Preview {
    @Previewable @State var selectedItem2: String?
    @Previewable @State var selectedItem3: String?
    @Previewable @State var selectedItem4: String?
    @Previewable @State var selectedItem5: String?
    @Previewable @State var selectedItemScrollable: String?

    let items: [String] = ["One", "Two", "Three", "Four", "Five", "Six", "Seven"]

    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                VGRSegmentedControl(items: Array(items.prefix(2)),
                                    selectedItem: $selectedItem2)

                VGRSegmentedControl(items: Array(items.prefix(3)),
                                    selectedItem: $selectedItem3)

                VGRSegmentedControl(items: Array(items.prefix(4)),
                                    selectedItem: $selectedItem4)

                VGRSegmentedControl(items: Array(items.prefix(5)),
                                    selectedItem: $selectedItem5)

                VStack {
                    LabeledContent {
                        Text("\(selectedItemScrollable ?? "n/a")")
                    } label: {
                        Text("Horizontally scrollable")
                    }
                    VGRSegmentedControl(items: items,
                                        selectedItem: $selectedItemScrollable)
                }
            }
            .padding(16)
        }
        .navigationTitle("VGRSegmentedControl")
    }
}
