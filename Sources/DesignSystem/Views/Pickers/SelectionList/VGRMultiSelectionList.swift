import SwiftUI

/// A vertically stacked list that lets the user pick one or more items from a set of options.
///
/// Each row pairs a circular checkmark indicator — drawn by the component — with a
/// caller-supplied label view. The component is generic over the item type; any
/// `Identifiable` value works, so callers can either use ``VGRSelectionListItem`` for the
/// simple case or pass their own domain model.
///
/// Selection is synced through a `Set` of items, which also doubles as the
/// pre-selection mechanism — any items present in the set when the view
/// appears will be shown as selected.
///
/// The rendering is a plain `VStack`; it does not wrap itself in a `List`,
/// `ScrollView`, or `NavigationStack`. The caller is responsible for any
/// surrounding chrome (titles, headers, scroll container, etc.).
///
/// For single-choice selection, use `VGRSingleSelectionList` instead (when available).
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
/// VGRMultiSelectionList(items: items, selection: $selection) { item in
///     Text(item.name)
///         .foregroundStyle(Color.Neutral.text)
///         .fontWeight(.medium)
/// }
/// ```
///
/// ### Usage (alternative, using strings instead of arbitrary View)
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

public struct VGRMultiSelectionList<Item: Identifiable & Hashable, Label: View>: View {

    /// The selectable items displayed in the list.
    public let items: [Item]

    /// Binding to the set of currently selected items. Seed it before
    /// presenting to pre-select items.
    @Binding public var selection: Set<Item>

    /// Builds the label view shown to the right of the checkbox for a given item.
    /// Nil when the list was created with a ``name`` closure — rendering
    /// then goes through the string-based path instead.
    private let label: ((Item) -> Label)?

    /// Returns the display name for an item. When provided, the list uses a
    /// simpler built-in row rendering (``VGRCheckRow``) instead of the
    /// caller-supplied ``label`` view.
    private let name: ((Item) -> String)?

    /// Creates a multi-selection list with a custom row label.
    /// - Parameters:
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the set of selected items. Seed it with
    ///     items to pre-select the corresponding rows.
    ///   - label: A view builder that produces the label shown next to the
    ///     checkbox for each item.
    public init(
        items: [Item],
        selection: Binding<Set<Item>>,
        @ViewBuilder label: @escaping (Item) -> Label
    ) {
        self.items = items
        self._selection = selection
        self.label = label
        self.name = nil
    }

    /// Creates a multi-selection list that renders each row using the design
    /// system's built-in ``VGRCheckRow`` styling with the string returned by
    /// `name` as the title.
    /// - Parameters:
    ///   - items: The selectable items to display.
    ///   - selection: A binding to the set of selected items.
    ///   - name: A closure that returns the display name for an item.
    public init(
        items: [Item],
        selection: Binding<Set<Item>>,
        name: @escaping (Item) -> String
    ) where Label == EmptyView {
        self.items = items
        self._selection = selection
        self.label = nil
        self.name = name
    }

    public var body: some View {
        VGRList {
            ForEach(items) { item in
                if let name {
                    Button {
                        toggle(item)
                    } label: {
                        VGRCheckRow(
                            title: name(item),
                            isSelected: selection.contains(item)
                        )
                    }
                    .buttonStyle(.plain)
                } else if let label {
                    VGRMultiSelectionListRow(
                        isSelected: selection.contains(item),
                        toggle: { toggle(item) }
                    ) {
                        label(item)
                    }
                }
            }
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
        ScrollView {
            VStack(alignment: .leading, spacing: .Margins.medium) {

                Text("Choose one or more items from the string list below.")
                    .font(.headlineSemibold)
                    .padding(.horizontal, .Margins.medium)

                VGRMultiSelectionList(items: items, selection: $selection) { $0.name }

                Text("Choose one or more items from the view list below.")
                    .font(.headlineSemibold)
                    .padding(.horizontal, .Margins.medium)

                VGRMultiSelectionList(items: items, selection: $selection) { item in
                    Text(item.name)
                        .foregroundStyle(.cyan)
                        .padding(.vertical, .Margins.small)
                }
            }
            .padding(.horizontal, .Margins.medium)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRMultiSelectionList")
        .navigationBarTitleDisplayMode(.inline)
    }
}
