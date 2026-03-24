# VGR Calendar V2

A SwiftUI calendar component with support for both month and week views. The component is fully customizable through generic view builders, letting consumers define their own day cells and month headers.

## Components

| Component | Description |
|---|---|
| `VGRCalendarViewV2` | Vertically scrolling month view. Renders months from a `DateInterval` using `LazyVStack`. |
| `VGRCalendarMonthViewV2` | Single month grid. Displays weekday headers and a grid of day cells. |
| `VGRCalendarWeekViewV2` | Horizontally paging week view. Automatically adjusts height to content and selects days on scroll. |
| `VGRCalendarWeekdaysViewV2` | Row of weekday symbols, respecting the calendar's `firstWeekday` and locale. |

## Data Model

The calendar uses `VGRCalendarIndexKey` as its primary key type. Each day is represented by a `(year, month, day)` tuple that conforms to `Hashable`, `Identifiable`, and `Sendable`.

Day data is provided as a `Binding<[VGRCalendarIndexKey: T]>` dictionary, where `T` is any type conforming to `Identifiable & Equatable`. This allows O(1) lookups per day cell.

## Usage

### Month View

```swift
@State var data: [VGRCalendarIndexKey: MyDayData] = [:]
@State var selectedDate = VGRCalendarIndexKey(from: Date())
@State var scrollPosition = ScrollPosition(id: VGRCalendarIndexKey(from: Date()).monthID)

VGRCalendarViewV2(
    calendar: .current,
    interval: myDateInterval,
    data: $data,
    selectedDate: $selectedDate,
    scrollPosition: $scrollPosition
) { month, entries in
    // Month header
    Text(month.monthName())
} dayContent: { day, dayData, isSelected in
    // Day cell
    Text(day.day, format: .number)
}
```

### Week View

```swift
@State var data: [VGRCalendarIndexKey: MyDayData] = [:]
@State var selectedDate = VGRCalendarIndexKey(from: Date())
@State var scrollPosition = ScrollPosition(id: VGRCalendarIndexKey(from: Date()).weekID)

VGRCalendarWeekViewV2(
    calendar: .current,
    interval: myDateInterval,
    data: $data,
    selectedDate: $selectedDate,
    scrollPosition: $scrollPosition
) { day, dayData, isSelected in
    // Day cell
    Text(day.day, format: .number)
}
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `calendar` | `Calendar` | Calendar instance used for date calculations and locale. Defaults to `.current`. |
| `interval` | `DateInterval` | Controls which months/weeks are rendered. |
| `data` | `Binding<[VGRCalendarIndexKey: T]>` | Dictionary mapping each day to its data. |
| `selectedDate` | `Binding<VGRCalendarIndexKey>` | The currently selected date. |
| `scrollPosition` | `Binding<ScrollPosition>` | Controls scroll position (month ID or week ID). |

## Localization

The calendar fully adapts to the provided `Calendar` instance. This includes:

- **Locale** — month and weekday names are displayed in the calendar's locale
- **First day of week** — the grid starts on the correct day (e.g. Monday in Sweden, Sunday in the US)
- **Weekday symbols** — short weekday names follow the locale's formatting

Pass a configured `Calendar` to control all of this:

```swift
var calendar: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.locale = Locale(identifier: "sv")
    return cal
}()

VGRCalendarViewV2(calendar: calendar, ...)
```

## Accessibility

- VoiceOver support with custom accessibility rotors for month navigation
- Accessibility actions for navigating between weeks
- Keyboard focus management for day cells
- Localized labels via `VGRCalendarIndexKey.accessibilityLabel`

## Examples

See the `Example/` folder for a full working implementation including:

- `ExampleView` — Month view with navigation to a week detail view
- `ExampleWeekView` — Standalone week view with an event list
- `ExampleDayView` — Custom day cell with selection state and event indicators
- `ExampleMonthHeaderView` — Month header with event count badge
