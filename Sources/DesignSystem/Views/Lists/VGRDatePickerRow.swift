import SwiftUI

/// A row that embeds a native `DatePicker` in the trailing accessory
/// slot. Built on top of ``VGRListRow``.
///
/// The picker's value is exposed via a `Binding<Date>`, mirroring the
/// native `DatePicker(selection:)` API — the caller owns and observes
/// the value. An optional range constrains the selectable dates, and
/// `displayedComponents` controls whether the picker exposes date,
/// time, or both.
///
/// The row mirrors `DatePicker`'s range overloads: it accepts a
/// `ClosedRange<Date>`, a `PartialRangeFrom<Date>` (`start...`) or a
/// `PartialRangeThrough<Date>` (`...end`), so callers can express lower
/// bounds, upper bounds or both.
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
///
/// VGRDatePickerRow(title: "Möte",
///                  selection: $meeting,
///                  in: Date()...)
///
/// VGRDatePickerRow(title: "Utgår senast",
///                  selection: $expiry,
///                  in: ...Date.distantFuture)
/// ```
public struct VGRDatePickerRow<Icon: View>: View {

    private enum DateRange {
        case unbounded
        case closed(ClosedRange<Date>)
        case from(PartialRangeFrom<Date>)
        case through(PartialRangeThrough<Date>)
    }

    /// The primary text shown on the row.
    let title: String

    /// Optional secondary text shown below the title.
    var subtitle: String?

    /// Binding to the selected date.
    @Binding var selection: Date

    private let range: DateRange

    /// Which calendar components the picker exposes (date, time, or both).
    let displayedComponents: DatePicker.Components

    private let icon: Icon

    /// Creates a date picker row with a leading icon and an optional
    /// closed range.
    public init(title: String,
                subtitle: String? = nil,
                selection: Binding<Date>,
                in range: ClosedRange<Date>? = nil,
                displayedComponents: DatePicker.Components = [.hourAndMinute, .date],
                @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.range = range.map(DateRange.closed) ?? .unbounded
        self.displayedComponents = displayedComponents
        self.icon = icon()
    }

    /// Creates a date picker row without a leading icon and an optional
    /// closed range.
    public init(title: String,
                subtitle: String? = nil,
                selection: Binding<Date>,
                in range: ClosedRange<Date>? = nil,
                displayedComponents: DatePicker.Components = [.hourAndMinute, .date]) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.range = range.map(DateRange.closed) ?? .unbounded
        self.displayedComponents = displayedComponents
        self.icon = EmptyView()
    }

    /// Creates a date picker row with a leading icon and a lower-bound
    /// range (`start...`).
    public init(title: String,
                subtitle: String? = nil,
                selection: Binding<Date>,
                in range: PartialRangeFrom<Date>,
                displayedComponents: DatePicker.Components = [.hourAndMinute, .date],
                @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.range = .from(range)
        self.displayedComponents = displayedComponents
        self.icon = icon()
    }

    /// Creates a date picker row without a leading icon and a
    /// lower-bound range (`start...`).
    public init(title: String,
                subtitle: String? = nil,
                selection: Binding<Date>,
                in range: PartialRangeFrom<Date>,
                displayedComponents: DatePicker.Components = [.hourAndMinute, .date]) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.range = .from(range)
        self.displayedComponents = displayedComponents
        self.icon = EmptyView()
    }

    /// Creates a date picker row with a leading icon and an upper-bound
    /// range (`...end`).
    public init(title: String,
                subtitle: String? = nil,
                selection: Binding<Date>,
                in range: PartialRangeThrough<Date>,
                displayedComponents: DatePicker.Components = [.hourAndMinute, .date],
                @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.range = .through(range)
        self.displayedComponents = displayedComponents
        self.icon = icon()
    }

    /// Creates a date picker row without a leading icon and an
    /// upper-bound range (`...end`).
    public init(title: String,
                subtitle: String? = nil,
                selection: Binding<Date>,
                in range: PartialRangeThrough<Date>,
                displayedComponents: DatePicker.Components = [.hourAndMinute, .date]) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.range = .through(range)
        self.displayedComponents = displayedComponents
        self.icon = EmptyView()
    }

    public var body: some View {
        VGRListRow(title: title,
                   subtitle: subtitle,
                   icon: { icon },
                   accessory: {
            switch range {
            case .unbounded:
                DatePicker("",
                           selection: $selection,
                           displayedComponents: displayedComponents)
                    .labelsHidden()
            case .closed(let r):
                DatePicker("",
                           selection: $selection,
                           in: r,
                           displayedComponents: displayedComponents)
                    .labelsHidden()
            case .from(let r):
                DatePicker("",
                           selection: $selection,
                           in: r,
                           displayedComponents: displayedComponents)
                    .labelsHidden()
            case .through(let r):
                DatePicker("",
                           selection: $selection,
                           in: r,
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
    @Previewable @State var meeting: Date = .now
    @Previewable @State var expiry: Date = .now

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
                                     subtitle: "Endast framtida tidpunkter",
                                     selection: $meeting,
                                     in: Date()...,
                                     icon: { Image(systemName: "clock") })

                    VGRDatePickerRow(title: "Utgår senast",
                                     subtitle: "Endast datum i det förflutna",
                                     selection: $expiry,
                                     in: ...Date(),
                                     displayedComponents: [.date],
                                     icon: { Image(systemName: "hourglass") })
                }
            }
        }
        .navigationTitle("VGRDatePickerRow")
    }
}
