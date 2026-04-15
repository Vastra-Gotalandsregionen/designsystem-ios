import SwiftUI

/// The standard row layout used inside a ``VGRList``.
///
/// A row renders a required `title` and optional `subtitle` in the center,
/// with an optional leading `icon` and optional trailing `accessory` built
/// from caller-supplied view builders. Typography, padding and the muted
/// accessory tint are applied by the design system — callers only provide
/// the content.
///
/// The vertical padding adjusts automatically: rows with a subtitle use
/// `.Margins.small`, rows without one use `.Margins.medium`, so compact and
/// two-line variants visually balance each other when stacked.
///
/// ### Usage
/// ```swift
/// VGRListRow(title: "Title")
///
/// VGRListRow(title: "Title", subtitle: "Subtitle")
///
/// VGRListRow(title: "Title") {
///     Text("Date") // trailing accessory via trailing closure
/// }
///
/// VGRListRow(title: "Title",
///            subtitle: "Subtitle",
///            icon: { Image(systemName: "bolt") },
///            accessory: { Text("Detail") })
/// ```
struct VGRListRow<Icon: View, Accessory: View>: View {

    /// The primary text shown on the row.
    let title: String

    /// Optional secondary text shown below the title. When `nil`, the row
    /// renders as a single-line layout with larger vertical padding.
    var subtitle: String? = nil

    private let icon: Icon?
    private let accessory: Accessory?

    /// Creates a row with optional icon and accessory view builders.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - icon: A view builder that produces a leading icon. Defaults to empty.
    ///   - accessory: A view builder that produces a trailing accessory.
    ///     Defaults to empty.
    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder icon: () -> Icon = { EmptyView() },
        @ViewBuilder accessory: () -> Accessory = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
        self.accessory = accessory()
    }

    /// Creates a row without an icon, using the trailing closure as the
    /// accessory. Provided so the common case
    /// `VGRListRow(title: "…") { accessory }` routes the trailing closure
    /// to the accessory slot rather than the icon slot.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - accessory: A view builder that produces a trailing accessory.
    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder accessory: () -> Accessory
    ) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = EmptyView()
        self.accessory = accessory()
    }

    private var verticalPadding: CGFloat {
        return subtitle != nil ? .Margins.small : .Margins.medium
    }

    var body: some View {
        HStack(spacing: .Margins.xtraSmall) {

            if let icon {
                icon
                    .accessibilityHidden(true)
            }

            VStack(spacing: .Margins.xtraSmall / 2) {
                Text(title)
                    .font(.bodyRegular)
                    .maxLeading()

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .maxLeading()
                }
            }
            .padding(.vertical, verticalPadding)
            .foregroundStyle(Color.Neutral.text)

            if let accessory {
                accessory
                    .foregroundStyle(Color.Neutral.textVariant)
            }

        }
        .padding(.horizontal, .Margins.medium)
        .maxLeading()
    }
}

#Preview {
    @Previewable @State var selectedDate: Date  = .now

    NavigationStack {
        ScrollView {
            VGRList {
                /// ListRow with title inline 
                VGRListRow(title:"Title")

                /// ListRow with title inline and accessory as trailing closure
                VGRListRow(title:"Title") {
                    Text("Date")
                }

                /// ListRow with title and subtitle as inline
                VGRListRow(title:"Title", subtitle: "Subtitle")

                /// ListRow with title, subtitle as inline and accessory as trailing closure
                VGRListRow(title:"Title", subtitle: "Subtitle") {
                    Text("Date")
                }

                /// ListRow with title, subtitle and icon
                VGRListRow(title:"Title",
                           subtitle: "Subtitle",
                           icon: { Image(systemName: "bolt") })

                /// ListRow with title, subtitle, icon and accessory, all as inline params
                VGRListRow(title:"Title",
                           subtitle: "Subtitle",
                           icon: { Image(systemName: "bolt")},
                           accessory: {
                    DatePicker(
                        "Välj datum",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                })

                /// ListRow with title, subtitle, icon and accessory, all as inline params
                VGRListRow(title:"Title",
                           subtitle: "Subtitle",
                           icon: { Image(systemName: "bolt") },
                           accessory: {
                    DatePicker(
                        "Välj datum",
                        selection: $selectedDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                })

                /// ListRow with title, subtitle, icon and accessory as a trailing closure
                VGRListRow(title:"An extended title that breaks the line in order to test the components boundaries",
                           subtitle: "Very long subtitle to test the components boundaries and functionality",
                           icon: { Image(systemName: "bolt") }) {
                    DatePicker(
                        "Välj datum",
                        selection: $selectedDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                }
            }
            .padding(.horizontal, .Margins.medium)
        }
        .background(Color.Elevation.background)
        .maxLeading()
    }
}
