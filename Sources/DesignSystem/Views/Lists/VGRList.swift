import SwiftUI

/// A vertically stacked, rounded-card container for a set of row views.
///
/// The list takes an arbitrary view hierarchy as content and automatically
/// inserts a ``VGRDivider`` between each top-level row, so callers don't
/// need to manage dividers themselves. The content area is drawn on the
/// design system's `Color.Elevation.elevation1` background and clipped to
/// the standard `.Radius.mainRadius` corner radius.
///
/// `VGRList` is purely the card — it does not own a header, footer, or
/// horizontal padding. Compose it inside a ``VGRSection`` (which provides
/// header, footer, and inset control) placed in a ``VGRContainer``.
///
/// The list is intended to hold the rows provided by the design system —
/// ``VGRListRow``, ``VGRNavRow``, ``VGRSelectRow``, ``VGRCheckRow`` — but
/// any `View` works as a row.
///
/// ### Usage
/// ```swift
/// VGRContainer {
///     VGRSection(header: "Section title") {
///         VGRList {
///             VGRListRow(title: "Title", subtitle: "Subtitle")
///             VGRListRow(title: "Second", subtitle: "Row")
///         }
///     }
/// }
/// ```
public struct VGRList<Content: View>: View {

    private let content: Content
    private var showBorder: Bool = false
    private var hideDividers: Bool = false
    private var borderColor: Color = Color.Status.errorText

    /// Creates a list of rows wrapped in a rounded card.
    /// - Parameters:
    ///   - showBorder: When `true`, a border is drawn around the card.
    ///   - bordercolor: Color of the border
    ///   - hideDividers: When `true`, the dividers between the elements of the list are hidden.
    ///   - content: A view builder that produces the rows; each top-level
    ///     view becomes a row separated by a ``VGRDivider``.
    public init(showBorder: Bool = false,
                borderColor: Color = Color.Status.errorText,
                hideDividers: Bool = false,
                @ViewBuilder content: () -> Content) {
        self.showBorder = showBorder
        self.borderColor = borderColor
        self.hideDividers = hideDividers
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content) { subviews in
                ForEach(Array(subviews.enumerated()), id: \.element.id) { index, subview in
                    subview
                        .background(Color.Elevation.elevation1)
                        .zIndex(Double(subviews.count - index)) /// Higher index in the beginning of the list, to accomodate for slide/move animations
                    if !hideDividers && index < subviews.count - 1 {
                        VGRDivider()
                    }
                }
            }
        }
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        .roundedBorder(showBorder, borderColor: borderColor)
        .foregroundStyle(Color.Neutral.text)
    }
}

#Preview {
    @Previewable @State var isToggleOn: Bool = false
    @Previewable @State var selectedDate: Date = .now

    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRList {
                    VGRListRow(title: "Title", subtitle: "Subtitle")

                    VGRListRow(title: "Title",
                               subtitle: "Subtitle",
                               icon: { Image(systemName: "bolt") })

                    VGRListRow(title: "Title",
                               subtitle: "Subtitle",
                               icon: { Image(systemName: "bolt") },
                               accessory: {
                        DatePicker("Välj datum", selection: $selectedDate)
                            .labelsHidden()
                    })
                }
            }

            VGRSection(header: "Section title") {
                VGRList {
                    Button {
                        withAnimation { isToggleOn.toggle() }
                    } label: {
                        VGRListRow(title: "Press me to see a hidden row",
                                   subtitle: "Subtitle") {
                            Image(systemName: isToggleOn ? "chevron.up" : "chevron.down")
                                .animation(nil)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    VGRListRow(title: "Peek-a-boo!", subtitle: "This is a hidden row that you just uncovered")
                        .isVisible(isToggleOn)
                        .transition(.move(edge: .top))
                }
            }

            VGRSection(header: "Lorem ipsum dolor etcetera och annat som brukar stå här när man testar saker för flera rader") {
                VGRList(showBorder: true) {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
            }

            VGRSection(header: "Lorem ipsum dolor etcetera och annat som brukar stå här när man testar saker för flera rader, inga dividers") {
                VGRList(showBorder: true,
                        borderColor: Color.Primary.action) {
                    VGRDatePickerRow(title: "Datum", selection: $selectedDate)
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
            }
        }
    }
}
