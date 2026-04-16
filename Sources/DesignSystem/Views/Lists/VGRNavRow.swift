import SwiftUI

/// A row that navigates to a destination view when tapped, visually
/// identical to ``VGRListRow`` but with a trailing chevron and
/// `NavigationLink` behavior.
///
/// Wraps the destination in a `NavigationLink`, so the row must be placed
/// inside a `NavigationStack` (or other navigation container) to function.
/// A `chevron.right` glyph is always appended to the accessory position —
/// any caller-supplied accessory is shown to its left.
///
/// Four overloaded initializers cover every combination of optional `icon`
/// and `accessory`. In all of them `destination` is the last parameter, so
/// the trailing closure always binds to the navigation destination
/// regardless of which other slots are filled.
///
/// ### Usage
/// ```swift
/// VGRNavRow(title: "Title") {
///     DestinationView()
/// }
///
/// VGRNavRow(title: "Title",
///           subtitle: "Subtitle",
///           icon: { Image(systemName: "bolt") }) {
///     DestinationView()
/// }
///
/// VGRNavRow(title: "Title",
///           accessory: { Text("Detail") }) {
///     DestinationView()
/// }
/// ```
public struct VGRNavRow<Icon: View, Accessory: View, Destination: View>: View {

    @ScaledMetric private var chevronSize: CGFloat = 25

    /// The primary text shown on the row.
    var title: String

    /// Optional secondary text shown below the title.
    var subtitle: String? = nil

    let icon: Icon
    let accessory: Accessory
    let destination: Destination

    /// Creates a nav row with both an icon and an accessory.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text.
    ///   - icon: A view builder that produces the leading icon.
    ///   - accessory: A view builder that produces a trailing accessory
    ///     shown to the left of the chevron.
    ///   - destination: A view builder that produces the navigation destination.
    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder accessory: () -> Accessory,
                @ViewBuilder destination: () -> Destination) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
        self.accessory = accessory()
        self.destination = destination()
    }

    /// Creates a nav row without an icon.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text.
    ///   - accessory: A view builder that produces a trailing accessory.
    ///   - destination: A view builder that produces the navigation destination.
    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder accessory: () -> Accessory,
                @ViewBuilder destination: () -> Destination) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = EmptyView()
        self.accessory = accessory()
        self.destination = destination()
    }

    /// Creates a nav row without an accessory.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text.
    ///   - icon: A view builder that produces the leading icon.
    ///   - destination: A view builder that produces the navigation destination.
    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder destination: () -> Destination) where Accessory == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
        self.accessory = EmptyView()
        self.destination = destination()
    }

    /// Creates a nav row with neither an icon nor an accessory — the
    /// trailing chevron is the only decoration.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text.
    ///   - destination: A view builder that produces the navigation destination.
    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder destination: () -> Destination) where Icon == EmptyView, Accessory == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = EmptyView()
        self.accessory = EmptyView()
        self.destination = destination()
    }

    public var body: some View {
        NavigationLink {
            destination
        } label: {
            VGRListRow(title: title,
                       subtitle: subtitle,
                       icon: { icon },
                       accessory: {

                HStack(spacing:0) {
                    accessory

                    Image(systemName: "chevron.right")
                        .font(.footnoteSemibold)
                        .frame(width: chevronSize, height: chevronSize)
                        .foregroundStyle(Color.Primary.action)
                        .accessibilityHidden(true)
                }
            })
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "No Detail set") {
                VGRList {
                    VGRNavRow(title:"Title") { Text("Destination") }

                    VGRNavRow(title:"Title",
                              subtitle: "Subtitle",
                              icon: { Image(systemName: "bolt") }) {
                        Text("Destination")
                    }
                }
            }

            VGRSection(header: "With Detail set") {
                VGRList {
                    VGRNavRow(title:"Title",
                              subtitle: "Subtitle",
                              accessory: {
                        Text("Detail")
                            .foregroundStyle(.purple)
                    }) {
                        Text("Destination")
                    }

                    VGRNavRow(title:"Title",
                              subtitle: "Subtitle",
                              icon: { Image(systemName: "bolt") },
                              accessory: {
                        Text("Detail")
                            .foregroundStyle(.cyan)
                    }) {
                        Text("Destination")
                    }
                }
            }
        }
    }
}
