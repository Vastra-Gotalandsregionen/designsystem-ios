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
///     ) { $0.name }
/// }
/// ```
public struct VGRMultiSelectionListScreen<Item: Identifiable & Hashable>: View {

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

    /// Returns the display name for an item, shown as the row title.
    public let name: (Item) -> String

    /// Creates a multi-selection list screen.
    /// - Parameters:
    ///   - title: Title shown in the navigation bar.
    ///   - description: Optional descriptive text shown above the list.
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the set of selected items. Seed it with
    ///     items to pre-select the corresponding rows.
    ///   - name: A closure that returns the display name for an item.
    public init(
        title: String,
        description: String? = nil,
        items: [Item],
        selection: Binding<Set<Item>>,
        name: @escaping (Item) -> String
    ) {
        self.title = title
        self.description = description
        self.items = items
        self._selection = selection
        self.name = name
    }

    public var body: some View {
        VGRContainer {
            VGRMultiSelectionList(
                header: description,
                items: items,
                selection: $selection,
                name: name
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
            selection: $selection,
        ) { $0.name }
    }
}
