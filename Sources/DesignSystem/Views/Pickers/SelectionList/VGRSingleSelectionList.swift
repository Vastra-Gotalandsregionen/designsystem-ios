import SwiftUI

/// A vertically stacked list that lets the user pick exactly one item from a set of options.
///
/// Each row shows the item's display name — produced by the caller-supplied
/// `name` closure — and a trailing checkmark that appears only on the
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
/// The rendering is a ``VGRList`` wrapped in a ``VGRSection``; it does not
/// wrap itself in a `ScrollView` or `NavigationStack`. The caller is
/// responsible for any surrounding chrome (titles, scroll container, etc.).
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
/// VGRSingleSelectionList(items: items, selection: $selection) { $0.name }
/// ```
public struct VGRSingleSelectionList<Item: Identifiable>: View {

    /// Optional flag to show warning indicator if no item is selected
    public var warnIfNotSelected: Bool = false

    /// Optional header string rendered above the list by the enclosing
    /// ``VGRSection``. Pass `nil` (the default) to omit.
    public let header: String?

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

    /// Returns the display name for an item, shown as the row title.
    public let name: (Item) -> String

    /// Creates a single-selection list.
    /// - Parameters:
    ///   - header: Optional header string rendered above the list.
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the selected item. Seed it to pre-select
    ///     the corresponding row, or `nil` for no selection.
    ///   - allowsDeselection: When `true`, tapping the already-selected row
    ///     clears the selection to `nil`. Defaults to `false`.
    ///   - warnIfNotSelected: Optional property to show warning if no item is selected
    ///   - name: A closure that returns the display name for an item.
    public init(
        header: String? = nil,
        items: [Item],
        selection: Binding<Item?>,
        allowsDeselection: Bool = false,
        warnIfNotSelected: Bool = false,
        name: @escaping (Item) -> String
    ) {
        self.warnIfNotSelected = warnIfNotSelected
        self.header = header
        self.items = items
        self._selection = selection
        self.allowsDeselection = allowsDeselection
        self.name = name
    }

    @ViewBuilder
    private var rows: some View {
        ForEach(items) { item in
            Button {
                toggle(item)
            } label: {
                VGRSelectRow(
                    title: name(item),
                    isSelected: selection?.id == item.id
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var showWarning: Bool {
        warnIfNotSelected && selection == nil
    }

    public var body: some View {
        VGRSection(header: header) {
            VGRList(showWarning: showWarning) { rows }
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
        VGRContainer {
            VGRSingleSelectionList(
                header: "Choose one item from the list below.",
                items: items,
                selection: $selection
            ) { $0.name }
            
            VGRSingleSelectionList(
                header: "Warns if no item is selected.",
                items: items,
                selection: $selection,
                allowsDeselection: true,
                warnIfNotSelected: true
            ) { $0.name }
        }
        .navigationTitle("VGRSingleSelectionList")
        .navigationBarTitleDisplayMode(.inline)
    }
}
