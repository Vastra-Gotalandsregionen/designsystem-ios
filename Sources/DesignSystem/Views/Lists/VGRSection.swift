import SwiftUI

/// A labeled grouping placed inside a ``VGRContainer``.
///
/// A section renders an optional header above its content and an optional
/// footer below it. The content itself is arbitrary — typically a
/// ``VGRList``, but can be any view (charts, banners, empty states, custom
/// cards). Content inset is controlled by the `inset` flag so sections can
/// host both padded cards and full-width elements.
///
/// Header and footer can each be a plain string (rendered with the design
/// system's `headline` / `footnote` fonts, nested inside the section's
/// inset so the text aligns with row content inside a ``VGRList``) or a
/// custom view supplied via a `@ViewBuilder` closure (inset by the
/// standard margin so it aligns with the content card's edge).
///
/// ### Usage
/// ```swift
/// VGRSection(header: "Today") {
///     VGRList {
///         VGRListRow(title: "Morning")
///     }
/// }
///
/// VGRSection(header: "Stats", inset: false) {
///     ChartView()
/// }
///
/// VGRSection(header: "Advanced",
///            footer: "These settings apply to future entries only.") {
///     VGRList { VGRListRow(title: "…") }
/// }
/// ```
public struct VGRSection<Header: View, Footer: View, Content: View>: View {

    private let headerTitle: String?
    private let footerTitle: String?
    private let header: Header
    private let footer: Footer
    private let content: Content
    private let inset: Bool

    /// Creates a section with optional string header and footer.
    /// - Parameters:
    ///   - header: Optional header text.
    ///   - footer: Optional footer text.
    ///   - inset: Whether the content is horizontally padded by
    ///     `.Margins.medium`. Defaults to `true`.
    ///   - content: A view builder that produces the section content.
    public init(header: String? = nil,
                footer: String? = nil,
                inset: Bool = true,
                @ViewBuilder content: () -> Content)
    where Header == EmptyView, Footer == EmptyView {
        self.headerTitle = header
        self.footerTitle = footer
        self.header = EmptyView()
        self.footer = EmptyView()
        self.inset = inset
        self.content = content()
    }

    /// Creates a section with a custom header view and an optional string footer.
    /// - Parameters:
    ///   - footer: Optional footer text.
    ///   - inset: Whether the content is horizontally padded. Defaults to `true`.
    ///   - content: A view builder that produces the section content.
    ///   - header: A view builder that produces the header.
    public init(footer: String? = nil,
                inset: Bool = true,
                @ViewBuilder content: () -> Content,
                @ViewBuilder header: () -> Header)
    where Footer == EmptyView {
        self.headerTitle = nil
        self.footerTitle = footer
        self.header = header()
        self.footer = EmptyView()
        self.inset = inset
        self.content = content()
    }

    /// Creates a section with an optional string header and a custom footer view.
    /// - Parameters:
    ///   - header: Optional header text.
    ///   - inset: Whether the content is horizontally padded. Defaults to `true`.
    ///   - content: A view builder that produces the section content.
    ///   - footer: A view builder that produces the footer.
    public init(header: String? = nil,
                inset: Bool = true,
                @ViewBuilder content: () -> Content,
                @ViewBuilder footer: () -> Footer)
    where Header == EmptyView {
        self.headerTitle = header
        self.footerTitle = nil
        self.header = EmptyView()
        self.footer = footer()
        self.inset = inset
        self.content = content()
    }

    /// Creates a section with a custom header and footer view.
    /// - Parameters:
    ///   - inset: Whether the content is horizontally padded. Defaults to `true`.
    ///   - content: A view builder that produces the section content.
    ///   - header: A view builder that produces the header.
    ///   - footer: A view builder that produces the footer.
    public init(inset: Bool = true,
                @ViewBuilder content: () -> Content,
                @ViewBuilder header: () -> Header,
                @ViewBuilder footer: () -> Footer) {
        self.headerTitle = nil
        self.footerTitle = nil
        self.header = header()
        self.footer = footer()
        self.inset = inset
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .Margins.medium) {
            if let headerTitle {
                Group {
                    Text(headerTitle)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.Neutral.text)
                        .padding(.horizontal, .Margins.medium)
                }
                .padding(.horizontal, inset ? .Margins.medium : 0)
            } else {
                header.padding(.horizontal, .Margins.medium)
            }

            content
                .padding(.horizontal, inset ? .Margins.medium : 0)

            if let footerTitle {
                Group {
                    Text(footerTitle)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.Neutral.textVariant)
                        .padding(.horizontal, .Margins.medium)
                }
                .padding(.horizontal, inset ? .Margins.medium : 0)
            } else {
                footer.padding(.horizontal, .Margins.medium)
            }
        }
    }
}

#Preview {
    NavigationStack {
        VGRContainer {

            VGRSection(header: "String header only") {
                VGRList {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
            }

            VGRSection(header: "Header and footer",
                       footer: "A short explanatory note that can wrap across multiple lines if needed.") {
                VGRList {
                    VGRListRow(title: "Title")
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
            }

            VGRSection {
                VGRList {
                    VGRListRow(title: "No header, no footer")
                }
            }

            VGRSection(footer: "Footer without a header") {
                VGRList {
                    VGRListRow(title: "Title")
                }
            }

            VGRSection(inset: false) {
                VGRShape(bend: [.topLeading]) {
                    VGRSection(header: "Välj läkemedel", footer: "Sidfot", inset: false) {
                        VGRList {
                            VGRListRow(title: "No header, no footer")
                        }
                    }
                    .padding(.top, .Margins.large)

                    RoundedRectangle(cornerRadius: .Radius.mainRadius)
                        .fill(Color.Elevation.elevation1)
                        .frame(height: 120)
                }
            } header: {
                HStack {
                    Image(systemName: "chart.bar").font(.title3)
                    Text("Custom header, reduced inset").font(.headline)
                }
            } footer: {
                HStack {
                    Image(systemName: "star").font(.footnote)
                    Text("Custom footer, reduced inset").font(.footnote)
                }
            }

            VGRSection(header: "These are the boundaries of a VGRSection") {
                Text("Header has default double inset")
                    .maxLeading()
                    .border(.blue, width: 1)

                Text("Elements also have a default inset.")
                    .maxLeading()
                    .border(.blue, width: 1)

                Text("And also a default between-item spacing")
                    .maxLeading()
                    .border(.blue, width: 1)
            }
            .border(.red, width: 1)
        }
    }
}
