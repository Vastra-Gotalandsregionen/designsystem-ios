import SwiftUI

/// A row that shows a single-select (radio-style) state via a trailing
/// checkmark. Use inside a ``VGRList`` to compose single-selection pickers
/// without pulling in the higher-level ``VGRSingleSelectionList``.
///
/// Unlike ``VGRCheckRow``, the indicator here is a plain `checkmark` drawn
/// only when `isSelected` is `true`; unselected rows have no trailing
/// indicator. The row does not manage its own tap handling — wrap it in a
/// `Button` (or similar) and let the caller mutate selection state.
///
/// Implicit animations are suppressed via
/// `.transaction { $0.animation = nil }` so selection changes that happen
/// inside a surrounding `withAnimation { … }` block do not animate the
/// indicator. The `.isSelected` accessibility trait is added when selected.
///
/// ### Usage
/// ```swift
/// Button {
///     selectedId = item.id
/// } label: {
///     VGRSelectRow(title: item.title, isSelected: selectedId == item.id)
/// }
/// ```
struct VGRSelectRow<Icon: View>: View {

    /// The primary text shown on the row.
    var title: String

    /// Optional secondary text shown below the title.
    var subtitle: String? = nil

    /// Whether this row is the currently-selected option.
    var isSelected: Bool

    let icon: Icon

    /// Creates a select row with a custom leading icon.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text.
    ///   - isSelected: Whether this row is currently selected.
    ///   - icon: A view builder that produces the leading icon.
    public init(title: String,
                subtitle: String? = nil,
                isSelected: Bool,
                @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.icon = icon()
    }

    /// Creates a select row without a leading icon.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text.
    ///   - isSelected: Whether this row is currently selected.
    public init(title: String,
                subtitle: String? = nil,
                isSelected: Bool) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.icon = EmptyView()
    }

    var body: some View {
        VGRListRow(title: title,
                   subtitle: subtitle,
                   icon: {
            icon
        }, accessory: {
            if isSelected {
                Image(systemName: "checkmark")
                    .accessibilityHidden(true)
                    .foregroundStyle(Color.Primary.action)
            }
        })
        .transaction { $0.animation = nil }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var selectedId: Int = 0

    NavigationStack {
        VGRContainer {
            VGRSection(header: "VGRSelectRow",
                       footer: "This row blanks out accessory view for the checkmark symbol") {
                VGRList {
                    Button {
                        selectedId = 0
                    } label: {
                        VGRSelectRow(title: "Title",
                                     isSelected: selectedId == 0)
                    }

                    Button {
                        selectedId = 1
                    } label: {
                        VGRSelectRow(title: "Title",
                                     subtitle: "Subtitle",
                                     isSelected: selectedId == 1)
                    }

                    Button {
                        selectedId = 2
                    } label: {
                        VGRSelectRow(title: "Title",
                                     subtitle: "Subtitle",
                                     isSelected: selectedId == 2,
                                     icon: { Image(systemName: "bolt") })
                    }
                }
            }
        }
    }
}
