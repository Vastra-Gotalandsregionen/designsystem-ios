import SwiftUI

/// A ready-made screen that presents a ``VGRSelectionList`` with standard
/// chrome: a navigation title, an optional description header, and the list
/// wrapped in a rounded card on the app's background.
///
/// Use this when you need the common "pick one or more items from a list"
/// flow without repeating the surrounding layout in every caller. For more
/// control over the layout, compose ``VGRSelectionList`` directly.
///
/// The screen does not supply its own `NavigationStack` — present it inside
/// one (or as a navigation destination) so the title is shown.
///
/// ### Usage
/// ```swift
/// @State private var selection: Set<String> = ["domination"]
///
/// let items = [
///     VGRSelectionListItem(name: "Hello", id: "hello"),
///     VGRSelectionListItem(name: "Domination", id: "domination"),
/// ]
///
/// NavigationStack {
///     VGRSelectionListScreen(
///         title: "Välj faktorer",
///         description: "Vad påverkade händelsen?",
///         items: items,
///         selection: $selection
///     ) { item in
///         Text(item.name)
///             .foregroundStyle(Color.Neutral.text)
///             .fontWeight(.medium)
///             .padding(.vertical, .Margins.medium)
///     }
/// }
/// ```
public struct VGRSelectionListScreen<Item: Identifiable, Label: View>: View {

    /// Title shown in the navigation bar.
    public let title: String

    /// Optional descriptive text shown above the list. Pass `nil` to hide.
    public let description: String?

    /// The selectable items displayed in the list.
    public let items: [Item]

    /// Binding to the set of currently selected item IDs. Seed it with IDs
    /// to pre-select the corresponding items.
    @Binding public var selection: Set<Item.ID>

    /// Builds the label view shown to the right of the checkbox for a given item.
    public let label: (Item) -> Label

    /// Creates a selection list screen.
    /// - Parameters:
    ///   - title: Title shown in the navigation bar.
    ///   - description: Optional descriptive text shown above the list.
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the set of selected item IDs. Seed it
    ///     with IDs to pre-select the corresponding items.
    ///   - label: A view builder that produces the label shown next to the
    ///     checkbox for each item.
    public init(
        title: String,
        description: String? = nil,
        items: [Item],
        selection: Binding<Set<Item.ID>>,
        @ViewBuilder label: @escaping (Item) -> Label
    ) {
        self.title = title
        self.description = description
        self.items = items
        self._selection = selection
        self.label = label
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .Margins.medium) {
                if let description {
                    Text(description)
                        .font(.headlineSemibold)
                        .maxLeading()
                        .padding(.horizontal, .Margins.medium)
                }

                VGRSelectionList(items: items, selection: $selection, label: label)
                    .background(Color.Elevation.elevation1)
                    .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            }
            .padding(.horizontal, .Margins.medium)
        }
        .background(Color.Elevation.background)
        .foregroundStyle(Color.Neutral.text)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("VGRSelectionListScreen") {

    @Previewable @State var selection: Set<String> = ["domination"]

    let items = [
        VGRSelectionListItem(name: "Hello"),
        VGRSelectionListItem(name: "World"),
        VGRSelectionListItem(name: "Domination"),
        VGRSelectionListItem(name: "Series"),
        VGRSelectionListItem(name: "Deluxe"),
    ]

    NavigationStack {
        VGRSelectionListScreen(
            title: "Selection List",
            description: "Choose one or more items from the list below.",
            items: items,
            selection: $selection
        ) { item in
            Text(item.name)
                .font(.bodyRegular)
                .foregroundStyle(Color.Neutral.text)
                .padding(.vertical, .Margins.medium)
        }
    }
}
