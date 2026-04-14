import SwiftUI

/// A vertically stacked list that lets the user pick exactly one item from a set of options.
///
/// Each row shows the caller-supplied label on the leading edge and a
/// trailing checkmark — drawn by the component — that appears only on the
/// currently selected row. Unselected rows have no trailing indicator.
///
/// Tapping an unselected row reassigns the selection to that row. By
/// default, tapping the already-selected row is a no-op (classic radio
/// behavior) — once a selection exists it can only be changed, not cleared.
/// Pass `allowsDeselection: true` to opt into toggle semantics where tapping
/// the selected row sets the binding back to `nil`.
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
/// @State private var selection: VGRSelectionListItem? = nil
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

    /// Binding to the currently selected item, or `nil` if nothing is
    /// selected. Seed it before presenting to pre-select an item.
    ///
    /// Items are matched by their `Identifiable.id`, so the bound value does
    /// not need to be reference-equal to an element in ``items`` — any item
    /// with the same `id` counts as the selection.
    @Binding public var selection: Item?

    /// Whether tapping the already-selected row clears the selection back to
    /// `nil`. Defaults to `false` — once an item is selected the user must
    /// pick a different one to change the selection, matching classic
    /// radio-button behavior. Set to `true` to allow tapping the selected
    /// row to deselect it.
    public let allowsDeselection: Bool

    /// Builds the label view shown on the leading edge of each row.
    public let label: (Item) -> Label

    /// Creates a single-selection list.
    /// - Parameters:
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the selected item. Seed it to pre-select
    ///     the corresponding row, or `nil` for no selection.
    ///   - allowsDeselection: When `true`, tapping the already-selected row
    ///     clears the selection to `nil`. Defaults to `false`.
    ///   - label: A view builder that produces the label shown on the
    ///     leading edge of each row.
    public init(
        items: [Item],
        selection: Binding<Item?>,
        allowsDeselection: Bool = false,
        @ViewBuilder label: @escaping (Item) -> Label
    ) {
        self.items = items
        self._selection = selection
        self.allowsDeselection = allowsDeselection
        self.label = label
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                VGRSingleSelectionListRow(
                    isSelected: selection?.id == item.id,
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
        if selection?.id == item.id {
            if allowsDeselection {
                selection = nil
            }
        } else {
            selection = item
        }
    }
}

#Preview("VGRSingleSelectionList") {

    @Previewable @State var selection: VGRSelectionListItem? = nil

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
