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
/// Pass `minimumSelectionCount` to keep the user from deselecting below a
/// given number of items.
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

    /// The smallest number of items the list lets the user keep selected.
    /// Defaults to `0` — no lower bound. When set, tapping an already
    /// selected row is a no-op once the selection has shrunk to this size,
    /// so the user can never deselect below the limit.
    ///
    /// The limit only guards deselection; it never selects items on the
    /// caller's behalf. A selection seeded below the limit is left as-is
    /// until the user picks enough items — combine with
    /// ``warnIfNotSelected`` to flag that state, which then warns while the
    /// selection is smaller than the limit rather than only when empty.
    public let minimumSelectionCount: Int

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
    ///   - minimumSelectionCount: The smallest number of items the user is
    ///     allowed to keep selected. Defaults to `0` — no lower bound.
    ///   - warnIfNotSelected: Optional flag to show warning if the minimum
    ///     number of items is not selected.
    ///   - inset: Whether the underlying ``VGRSection`` horizontally insets
    ///     its content. Defaults to `true`. Pass `false` when the list is
    ///     wrapped in a container that already supplies horizontal framing.
    ///   - row: A view builder that produces the row for an item given its
    ///     current `isSelected` state.
    public init(
        header: String? = nil,
        items: [Item],
        selection: Binding<Set<Item>>,
        minimumSelectionCount: Int = 0,
        warnIfNotSelected: Bool = false,
        inset: Bool = true,
        @ViewBuilder row: @escaping (Item, Bool) -> Row
    ) {
        self.warnIfNotSelected = warnIfNotSelected
        self.header = header
        self.inset = inset
        self.items = items
        self._selection = selection
        self.minimumSelectionCount = minimumSelectionCount
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
        return warnIfNotSelected && selection.count < max(minimumSelectionCount, 1)
    }

    public var body: some View {
        VGRSection(header: header, inset: inset) {
            VGRList(showBorder: showWarning) { rows }
        }
    }

    private func toggle(_ item: Item) {
        if selection.contains(item) {
            guard selection.count > minimumSelectionCount else { return }
            selection.remove(item)
        } else {
            selection.insert(item)
        }
    }
}

#Preview("VGRMultiSelectionList") {

    @Previewable @State var selection: Set<VGRSelectionListItem> = []
    @Previewable @State var minimumSelection: Set<VGRSelectionListItem> = []

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

            VGRMultiSelectionList(
                header: "Requires at least two items, and warns until two are picked.",
                items: items,
                selection: $minimumSelection,
                minimumSelectionCount: 2,
                warnIfNotSelected: true
            ) { item, isSelected in
                VGRCheckRow(title: item.name, isSelected: isSelected)
            }
        }
        .navigationTitle("VGRMultiSelectionList")
        .navigationBarTitleDisplayMode(.inline)
    }
}
