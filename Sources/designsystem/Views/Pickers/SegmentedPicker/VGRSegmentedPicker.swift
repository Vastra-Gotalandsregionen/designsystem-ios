import Foundation
import SwiftUI

/// A customizable segmented picker component that displays a horizontal list of selectable items.
///
/// This component supports both scrollable and fixed layouts depending on the number of items and the specified non-scrollable count.
/// It allows customization of the display text and accessibility identifiers for each item.
/// Use this component when you need a compact selection control with customizable appearance and accessibility support.
///
/// - Features:
///   - Supports scrollable and fixed segmented controls.
///   - Customizable item width, display text, and accessibility identifiers.
///   - Highlights the selected item visually.
///
/// - Usage:
/// ```swift
/// // Scrollable segmented picker
/// VGRSegmentedPicker(items: ["One", "Two", "Three", "Four", "Five"], selectedItem: $selected)
///
/// // Non-scrollable segmented picker with fixed number of items
/// VGRSegmentedPicker(items: ["One", "Two", "Three", "Four", "Five"], nonScrollableItemCount: 5, selectedItem: $selected)
/// ```
public struct VGRSegmentedPicker<Item: Hashable>: View {

    /// The array of items to display in the segmented picker.
    let items: [Item]

    /// The number of items that should be displayed without scrolling (fixed layout).
    let nonScrollableItemCount: Int

    /// The ideal width for each item in the picker.
    let itemIdealWidth: CGFloat

    /// A closure that returns the display text for a given item.
    let displayText: (Item) -> String

    /// A closure that returns the accessibility identifier for a given item.
    let accessibilityId: (Item) -> String

    /// The currently selected item, bound to an external state.
    @Binding var selectedItem: Item?

    /// Creates a `VGRSegmentedPicker` with customizable items, layout, and display options.
    ///
    /// - Parameters:
    ///   - items: The array of items to display.
    ///   - nonScrollableItemCount: The number of items to display without scrolling (default is 4).
    ///   - itemIdealWidth: The ideal width for each item (default is 100).
    ///   - selectedItem: A binding to the currently selected item.
    ///   - displayText: A closure that returns the display string for each item.
    ///   - accessibilityId: A closure that returns the accessibility identifier for each item (default returns the string representation).
    public init(items: [Item],
                nonScrollableItemCount: Int = 4,
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

    /// The view body that renders the segmented picker.
    ///
    /// It uses `VGRBaseSegmentedControlView` to layout the items either scrollably or fixed depending on the `nonScrollableItemCount`.
    /// Each item is styled with text, background, and foreground colors based on selection state.
    public var body: some View {
        VGRBaseSegmentedControlView(items,
                                    nonScrollableItemCount: nonScrollableItemCount,
                                    insets: EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6),
                                    selectedItem: $selectedItem) { item, selected in
            Text(displayText(item))
                .frame(idealWidth: itemIdealWidth, maxWidth: .infinity)
                .font(.footnote)
                .fontWeight(selected ? .bold : .regular)
                .lineLimit(1)
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(selected ? Color.Primary.action : Color.clear)
                )
                .foregroundColor(selected ? Color.Elevation.elevation1 : Color.Primary.action)
                .accessibilityIdentifier(accessibilityId(item))

        }.background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.Elevation.elevation1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.Primary.action, lineWidth: 2)
        )
    }
}

/// Convenience initializer for `VGRSegmentedPicker` when the item type is `String`.
///
/// This extension provides backward compatibility by simplifying initialization for string arrays,
/// automatically using the string itself for display text and accessibility identifiers.
extension VGRSegmentedPicker where Item == String {
    public init(items: [String],
                nonScrollableItemCount: Int = 4,
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
    @Previewable @State var selectedItem: String?
    @Previewable @State var selectedItem2: String?

    let items: [String] = ["One", "Two", "Three", "Four", "Five"]

    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                VStack {
                    LabeledContent {
                        Text("Index: \(selectedItem ?? "n/a")")
                    } label: {
                        Text("Horizontally scrollable")
                    }
                    VGRSegmentedPicker(items: items, selectedItem: $selectedItem)
                }
                .padding(16)

                VStack {
                    LabeledContent {
                        Text("Index: \(selectedItem ?? "n/a")")
                    } label: {
                        Text("Fixed, 5 non-scrollable items")
                    }
                    VGRSegmentedPicker(
                        items: items,
                        nonScrollableItemCount: 5,
                        selectedItem: $selectedItem
                    )
                }
                .padding(16)

                VStack {
                    LabeledContent {
                        Text("Index: \(selectedItem2 ?? "n/a")")
                    } label: {
                        Text("Fixed (default 4 non-scrollable)")
                            .lineLimit(1)
                    }

                    VGRSegmentedPicker(items: Array(items.prefix(2)),
                                       selectedItem: $selectedItem2)
                }
                .padding(16)
            }
        }
        .navigationTitle("VGRSegmentedPicker")
    }
}
