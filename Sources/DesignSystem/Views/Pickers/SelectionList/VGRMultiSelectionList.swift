import SwiftUI

/// A vertically stacked list that lets the user pick one or more items from a set of options.
///
/// Each row shows the item's display name — produced by the caller-supplied
/// `name` closure — alongside a circular checkmark indicator that reflects
/// the current selection state.
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
/// VGRMultiSelectionList(items: items, selection: $selection) { $0.name }
/// ```
public struct VGRMultiSelectionList<Item: Identifiable & Hashable>: View {

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

    /// Returns the display name for an item, shown as the row title.
    public let name: (Item) -> String

    /// Creates a multi-selection list.
    /// - Parameters:
    ///   - header: Optional header string rendered above the list.
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the set of selected items. Seed it with
    ///     items to pre-select the corresponding rows.
    ///   - warnIfNotSelected: Optional flag to show warning if no item is selected
    ///   - inset: Whether the underlying ``VGRSection`` horizontally insets
    ///     its content. Defaults to `true`. Pass `false` when the list is
    ///     wrapped in a container that already supplies horizontal framing.
    ///   - name: A closure that returns the display name for an item.
    public init(
        header: String? = nil,
        items: [Item],
        selection: Binding<Set<Item>>,
        warnIfNotSelected: Bool = false,
        inset: Bool = true,
        name: @escaping (Item) -> String
    ) {
        self.warnIfNotSelected = warnIfNotSelected
        self.header = header
        self.inset = inset
        self.items = items
        self._selection = selection
        self.name = name
    }

    @ViewBuilder
    private var rows: some View {
        ForEach(items) { item in
            Button {
                toggle(item)
            } label: {
                VGRCheckRow(
                    title: name(item),
                    isSelected: selection.contains(item)
                )
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
            ) { $0.name }

            VGRShape {
                VGRMultiSelectionList(
                    header: "Warns when nothing is selected",
                    items: items,
                    selection: $selection,
                    warnIfNotSelected: true,
                    inset: false
                ) { $0.name }
            }
        }
        .navigationTitle("VGRMultiSelectionList")
        .navigationBarTitleDisplayMode(.inline)
    }
}
