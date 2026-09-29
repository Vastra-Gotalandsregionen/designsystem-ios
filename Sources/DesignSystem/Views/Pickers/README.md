# Pickers

Komponenter där användaren väljer ett eller flera värden.

| Mapp                     | Komponenter                                                                 | Dokumentation |
|--------------------------|-----------------------------------------------------------------------------|---------------|
| `BodyPicker/`            | `VGRBodyPickerView`, `VGRBodyView`, `VGRBodyPart`                           | [README](BodyPicker/README.md) |
| `Calendar/`              | `VGRCalendarView` (UIKit-baserad månadskalender), `VGRCalendarWeekView`     | [README](Calendar/README.md) |
| `DateTimePickerPopover/` | `VGRDatePickerPopover`, `.vgrDatePickerPopover(...)`, `.vgrTimePickerPopover(...)` | Källfiler |
| `DurationPicker/`        | `VGRDurationPicker` (minuter och sekunder)                                  | [README](DurationPicker/README.md) |
| `MultiPicker/`           | `VGRMultiPickerView` – `UIPickerView` med flera kolumner                    | Källfiler |
| `RecurrencePicker/`      | `VGRRecurrencePickerView`, `Recurrence`, `RecurrencePeriod`, `RecurrenceWeekday`, `RecurrenceDeviation` | Källfiler |
| `SegmentedPicker/`       | `VGRSegmentedPicker`, `VGRSegmentedControl`                                 | [README](SegmentedPicker/README.md) |
| `SelectionList/`         | `VGRSingleSelectionList`, `VGRMultiSelectionList` och färdiga skärmar       | [README](SelectionList/README.md) |

`Recurrence` delas med notifikationsmodulen i `Logic/Notifications` och beskriver upprepningsmönster för både UI och schemaläggning.
