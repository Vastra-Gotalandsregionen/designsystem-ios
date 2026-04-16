import SwiftUI

/// A row that embeds a `Toggle` control in the trailing accessory slot.
/// Built on top of ``VGRListRow``.
///
/// The toggle's state is exposed via a `Binding<Bool>`, mirroring the
/// native `Toggle(isOn:)` API — the caller owns and observes the value.
/// Title, optional subtitle and an optional leading icon are forwarded to
/// the underlying row.
///
/// Tapping the toggle flips the binding; the row body around the toggle
/// is not tappable. Use inside a ``VGRList`` for settings-style screens
/// where each row represents an independent boolean.
///
/// The toggle is tinted with `Color.Primary.action` so the on-state
/// color stays consistent with other design system indicators
/// (``VGRCheckRow``, ``VGRSelectRow``) regardless of the host app's
/// accent color.
///
/// ### Usage
/// ```swift
/// @State private var notifications: Bool = true
///
/// VGRToggleRow(title: "Notifieringar", isOn: $notifications)
///
/// VGRToggleRow(title: "Mörkt läge",
///              subtitle: "Följer systemets inställning",
///              isOn: $darkMode,
///              icon: { Image(systemName: "moon") })
/// ```
public struct VGRToggleRow<Icon: View>: View {

    /// The primary text shown on the row.
    let title: String

    /// Optional secondary text shown below the title.
    var subtitle: String?

    /// Binding to the toggle's on/off state.
    @Binding var isOn: Bool

    private let icon: Icon

    /// Creates a toggle row with a leading icon.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - isOn: Binding to the toggle's on/off state.
    ///   - icon: A view builder that produces the leading icon.
    public init(title: String,
                subtitle: String? = nil,
                isOn: Binding<Bool>,
                @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.icon = icon()
    }

    /// Creates a toggle row without a leading icon.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - isOn: Binding to the toggle's on/off state.
    public init(title: String,
                subtitle: String? = nil,
                isOn: Binding<Bool>) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.icon = EmptyView()
    }

    public var body: some View {
        VGRListRow(title: title,
                   subtitle: subtitle,
                   icon: { icon },
                   accessory: {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.Primary.action)
        })
    }
}

#Preview {
    @Previewable @State var notifications: Bool = true
    @Previewable @State var darkMode: Bool = false
    @Previewable @State var wifi: Bool = true
    @Previewable @State var bluetooth: Bool = false

    NavigationStack {
        VGRContainer {
            VGRSection(header: "VGRToggleRow") {
                VGRList {
                    VGRToggleRow(title: "Notifieringar",
                                 isOn: $notifications)
                    
                    VGRToggleRow(title: "Mörkt läge",
                                 subtitle: "Följer systemets inställning",
                                 isOn: $darkMode)
                }
            }

            VGRSection(header: "VGRToggleRow with Icon") {
                VGRList {
                    VGRToggleRow(title: "Bluetooth",
                                 isOn: $bluetooth,
                                 icon: { Image(systemName: "dot.radiowaves.left.and.right") })

                    VGRToggleRow(title: "Wi-Fi",
                                 subtitle: "Anslut till tillgängliga nätverk",
                                 isOn: $wifi,
                                 icon: { Image(systemName: "wifi") })
                }
            }
        }
        .navigationTitle("VGRToggleRow")
    }
}
