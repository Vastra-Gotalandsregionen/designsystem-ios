# VGRCalendar

A high-performance calendar component built with UIKit (`UICollectionView`) wrapped for SwiftUI, supporting infinite scrolling and custom day cell rendering. Also includes a pure SwiftUI horizontal week view variant.

## Architecture

### Month Calendar (UIKit-backed)

```
VGRCalendarView (SwiftUI)
  └─ UIViewControllerRepresentable
       └─ VGRCalendarViewController
            ├─ VGRCalendarCollectionView (UICollectionView subclass, VoiceOver scroll guard)
            │    ├─ VGRCalendarLayout (compositional layout, 7-column grid)
            │    ├─ VGRCalendarMonthHeader (month title + weekday labels)
            │    ├─ VGRCalendarDayCell (UIHostingConfiguration → SwiftUI content)
            │    ├─ VGRCalendarPlaceholderCell (padding for adjacent months)
            │    └─ VGRCalendarSectionBackground (rounded decoration view)
            ├─ VGRCalendarDataSource (diffable data source + snapshot generation)
            └─ VGRCalendarInfiniteScrollManager (dynamic window expansion)
```

**VGRCalendarView** is the public SwiftUI entry point. It accepts a `VGRCalendarDataProviding` conformer for data, a `@Binding` for selection, a `@ViewBuilder` closure for custom day cells, and an optional `onDateTapped` callback. An optional `VGRCalendarActions` object exposes imperative scroll methods (`scrollToToday`, `scrollToDate`).

**VGRCalendarViewController** owns the `VGRCalendarCollectionView`, wires up the data source and delegate, handles selection changes via `reconfigureItems`, and delegates scroll events to the infinite scroll manager. Also implements `UICollectionViewDataSourcePrefetching` for smoother scrolling.

**VGRCalendarCollectionView** is a `UICollectionView` subclass that disables `scrollsToTop` and guards against large VoiceOver-triggered content offset jumps while still allowing normal small swipe-based scrolls.

**VGRCalendarDataSource** wraps `UICollectionViewDiffableDataSource`. It generates `NSDiffableDataSourceSnapshot` with `VGRCalendarSection` (year/month) sections and `VGRCalendarItem` items (real days + placeholder padding). Sections are cached to avoid regeneration.

**VGRCalendarInfiniteScrollManager** monitors `scrollViewDidScroll` and expands the date window (24 months at a time) when the user scrolls within a threshold (~2500pt) of either edge. Backward expansion adjusts `contentOffset` to maintain visual position. A guard flag prevents concurrent expansions.

**VGRCalendarLayout** creates a `UICollectionViewCompositionalLayout` with fractional-width items (1/7), estimated-height groups, month header boundary supplementary items, and section background decoration views.

### Week Calendar (SwiftUI)

```
VGRCalendarWeekView (SwiftUI)
  ├─ VGRCalendarWeekHeaderView (weekday labels)
  └─ ScrollView(.horizontal)
       └─ LazyHStack (paged)
            └─ ForEach weeks → HStack of day cells
```

**VGRCalendarWeekView** is a standalone horizontal paging calendar. It uses `VGRCalendarViewModel` to generate week periods from a `DateInterval`, supports VoiceOver navigation via custom accessibility actions (next/previous week), and manages `@AccessibilityFocusState` for screen reader focus.

### Data Model

| Type | Purpose |
|---|---|
| `VGRCalendarIndexKey` | Lightweight year/month/day struct used as dictionary key and identifier. Provides `accessibilityLabel` with Swedish locale formatting. |
| `VGRCalendarSection` | Year/month identifier for collection view sections. |
| `VGRCalendarItem` | Wraps an `IndexKey` with an `isPlaceholder` flag for padding cells. |
| `VGRCalendarPeriodModel` | Groups days into a period (week or month) with leading padding info. |
| `VGRCalendarViewModel` | `@Observable` class that generates week and month `PeriodModel` arrays from a `DateInterval`. Powers the week view. |
| `VGRCalendarDataProviding` | Protocol for supplying day data and month accessibility labels. `VGRCalendarData` is the default struct implementation. |

### Localization

Calendar strings are defined in `Localizable.strings` under the `calendar.*` namespace (Swedish). Date accessibility labels in `VGRCalendarIndexKey` use Swedish ordinal formatting (e.g. "Måndag, 2:a februari 2026").
