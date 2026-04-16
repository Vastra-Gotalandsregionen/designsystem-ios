import SwiftUI

/// A row that embeds a native `DatePicker` in the trailing accessory
/// slot. Built on top of ``VGRListRow``.
///
/// The picker's value is exposed via a `Binding<Date>`, mirroring the
/// native `DatePicker(selection:)` API — the caller owns and observes
/// the value. An optional `ClosedRange<Date>` constrains the selectable
/// range, and `displayedComponents` controls whether the picker exposes
/// date, time, or both.
///
/// Title, optional subtitle and an optional leading icon are forwarded
/// to the underlying row. Use inside a ``VGRList`` for settings-style
/// screens where each row represents an independent date or time.
///
/// ### Usage
/// ```swift
/// @State private var reminder: Date = .now
///
/// VGRDatePickerRow(title: "Påminnelse",
///                  selection: $reminder)
///
/// VGRDatePickerRow(title: "Starttid",
///                  subtitle: "Välj tidpunkt",
///                  selection: $reminder,
///                  displayedComponents: [.hourAndMinute])
///
/// VGRDatePickerRow(title: "Födelsedatum",
///                  selection: $birthday,
///                  in: Date.distantPast ... .now,
///                  displayedComponents: [.date],
///                  icon: { Image(systemName: "calendar") })
/// ```
public struct VGRDatePickerRow<Icon: View>: View {

    /// The primary text shown on the row.
    let title: String

    /// Optional secondary text shown below the title.
    var subtitle: String?

    /// Binding to the selected date.
    @Binding var selection: Date

    /// Optional closed range that constrains the selectable dates. When
    /// `nil`, any date is selectable.
    let range: ClosedRange<Date>?

    /// Which calendar components the picker exposes (date, time, or both).
    let displayedComponents: DatePicker.Components

    private let icon: Icon

    /// Creates a date picker row with a leading icon.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - selection: Binding to the selected date.
    ///   - range: Optional closed range that constrains the selectable
    ///     dates. Defaults to `nil` (unconstrained).
    ///   - displayedComponents: Which calendar components the picker
    ///     exposes. Defaults to `[.hourAndMinute, .date]`.
    ///   - icon: A view builder that produces the leading icon.
    public init(title: String,
                subtitle: String? = nil,
                selection: Binding<Date>,
                in range: ClosedRange<Date>? = nil,
                displayedComponents: DatePicker.Components = [.hourAndMinute, .date],
                @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.range = range
        self.displayedComponents = displayedComponents
        self.icon = icon()
    }

    /// Creates a date picker row without a leading icon.
    /// - Parameters:
    ///   - title: The primary text shown on the row.
    ///   - subtitle: Optional secondary text shown below the title.
    ///   - selection: Binding to the selected date.
    ///   - range: Optional closed range that constrains the selectable
    ///     dates. Defaults to `nil` (unconstrained).
    ///   - displayedComponents: Which calendar components the picker
    ///     exposes. Defaults to `[.hourAndMinute, .date]`.
    public init(title: String,
                subtitle: String? = nil,
                selection: Binding<Date>,
                in range: ClosedRange<Date>? = nil,
                displayedComponents: DatePicker.Components = [.hourAndMinute, .date]) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.range = range
        self.displayedComponents = displayedComponents
        self.icon = EmptyView()
    }

    public var body: some View {
        VGRListRow(title: title,
                   subtitle: subtitle,
                   icon: { icon },
                   accessory: {
            if let range {
                DatePicker("",
                           selection: $selection,
                           in: range,
                           displayedComponents: displayedComponents)
                    .labelsHidden()
            } else {
                DatePicker("",
                           selection: $selection,
                           displayedComponents: displayedComponents)
                    .labelsHidden()
            }
        })
    }
}

#Preview {
    @Previewable @State var reminder: Date = .now
    @Previewable @State var start: Date = .now
    @Previewable @State var birthday: Date = .now

    NavigationStack {
        VGRContainer {
            VGRSection(header: "VGRDatePickerRow") {
                VGRList {
                    VGRDatePickerRow(title: "Påminnelse",
                                     selection: $reminder)

                    VGRDatePickerRow(title: "Starttid",
                                     subtitle: "Välj tidpunkt",
                                     selection: $start,
                                     displayedComponents: [.hourAndMinute])
                }
            }

            VGRSection(header: "VGRDatePickerRow with Icon") {
                VGRList {
                    VGRDatePickerRow(title: "Födelsedatum",
                                     selection: $birthday,
                                     in: Date.distantPast ... .now,
                                     displayedComponents: [.date],
                                     icon: { Image(systemName: "calendar") })

                    VGRDatePickerRow(title: "Möte",
                                     subtitle: "Välj datum och tid",
                                     selection: $reminder,
                                     in: Date() ... Date.distantFuture,
                                     icon: { Image(systemName: "clock") })
                }
            }
        }
        .navigationTitle("VGRDatePickerRow")
    }
}
