import SwiftUI

/// A vertically stacked list that lets the user pick exactly one item from a set of options.
///
/// The list owns selection state only — each row's appearance is produced by
/// a caller-supplied `row` builder that receives the item and its current
/// `isSelected` state. Wrap the returned view in anything you like
/// (``VGRSelectRow``, a custom layout, etc.); the list wraps it in a tappable
/// `Button` and applies the `.isSelected` accessibility trait for you.
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
/// VGRSingleSelectionList(items: items, selection: $selection) { item, isSelected in
///     VGRSelectRow(title: item.name, isSelected: isSelected)
/// }
/// ```
public struct VGRSingleSelectionList<Item: Identifiable, Row: View>: View {

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

    /// Builds the row view for an item. Receives the item and whether it is
    /// the currently-selected row, so callers can vary content and styling
    /// based on selection state.
    public let row: (Item, Bool) -> Row

    /// Creates a single-selection list.
    /// - Parameters:
    ///   - header: Optional header string rendered above the list.
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the selected item. Seed it to pre-select
    ///     the corresponding row, or `nil` for no selection.
    ///   - allowsDeselection: When `true`, tapping the already-selected row
    ///     clears the selection to `nil`. Defaults to `false`.
    ///   - warnIfNotSelected: Optional property to show warning if no item is selected.
    ///   - inset: Whether the underlying ``VGRSection`` horizontally insets
    ///     its content. Defaults to `true`. Pass `false` when the list is
    ///     wrapped in a container that already supplies horizontal framing.
    ///   - row: A view builder that produces the row for an item given its
    ///     current `isSelected` state.
    public init(
        header: String? = nil,
        items: [Item],
        selection: Binding<Item?>,
        allowsDeselection: Bool = false,
        warnIfNotSelected: Bool = false,
        inset: Bool = true,
        @ViewBuilder row: @escaping (Item, Bool) -> Row
    ) {
        self.warnIfNotSelected = warnIfNotSelected
        self.header = header
        self.inset = inset
        self.items = items
        self._selection = selection
        self.allowsDeselection = allowsDeselection
        self.row = row
    }

    @ViewBuilder
    private var rows: some View {
        ForEach(items) { item in
            let isSelected = selection?.id == item.id
            Button {
                toggle(item)
            } label: {
                row(item, isSelected)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        }
    }

    private var showWarning: Bool {
        warnIfNotSelected && selection == nil
    }

    public var body: some View {
        VGRSection(header: header, inset: inset) {
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
            ) { item, isSelected in
                VGRSelectRow(
                    title: item.name,
                    isSelected: isSelected,
                    icon: {
                        Image(systemName: "bolt")
                            .foregroundStyle(Color.red)
                    }
                )
            }

            VGRSingleSelectionList(
                header: "Warns if no item is selected.",
                items: items,
                selection: $selection,
                allowsDeselection: true,
                warnIfNotSelected: true
            ) { item, isSelected in
                VGRSelectRow(title: item.name, isSelected: isSelected)
            }
        }
        .navigationTitle("VGRSingleSelectionList")
        .navigationBarTitleDisplayMode(.inline)
    }
}
