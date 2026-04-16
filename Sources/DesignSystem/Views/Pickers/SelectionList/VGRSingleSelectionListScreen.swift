import SwiftUI

/// A ready-made screen that presents a ``VGRSingleSelectionList`` with
/// standard chrome: a navigation title, an optional description header, and
/// the list wrapped in a rounded card on the app's background.
///
/// Use this when you need the common "pick exactly one item from a list"
/// flow without repeating the surrounding layout in every caller. For more
/// control over the layout, compose ``VGRSingleSelectionList`` directly.
///
/// The screen does not supply its own `NavigationStack` — present it inside
/// one (or as a navigation destination) so the title is shown.
///
/// ### Usage
/// ```swift
/// @State private var selection: VGRSelectionListItem? = nil
///
/// let items = [
///     VGRSelectionListItem(id: "hello", name: "Hello"),
///     VGRSelectionListItem(id: "domination", name: "Domination"),
/// ]
///
/// NavigationStack {
///     VGRSingleSelectionListScreen(
///         title: "Välj en faktor",
///         description: "Vad påverkade händelsen mest?",
///         items: items,
///         selection: $selection
///     ) { $0.name }
/// }
/// ```
public struct VGRSingleSelectionListScreen<Item: Identifiable>: View {

    /// Title shown in the navigation bar.
    public let title: String

    /// Optional descriptive text shown above the list as its header. Pass
    /// `nil` to hide.
    public let description: String?

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
    /// `nil`. Defaults to `false` — classic radio-button behavior. Set to
    /// `true` to allow tapping the selected row to deselect it. Forwarded to
    /// the underlying ``VGRSingleSelectionList``.
    public let allowsDeselection: Bool

    /// Returns the display name for an item, shown as the row title.
    public let name: (Item) -> String

    /// Creates a single-selection list screen.
    /// - Parameters:
    ///   - title: Title shown in the navigation bar.
    ///   - description: Optional descriptive text shown above the list.
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the selected item. Seed it to pre-select
    ///     the corresponding row, or `nil` for no selection.
    ///   - allowsDeselection: When `true`, tapping the already-selected row
    ///     clears the selection to `nil`. Defaults to `false`.
    ///   - name: A closure that returns the display name for an item.
    public init(
        title: String,
        description: String? = nil,
        items: [Item],
        selection: Binding<Item?>,
        allowsDeselection: Bool = false,
        name: @escaping (Item) -> String
    ) {
        self.title = title
        self.description = description
        self.items = items
        self._selection = selection
        self.allowsDeselection = allowsDeselection
        self.name = name
    }

    public var body: some View {
        VGRContainer {
            VGRSingleSelectionList(
                header: description,
                items: items,
                selection: $selection,
                allowsDeselection: allowsDeselection,
                name: name
            )
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("VGRSingleSelectionListScreen") {

    @Previewable @State var selection: VGRSelectionListItem? = nil

    let items = [
        VGRSelectionListItem(name: "Hello"),
        VGRSelectionListItem(name: "World"),
        VGRSelectionListItem(name: "Domination"),
        VGRSelectionListItem(name: "Series"),
        VGRSelectionListItem(name: "Deluxe"),
    ]

    NavigationStack {
        VGRSingleSelectionListScreen(
            title: "Single Selection List",
            description: "Choose one item from the list below.",
            items: items,
            selection: $selection,
            allowsDeselection: true
        ) { $0.name }
    }
}
