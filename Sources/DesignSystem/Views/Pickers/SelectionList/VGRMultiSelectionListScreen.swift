import SwiftUI

/// A ready-made screen that presents a ``VGRMultiSelectionList`` with
/// standard chrome: a navigation title, an optional description header, and
/// the list wrapped in a rounded card on the app's background.
///
/// Use this when you need the common "pick one or more items from a list"
/// flow without repeating the surrounding layout in every caller. For more
/// control over the layout, compose ``VGRMultiSelectionList`` directly.
///
/// The screen does not supply its own `NavigationStack` — present it inside
/// one (or as a navigation destination) so the title is shown.
///
/// ### Usage
/// ```swift
/// @State private var selection: Set<VGRSelectionListItem> = []
///
/// let items = [
///     VGRSelectionListItem(id: "hello", name: "Hello"),
///     VGRSelectionListItem(id: "domination", name: "Domination"),
/// ]
///
/// NavigationStack {
///     VGRMultiSelectionListScreen(
///         title: "Välj faktorer",
///         description: "Vad påverkade händelsen?",
///         items: items,
///         selection: $selection
///     ) { item, isSelected in
///         VGRCheckRow(title: item.name, isSelected: isSelected)
///     }
/// }
/// ```
public struct VGRMultiSelectionListScreen<Item: Identifiable & Hashable, Row: View>: View {

    /// Title shown in the navigation bar.
    public let title: String

    /// Optional descriptive text shown above the list as its header. Pass
    /// `nil` to hide.
    public let description: String?

    /// The selectable items displayed in the list.
    public let items: [Item]

    /// Binding to the set of currently selected items. Seed it before
    /// presenting to pre-select items.
    @Binding public var selection: Set<Item>

    /// Builds the row view for an item. Receives the item and whether it is
    /// currently part of the selection set, so callers can vary content and
    /// styling based on selection state.
    public let row: (Item, Bool) -> Row

    /// Creates a multi-selection list screen.
    /// - Parameters:
    ///   - title: Title shown in the navigation bar.
    ///   - description: Optional descriptive text shown above the list.
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the set of selected items. Seed it with
    ///     items to pre-select the corresponding rows.
    ///   - row: A view builder that produces the row for an item given its
    ///     current `isSelected` state.
    public init(
        title: String,
        description: String? = nil,
        items: [Item],
        selection: Binding<Set<Item>>,
        @ViewBuilder row: @escaping (Item, Bool) -> Row
    ) {
        self.title = title
        self.description = description
        self.items = items
        self._selection = selection
        self.row = row
    }

    public var body: some View {
        VGRContainer {
            VGRMultiSelectionList(
                header: description,
                items: items,
                selection: $selection,
                row: row
            )
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("VGRMultiSelectionListScreen") {

    @Previewable @State var selection: Set<VGRSelectionListItem> = []

    let items = [
        VGRSelectionListItem(name: "Hello"),
        VGRSelectionListItem(name: "World"),
        VGRSelectionListItem(name: "Domination"),
        VGRSelectionListItem(name: "Series"),
        VGRSelectionListItem(name: "Deluxe"),
    ]

    NavigationStack {
        VGRMultiSelectionListScreen(
            title: "Selection List",
            description: "Choose one or more items from the list below.",
            items: items,
            selection: $selection
        ) { item, isSelected in
            VGRCheckRow(title: item.name, isSelected: isSelected)
        }
    }
}
