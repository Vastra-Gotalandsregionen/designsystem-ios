import SwiftUI

/// A vertically stacked list that lets the user pick one or more items from a set of options.
///
/// The list owns selection state only — each row's appearance is produced by
/// a caller-supplied `row` builder that receives the item and its current
/// `isSelected` state. Wrap the returned view in anything you like
/// (``VGRCheckRow``, a custom layout, etc.); the list wraps it in a tappable
/// `Button` for you.
///
/// The component is generic over the item type; any `Identifiable & Hashable`
/// value works, so callers can either use ``VGRSelectionListItem`` for the
/// simple case or pass their own domain model.
///
/// Selection is synced through a `Set` of items, which also doubles as the
/// pre-selection mechanism — any items present in the set when the view
/// appears will be shown as selected.
///
/// The rendering is a ``VGRList`` wrapped in a ``VGRSection``; it does not
/// wrap itself in a `ScrollView` or `NavigationStack`. The caller is
/// responsible for any surrounding chrome (titles, scroll container, etc.).
///
/// For single-choice selection, use ``VGRSingleSelectionList`` instead.
///
/// ### Usage
/// ```swift
/// @State private var selection: Set<VGRSelectionListItem> = []
///
/// let items = [
///     VGRSelectionListItem(id: "hello", name: "Hello"),
///     VGRSelectionListItem(id: "world", name: "World"),
/// ]
///
/// VGRMultiSelectionList(items: items, selection: $selection) { item, isSelected in
///     VGRCheckRow(title: item.name, isSelected: isSelected)
/// }
/// ```
public struct VGRMultiSelectionList<Item: Identifiable & Hashable, Row: View>: View {

    /// Optional flag to show warning indicator if no item is selected
    public var warnIfNotSelected: Bool = false

    /// Optional header string rendered above the list by the enclosing
    /// ``VGRSection``. Pass `nil` (the default) to omit.
    public let header: String?

    /// Whether the underlying ``VGRSection`` horizontally insets its
    /// content. Forwarded to ``VGRSection/init(header:footer:inset:content:)``.
    /// Defaults to `true` — pass `false` when the list is already placed
    /// inside a container that supplies its own horizontal framing
    /// (for example a ``VGRShape``).
    public let inset: Bool

    /// The selectable items displayed in the list.
    public let items: [Item]

    /// Binding to the set of currently selected items. Seed it before
    /// presenting to pre-select items.
    @Binding public var selection: Set<Item>

    /// Builds the row view for an item. Receives the item and whether it is
    /// currently part of the selection set, so callers can vary content and
    /// styling based on selection state.
    public let row: (Item, Bool) -> Row

    /// Creates a multi-selection list.
    /// - Parameters:
    ///   - header: Optional header string rendered above the list.
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the set of selected items. Seed it with
    ///     items to pre-select the corresponding rows.
    ///   - warnIfNotSelected: Optional flag to show warning if no item is selected.
    ///   - inset: Whether the underlying ``VGRSection`` horizontally insets
    ///     its content. Defaults to `true`. Pass `false` when the list is
    ///     wrapped in a container that already supplies horizontal framing.
    ///   - row: A view builder that produces the row for an item given its
    ///     current `isSelected` state.
    public init(
        header: String? = nil,
        items: [Item],
        selection: Binding<Set<Item>>,
        warnIfNotSelected: Bool = false,
        inset: Bool = true,
        @ViewBuilder row: @escaping (Item, Bool) -> Row
    ) {
        self.warnIfNotSelected = warnIfNotSelected
        self.header = header
        self.inset = inset
        self.items = items
        self._selection = selection
        self.row = row
    }

    @ViewBuilder
    private var rows: some View {
        ForEach(items) { item in
            let isSelected = selection.contains(item)
            Button {
                toggle(item)
            } label: {
                row(item, isSelected)
            }
            .buttonStyle(.plain)
        }
    }

    private var showWarning: Bool {
        return warnIfNotSelected && selection.isEmpty
    }

    public var body: some View {
        VGRSection(header: header, inset: inset) {
            VGRList(showWarning: showWarning) { rows }
        }
    }

    private func toggle(_ item: Item) {
        if selection.contains(item) {
            selection.remove(item)
        } else {
            selection.insert(item)
        }
    }
}

#Preview("VGRMultiSelectionList") {

    @Previewable @State var selection: Set<VGRSelectionListItem> = []

    let items = [
        VGRSelectionListItem(name: "Hello"),
        VGRSelectionListItem(name: "World"),
        VGRSelectionListItem(name: "Domination"),
        VGRSelectionListItem(name: "Series"),
        VGRSelectionListItem(name: "Deluxe"),
    ]

    NavigationStack {
        VGRContainer {
            VGRMultiSelectionList(
                header: "Choose one or more items from the list below.",
                items: items,
                selection: $selection
            ) { item, isSelected in
                VGRCheckRow(title: item.name, isSelected: isSelected)
            }

            VGRShape {
                VGRMultiSelectionList(
                    header: "Warns when nothing is selected",
                    items: items,
                    selection: $selection,
                    warnIfNotSelected: true,
                    inset: false
                ) { item, isSelected in
                    VGRCheckRow(title: item.name, isSelected: isSelected)
                }
            }
        }
        .navigationTitle("VGRMultiSelectionList")
        .navigationBarTitleDisplayMode(.inline)
    }
}
