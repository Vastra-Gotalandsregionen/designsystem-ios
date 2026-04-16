import SwiftUI

/// A single selectable entry in a ``VGRMultiSelectionList`` or
/// ``VGRSingleSelectionList``.
///
/// Each item is identified by its ``id`` and displays ``name`` as its row label.
/// The ``id`` is what appears in the selection binding — use a stable, unique
/// string per item (e.g. a domain key or UUID string).
///
/// ### Usage
/// ```swift
/// let items = [
///     VGRSelectionListItem(id: "hello", name: "Hello"),
///     VGRSelectionListItem(id: "world", name: "World"),
/// ]
///
/// // Or, if a stable id is not required, a UUID id is generated automatically:
/// let generated = [
///     VGRSelectionListItem(name: "Hello"),
///     VGRSelectionListItem(name: "World"),
/// ]
/// ```
public struct VGRSelectionListItem: Hashable, Identifiable {

    /// A stable, unique identifier for the item. Used as the value stored in
    /// the selection binding of a ``VGRMultiSelectionList``.
    public let id: String

    /// The human-readable label displayed for the item.
    public let name: String

    /// Creates a new selection list item.
    /// - Parameters:
    ///   - id: A stable, unique identifier for the item.
    ///   - name: The human-readable label to display.
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    /// Creates a new selection list item with a default UUID id
    /// - Parameters:
    ///   - name: The human-readable label to display.
    public init(name: String) {
        self.id = UUID().uuidString
        self.name = name
    }
}
