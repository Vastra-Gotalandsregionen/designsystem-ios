# Views

Alla visuella komponenter i designsystemet, grupperade per ansvarsområde. Varje mapp med egen dokumentation länkas nedan. Komponenter utan egen README har DocC-kommentarer och `#Preview`-block i källfilen.

| Mapp | Innehåll | Dokumentation |
|------|----------|---------------|
| `Alerts/` | `VGRAlert`, `VGRAlertButton`, `.vgrAlert(item:)` – UIKit-baserade alerts med iOS 26-anatomi | [README](Alerts/README.md) |
| `Buttons/` | `VGRButton`, `VGRButtonV2`, `VGRChip`, `VGRChipButton`, `VGRStepper`, `VGRFlexibleStepper`, `VGRToggle`, toolbar-knappar (`VGRCloseButton`, `VGRDoneButton`, `VGRSaveButton`, `VGRCancelButton`, `VGREditButton`) | [Button/README](Buttons/Button/README.md) |
| `Cards/` | `VGRCalloutV3`, `VGRSimpleCallout`, `VGRCalloutV2`, `VGRCardView`, `VGRCardButton`, `VGRPanel`, `VGRDisclosureGroup` | [Callout/README](Cards/Callout/README.md) |
| `Design/` | `VGRIcon`, `VGRShape`, `VGRDivider`, `Blob` | Källfiler |
| `Inputs/` | `VGRTextInput`, `VGRTextArea` | [README](Inputs/README.md) |
| `Labels/` | `VGRFlagLabel`, `VGRValidationLabel` | [README](Labels/README.md) |
| `Layouts/` | `VGRFlowLayout`, `VGRPortraitLandscapeView` | [README](Layouts/README.md) |
| `Lists/` | `VGRContainer`, `VGRSection`, `VGRList` och radkomponenterna | [README](Lists/README.md) |
| `Pickers/` | Body-, kalender-, datum/tid-, duration-, multi-, recurrence-, segment- och selection-pickers | [README](Pickers/README.md) |
| `Screens/` | `VGRContentScreen`, WhatsNew, videokomponenter, `WebView` | [README](Screens/README.md) |
| `Sliders/` | `LevelSlider` | [LevelSlider/README](Sliders/LevelSlider/README.md) |
| `Tips/` | `VGRInlineTipView` (TipKit) | [README](Tips/README.md) |
| `WebSurvey/` | `VGRSurveyScreen` för Microsoft Forms | [README](WebSurvey/README.md) |

## Konventioner

- Publika typer prefixas med `VGR`. Undantag finns av historiska skäl (`Blob`, `LevelSlider`, `WebView`).
- Varje publik vy har ett `#Preview`-block. Deprecated komponenter har sina previews utkommenterade för att slippa Xcode-varningar.
- Färger tas från `Color.Primary`, `Color.Accent`, `Color.Neutral`, `Color.Status` och `Color.Elevation`. Avstånd och radier från `CGFloat.Margins` och `CGFloat.Radius`.
