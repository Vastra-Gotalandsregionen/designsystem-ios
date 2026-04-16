import SwiftUI

/// A row that shows a multi-select (checkbox-style) state via a leading
/// circular indicator. Use inside a ``VGRList`` to compose multi-selection
/// pickers without pulling in the higher-level ``VGRMultiSelectionList``.
///
/// The indicator is always present and swaps between `checkmark.circle.fill`
/// and `circle` based on `isSelected`. The row does not manage its own tap
/// handling — wrap it in a `Button` (or similar) and let the caller mutate
/// selection state.
///
/// Implicit animations are suppressed via
/// `.transaction { $0.animation = nil }` so selection changes that happen
/// inside a surrounding `withAnimation { … }` block do not animate the
/// indicator. The `.isSelected` accessibility trait is added when selected.
///
/// ### Usage
/// ```swift
/// Button {
///     selection.toggle(item)
/// } label: {
///     VGRCheckRow(title: item.title, isSelected: selection.contains(item))
/// }
/// ```
struct VGRCheckRow<Accessory: View>: View {

    /// The primary text shown on the row.
    var title: String

    /// Optional secondary text shown below the title.
    var subtitle: String? = nil

    /// Whether this row is currently part of the selection.
    var isSelected: Bool

    let accessory: Accessory

    /// Creates a check row with a trailing accessory.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text.
    ///   - isSelected: Whether this row is currently selected.
    ///   - accessory: A view builder that produces a trailing accessory.
    public init(title: String,
                subtitle: String? = nil,
                isSelected: Bool,
                @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.accessory = accessory()
    }

    /// Creates a check row without a trailing accessory.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text.
    ///   - isSelected: Whether this row is currently selected.
    public init(title: String,
                subtitle: String? = nil,
                isSelected: Bool) where Accessory == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.accessory = EmptyView()
    }

    var body: some View {
        VGRListRow(title: title,
                   subtitle: subtitle,
                   icon: {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .accessibilityHidden(true)
                .foregroundStyle(Color.Primary.action)
        }, accessory: {
            accessory
        })
        .transaction { $0.animation = nil }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var firstButton: Bool = false
    @Previewable @State var secondButton: Bool = true
    @Previewable @State var thirdButton: Bool = false

    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRList {
                    Button {
                        firstButton.toggle()
                    } label: {
                        VGRCheckRow(title: "Title", isSelected: firstButton)
                    }
                    .buttonStyle(.plain)

                    Button {
                        secondButton.toggle()
                    } label: {
                        VGRCheckRow(title: "Title",
                                    subtitle: "Subtitle",
                                    isSelected: secondButton)
                    }

                    Button {
                        thirdButton.toggle()
                    } label: {
                        VGRCheckRow(title: "Title",
                                    subtitle: "Subtitle",
                                    isSelected: thirdButton) {
                            HStack {
                                Text("Detail")

                                Image(systemName: "star.fill")
                            }
                            .foregroundStyle(.purple)
                        }
                    }
                }
            }
        }
        .navigationTitle("VGRCheckRow")
    }
}
