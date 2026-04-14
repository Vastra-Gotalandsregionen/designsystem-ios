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
///     ) { item in
///         Text(item.name)
///             .foregroundStyle(Color.Neutral.text)
///             .fontWeight(.medium)
///             .padding(.vertical, .Margins.medium)
///     }
/// }
/// ```
public struct VGRSingleSelectionListScreen<Item: Identifiable, Label: View>: View {

    /// Title shown in the navigation bar.
    public let title: String

    /// Optional descriptive text shown above the list. Pass `nil` to hide.
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

    /// Builds the label view shown on the leading edge of each row.
    public let label: (Item) -> Label

    /// Creates a single-selection list screen.
    /// - Parameters:
    ///   - title: Title shown in the navigation bar.
    ///   - description: Optional descriptive text shown above the list.
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the selected item. Seed it to pre-select
    ///     the corresponding row, or `nil` for no selection.
    ///   - allowsDeselection: When `true`, tapping the already-selected row
    ///     clears the selection to `nil`. Defaults to `false`.
    ///   - label: A view builder that produces the label shown on the
    ///     leading edge of each row.
    public init(
        title: String,
        description: String? = nil,
        items: [Item],
        selection: Binding<Item?>,
        allowsDeselection: Bool = false,
        @ViewBuilder label: @escaping (Item) -> Label
    ) {
        self.title = title
        self.description = description
        self.items = items
        self._selection = selection
        self.allowsDeselection = allowsDeselection
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

                VGRSingleSelectionList(
                    items: items,
                    selection: $selection,
                    allowsDeselection: allowsDeselection,
                    label: label
                )
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
            selection: $selection
        ) { item in
            Text(item.name)
                .font(.bodyRegular)
                .foregroundStyle(Color.Neutral.text)
                .padding(.vertical, .Margins.medium)
        }
    }
}
