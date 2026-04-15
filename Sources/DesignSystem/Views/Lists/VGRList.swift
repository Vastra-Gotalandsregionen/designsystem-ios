import SwiftUI

/// A vertically stacked, rounded-card container for a set of row views.
///
/// The list takes an arbitrary view hierarchy as content and automatically
/// inserts a ``VGRDivider`` between each top-level row, so callers don't
/// need to manage dividers themselves. The content area is drawn on the
/// design system's `Color.Elevation.elevation1` background and clipped to
/// the standard `.Radius.mainRadius` corner radius.
///
/// An optional header can be supplied either as a plain string (rendered
/// with the design system's `headline` font above the card) or as a custom
/// view built with a ``@ViewBuilder`` closure for full control.
///
/// The list is intended to hold the rows provided by the design system —
/// ``VGRListRow``, ``VGRNavRow``, ``VGRSelectRow``, ``VGRCheckRow`` — but
/// any `View` works as a row.
///
/// ### Usage
/// ```swift
/// VGRList {
///     VGRListRow(title: "Title", subtitle: "Subtitle")
///     VGRListRow(title: "Second", subtitle: "Row")
/// }
/// ```
///
/// ### Usage with a string header
/// ```swift
/// VGRList(header: "Section title") {
///     VGRListRow(title: "Title", subtitle: "Subtitle")
/// }
/// ```
///
/// ### Usage with a custom header view
/// ```swift
/// VGRList(header: { Image(systemName: "star").font(.title) }) {
///     VGRListRow(title: "Title", subtitle: "Subtitle")
/// }
/// ```
struct VGRList<Header: View, Content: View>: View {

    private let headerTitle: String?
    private let header: Header
    private let content: Content
    private var showWarning: Bool = false

    /// Creates a list with a custom header view.
    /// - Parameters:
    ///   - header: A view builder that produces the header shown above the list.
    ///   - content: A view builder that produces the rows; each top-level
    ///     view becomes a row separated by a ``VGRDivider``.
    public init(showWarning: Bool = false,
                @ViewBuilder header: () -> Header,
                @ViewBuilder content: () -> Content) {
        self.showWarning = showWarning
        self.headerTitle = nil
        self.header = header()
        self.content = content()
    }

    /// Creates a list with a plain-string header rendered above the card.
    /// - Parameters:
    ///   - header: The header text.
    ///   - content: A view builder that produces the rows.
    public init(showWarning: Bool = false,
                header: String,
                @ViewBuilder content: () -> Content) where Header == EmptyView {
        self.showWarning = showWarning
        self.headerTitle = header
        self.header = EmptyView()
        self.content = content()
    }

    /// Creates a list without a header.
    /// - Parameter content: A view builder that produces the rows.
    public init(showWarning: Bool = false,
                @ViewBuilder content: () -> Content) where Header == EmptyView {
        self.showWarning = showWarning
        self.headerTitle = nil
        self.header = EmptyView()
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .Margins.medium) {
            if let headerTitle {
                Text(headerTitle)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, .Margins.medium)
            } else {
                header
            }

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
        }
        .foregroundStyle(Color.Neutral.text)
    }
}

#Preview {
    @Previewable @State var selectedDate: Date = .now

    NavigationStack {
        ScrollView {
            VStack(spacing: .Margins.medium) {
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

                VGRList(header: "Section title") {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
                
                VGRList(showWarning: true,
                        header: "Lorem ipsum dolor etcetera och annat som brukar stå här när man testar saker för flera rader") {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
                
                VGRList(header: { Image(systemName: "star").font(.title) }) {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }

            }
        }
        .padding(.horizontal, .Margins.medium)
        .background(Color.Elevation.background)
        .maxLeading()
    }
}
