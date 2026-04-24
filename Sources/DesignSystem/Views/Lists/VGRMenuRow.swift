import SwiftUI

/// A row that opens a `Menu` when tapped, showing the currently selected
/// value and an up/down chevron on the trailing edge to signal the
/// disclosure. Built on top of ``VGRListRow``.
///
/// The accessory slot always renders `Text(value)` followed by a
/// `chevron.up.chevron.down` glyph — the visual structure is fixed so
/// menu rows stay consistent across screens. The caller supplies the
/// menu's items via a `@ViewBuilder` and is responsible for keeping
/// `value` in sync with whichever action was last picked.
///
/// The menu content can contain any of SwiftUI's menu elements:
/// `Button`, `Divider`, nested `Menu`, `Picker`, etc.
///
/// An optional leading icon, title and subtitle are forwarded to the
/// underlying row. Use inside a ``VGRList`` for settings-style pickers
/// where a compact trailing menu is more appropriate than a full-screen
/// selection list.
///
/// ### Usage
/// ```swift
/// @State private var sort: String = "Datum"
///
/// VGRMenuRow(title: "Sortering", value: sort) {
///     Button("Namn")    { sort = "Namn" }
///     Button("Datum")   { sort = "Datum" }
///     Divider()
///     Button("Storlek") { sort = "Storlek" }
/// }
///
/// VGRMenuRow(title: "Tema",
///            subtitle: "Bestämmer appens utseende",
///            value: theme,
///            icon: { Image(systemName: "paintpalette") }) {
///     Button("Auto")  { theme = "Auto" }
///     Button("Ljust") { theme = "Ljust" }
///     Button("Mörkt") { theme = "Mörkt" }
/// }
/// ```
public struct VGRMenuRow<Icon: View, ValueLabel: View, Content: View>: View {

    @ScaledMetric private var chevronSize: CGFloat = 25

    /// The primary text shown on the row.
    let title: String

    /// Optional secondary text shown below the title.
    var subtitle: String?

    private let icon: Icon
    private let valueLabel: ValueLabel
    private let menuContent: Content

    /// Creates a menu row with a leading icon and a string value label.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - value: The currently-selected value shown as the menu's label.
    ///   - icon: A view builder that produces the leading icon.
    ///   - menu: A view builder that produces the menu's items.
    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder icon: () -> Icon,
                value: String,
                @ViewBuilder menu: () -> Content) where ValueLabel == Text {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
        self.valueLabel = Text(value).font(.bodySemibold)
        self.menuContent = menu()
    }

    /// Creates a menu row without a leading icon, using a string value label.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - value: The currently-selected value shown as the menu's label.
    ///   - menu: A view builder that produces the menu's items.
    public init(title: String,
                subtitle: String? = nil,
                value: String,
                @ViewBuilder menu: () -> Content) where Icon == EmptyView, ValueLabel == Text {
        self.title = title
        self.subtitle = subtitle
        self.icon = EmptyView()
        self.valueLabel = Text(value).font(.bodySemibold)
        self.menuContent = menu()
    }

    /// Creates a menu row with a leading icon and a custom value label view.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - icon: A view builder that produces the leading icon.
    ///   - valueLabel: A view builder that produces the menu's label view.
    ///   - menu: A view builder that produces the menu's items.
    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder valueLabel: () -> ValueLabel,
                @ViewBuilder menu: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
        self.valueLabel = valueLabel()
        self.menuContent = menu()
    }

    /// Creates a menu row without a leading icon, using a custom value label view.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - valueLabel: A view builder that produces the menu's label view.
    ///   - menu: A view builder that produces the menu's items.
    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder valueLabel: () -> ValueLabel,
                @ViewBuilder menu: () -> Content) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = EmptyView()
        self.valueLabel = valueLabel()
        self.menuContent = menu()
    }

    public var body: some View {
        VGRListRow(title: title,
                   subtitle: subtitle,
                   icon: { icon },
                   accessory: {
            Menu {
                menuContent
            } label: {
                HStack(spacing: .Margins.xtraSmall / 2) {
                    valueLabel

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnoteSemibold)
                        .frame(width: chevronSize, height: chevronSize)
                        .accessibilityHidden(true)
                }
                .foregroundStyle(Color.Primary.action)
                .fixedSize(horizontal: true, vertical: false)
            }
        })
    }
}

#Preview {
    @Previewable @State var sort: String = "Datum"
    @Previewable @State var theme: String = "Auto"
    @Previewable @State var unit: String = "Metric"
    @Previewable @State var status: VGRFlagLabelState = .success

    let statusText: LocalizedStringKey = {
        switch status {
        case .success:     return "Success"
        case .warning:     return "Warning"
        case .error:       return "Error"
        case .information: return "Information"
        }
    }()

    NavigationStack {
        VGRContainer {
            VGRSection(header: "VGRMenuRow") {
                VGRList {
                    VGRMenuRow(title: "Sortering",
                               value: sort) {
                        Button("Namn")    { sort = "Namn" }
                        Button("Datum")   { sort = "Datum" }
                        Divider()
                        Button("Storlek") { sort = "Storlek" }
                    }

                    VGRMenuRow(title: "Tema",
                               subtitle: "Bestämmer appens utseende",
                               value: theme) {
                        Button("Auto")  { theme = "Auto" }
                        Button("Ljust") { theme = "Ljust" }
                        Button("Mörkt") { theme = "Mörkt" }
                    }
                }
            }

            VGRSection(header: "VGRMenuRow with Icon") {
                VGRList {
                    VGRMenuRow(title: "Enheter",
                               icon: { Image(systemName: "ruler") },
                               value: unit) {
                        Button("Metric")   { unit = "Metric" }
                        Button("Imperial") { unit = "Imperial" }
                    }

                    VGRMenuRow(title: "Enheter",
                               subtitle: "Välj en enhetsstandard",
                               icon: { Image(systemName: "ruler") },
                               value: unit) {
                        Button("Metric")   { unit = "Metric" }
                        Button("Imperial") { unit = "Imperial" }
                    }
                }
            }

            VGRSection(header: "VGRMenuRow anpassad label") {
                VGRList {
                    VGRMenuRow(title: "Status",
                               valueLabel: { VGRFlagLabel(statusText, state: status) }) {
                        Button("Success")   { status = .success }
                        Button("Warning") { status = .warning }
                        Button("Error")   { status = .error }
                        Button("Information") { status = .information }
                    }

                    VGRMenuRow(title: "Status",
                               subtitle: "Med ikon och flagg-etikett",
                               icon: { Image(systemName: "flag") },
                               valueLabel: { VGRFlagLabel(statusText, state: status) }) {
                        Button("Success")   { status = .success }
                        Button("Warning") { status = .warning }
                        Button("Error")   { status = .error }
                        Button("Information") { status = .information }
                    }
                }
            }
        }
        .navigationTitle("VGRMenuRow")
        .navigationBarTitleDisplayMode(.inline)
    }
}
