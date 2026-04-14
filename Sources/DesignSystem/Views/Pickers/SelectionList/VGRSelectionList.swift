import SwiftUI

/// A vertically stacked list that lets the user pick one or more items from a set of options.
///
/// Each row pairs a circular checkmark indicator — drawn by the component — with a
/// caller-supplied label view. The component is generic over the item type; any
/// `Identifiable` value works, so callers can either use ``VGRSelectionListItem`` for the
/// simple case or pass their own domain model.
///
/// Selection is synced through a `Set` of item IDs, which also doubles as the
/// pre-selection mechanism — any IDs present in the set when the view appears
/// will be shown as selected.
///
/// The rendering is a plain `VStack`; it does not wrap itself in a `List`,
/// `ScrollView`, or `NavigationStack`. The caller is responsible for any
/// surrounding chrome (titles, headers, scroll container, etc.).
///
/// ### Usage
/// ```swift
/// @State private var selection: Set<String> = ["world"]
///
/// let items = [
///     VGRSelectionListItem(id: "hello", name: "Hello"),
///     VGRSelectionListItem(id: "world", name: "World"),
/// ]
///
/// VGRSelectionList(items: items, selection: $selection) { item in
///     Text(item.name)
///         .foregroundStyle(Color.Neutral.text)
///         .fontWeight(.medium)
/// }
/// ```
public struct VGRSelectionList<Item: Identifiable, Label: View>: View {

    /// The selectable items displayed in the list.
    public let items: [Item]

    /// Binding to the set of currently selected item IDs. Seed it with IDs to
    /// pre-select the corresponding items.
    @Binding public var selection: Set<Item.ID>

    /// Builds the label view shown to the right of the checkbox for a given item.
    public let label: (Item) -> Label

    /// Creates a selection list.
    /// - Parameters:
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the set of selected item IDs. Seed it with
    ///     IDs to pre-select the corresponding items.
    ///   - label: A view builder that produces the label shown next to the
    ///     checkbox for each item.
    public init(
        items: [Item],
        selection: Binding<Set<Item.ID>>,
        @ViewBuilder label: @escaping (Item) -> Label
    ) {
        self.items = items
        self._selection = selection
        self.label = label
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                VGRSelectionListRow(
                    isSelected: selection.contains(item.id),
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
        if selection.contains(item.id) {
            selection.remove(item.id)
        } else {
            selection.insert(item.id)
        }
    }
}

#Preview("VGRSelectionList") {

    @Previewable @State var selection: Set<String> = ["domination"]

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

                Text("Choose one or more items from the list below.")
                    .font(.headlineSemibold)
                    .padding(.horizontal, .Margins.medium)

                VGRSelectionList(items: items, selection: $selection) { item in
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
        .navigationTitle("VGRSelectionList")
        .navigationBarTitleDisplayMode(.inline)
    }
}
