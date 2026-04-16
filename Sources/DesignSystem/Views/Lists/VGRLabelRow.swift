import SwiftUI

/// A row that pairs a title and optional subtitle with a read-only value
/// label on the trailing edge. Built on top of ``VGRListRow``.
///
/// The value is rendered with the design system's `bodyRegular` font and
/// `Color.Neutral.textVariant` so it reads as secondary information next
/// to the title. An optional leading icon is forwarded to the underlying
/// row — useful for labeling entries with a category glyph.
///
/// Use inside a ``VGRList`` for displaying static key/value data such as
/// profile details, measurements, or metadata summaries.
///
/// ### Usage
/// ```swift
/// VGRLabelRow("Weight", value: "72 kg")
///
/// VGRLabelRow("Date of birth", subtitle: "Age 34", value: "1990-01-01")
///
/// VGRLabelRow("Dose", value: "5 mg",
///             icon: { Image(systemName: "pill") })
/// ```
public struct VGRLabelRow<Icon: View>: View {

    /// The primary text shown on the row.
    let title: String

    /// Optional secondary text shown below the title.
    var subtitle: String?

    /// The read-only value displayed on the trailing edge.
    let value: String

    private let icon: Icon

    /// Creates a label row with a leading icon.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - value: The read-only value shown on the trailing edge.
    ///   - icon: A view builder that produces the leading icon.
    public init(_ title: String,
                subtitle: String? = nil,
                value: String,
                @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.icon = icon()
    }

    /// Creates a label row without a leading icon.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - value: The read-only value shown on the trailing edge.
    public init(_ title: String,
                subtitle: String? = nil,
                value: String) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.icon = EmptyView()
    }

    private var a11yLabel: String {
        [title, subtitle].compactMap{ $0 }.joined(separator: ", ")
    }

    public var body: some View {
        VGRListRow(title: title,
                   subtitle: subtitle,
                   icon: { icon },
                   accessory: {
            Text(value)
                .font(.bodyRegular)
                .foregroundStyle(Color.Neutral.textVariant)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: true, vertical: false)
        })
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yLabel)
        .accessibilityValue(value)

    }
}

#Preview {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "VGRLabelRow") {
                VGRList {
                    VGRLabelRow("Hello", value: "World")

                    VGRLabelRow("Hello", value: "23 februari 2026, 13:37 is the time")

                    VGRLabelRow("Hello", subtitle: "World domination sequence", value: "23 februari 2026, 13:37")

                    VGRLabelRow("Hello", subtitle: "World", value: "Domination")

                    VGRLabelRow("Hello",
                                value: "World",
                                icon: { Image(systemName: "star") })

                    VGRLabelRow("Hello",
                                subtitle: "World",
                                value: "Domination",
                                icon: { Image(systemName: "star") })
                }
            }
        }
    }
}
