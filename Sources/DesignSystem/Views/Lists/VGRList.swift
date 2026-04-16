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
    private var showWarning: Bool = false

    /// Creates a list of rows wrapped in a rounded card.
    /// - Parameters:
    ///   - showWarning: When `true`, a warning border is drawn around the card.
    ///   - content: A view builder that produces the rows; each top-level
    ///     view becomes a row separated by a ``VGRDivider``.
    public init(showWarning: Bool = false,
                @ViewBuilder content: () -> Content) {
        self.showWarning = showWarning
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content) { subviews in
                ForEach(subviews.indices, id: \.self) { index in
                    subviews[index]
                    if index < subviews.count - 1 {
                        VGRDivider()
                    }
                }
            }
        }
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        .warningBorder(showWarning)
        .foregroundStyle(Color.Neutral.text)
    }
}

#Preview {
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
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
            }

            VGRSection(header: "Lorem ipsum dolor etcetera och annat som brukar stå här när man testar saker för flera rader") {
                VGRList(showWarning: true) {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
            }
        }
    }
}
