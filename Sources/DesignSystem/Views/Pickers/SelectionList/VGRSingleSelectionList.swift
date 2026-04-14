import SwiftUI

/// A vertically stacked list that lets the user pick exactly one item from a set of options.
///
/// Each row shows the caller-supplied label on the leading edge and a
/// trailing checkmark — drawn by the component — that appears only on the
/// currently selected row. Unselected rows have no trailing indicator.
///
/// Tapping an unselected row reassigns the selection to that row. Tapping
/// the already-selected row clears the selection (the binding becomes
/// `nil`), mirroring the toggle semantics of ``VGRMultiSelectionList``. If
/// your flow should never allow an empty selection, seed the binding with an
/// initial value and ignore the `nil` case in your own state.
///
/// The component is generic over the item type; any `Identifiable` value
/// works, so callers can either use ``VGRSelectionListItem`` for the simple
/// case or pass their own domain model.
///
/// The rendering is a plain `VStack`; it does not wrap itself in a `List`,
/// `ScrollView`, or `NavigationStack`. The caller is responsible for any
/// surrounding chrome (titles, headers, scroll container, etc.).
///
/// For multi-choice selection, use ``VGRMultiSelectionList`` instead.
///
/// ### Usage
/// ```swift
/// @State private var selection: String? = "world"
///
/// let items = [
///     VGRSelectionListItem(id: "hello", name: "Hello"),
///     VGRSelectionListItem(id: "world", name: "World"),
/// ]
///
/// VGRSingleSelectionList(items: items, selection: $selection) { item in
///     Text(item.name)
///         .foregroundStyle(Color.Neutral.text)
///         .fontWeight(.medium)
/// }
/// ```
public struct VGRSingleSelectionList<Item: Identifiable, Label: View>: View {

    /// The selectable items displayed in the list.
    public let items: [Item]

    /// Binding to the currently selected item ID, or `nil` if nothing is
    /// selected. Seed it before presenting to pre-select an item.
    @Binding public var selection: Item.ID?

    /// Builds the label view shown on the leading edge of each row.
    public let label: (Item) -> Label

    /// Creates a single-selection list.
    /// - Parameters:
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the selected item ID. Seed it with an ID
    ///     to pre-select the corresponding item, or `nil` for no selection.
    ///   - label: A view builder that produces the label shown on the
    ///     leading edge of each row.
    public init(
        items: [Item],
        selection: Binding<Item.ID?>,
        @ViewBuilder label: @escaping (Item) -> Label
    ) {
        self.items = items
        self._selection = selection
        self.label = label
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                VGRSingleSelectionListRow(
                    isSelected: selection == item.id,
                    toggle: { toggle(item) }
                ) {
                    label(item)
                }

                if items.last?.id != item.id {
                    VGRDivider()
                }
            }
        }
    }

    private func toggle(_ item: Item) {
        if selection == item.id {
            selection = nil
        } else {
            selection = item.id
        }
    }
}

#Preview("VGRSingleSelectionList") {

    @Previewable @State var selection: String? = nil

    let items = [
        VGRSelectionListItem(name: "Hello"),
        VGRSelectionListItem(name: "World"),
        VGRSelectionListItem(name: "Domination"),
        VGRSelectionListItem(name: "Series"),
        VGRSelectionListItem(name: "Deluxe"),
    ]

    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: .Margins.medium) {

                Text("Choose one item from the list below.")
                    .font(.headlineSemibold)
                    .padding(.horizontal, .Margins.medium)

                VGRSingleSelectionList(items: items, selection: $selection) { item in
                    Text(item.name)
                        .foregroundStyle(Color.Neutral.text)
                        .fontWeight(.medium)
                        .padding(.vertical, .Margins.medium)
                }
                .background(Color.Elevation.elevation1)
                .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            }
            .padding(.horizontal, .Margins.medium)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRSingleSelectionList")
        .navigationBarTitleDisplayMode(.inline)
    }
}
