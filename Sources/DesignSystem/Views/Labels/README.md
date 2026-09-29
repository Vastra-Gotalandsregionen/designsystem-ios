# Labels

Små textetiketter för status och validering.

| Komponent            | Användning                                                   |
|----------------------|--------------------------------------------------------------|
| `VGRFlagLabel`       | Pillformad flagga med symbol och text, färgad efter tillstånd |
| `VGRValidationLabel` | Hjälptext under ett fält eller en lista, med valfritt varningsläge |

---

## VGRFlagLabel

Färger och standardikon styrs av `VGRFlagLabelState`. Både symbol och färger kan skrivas över.

| Tillstånd      | Bakgrund / förgrund                          | Standardikon                  |
|----------------|----------------------------------------------|-------------------------------|
| `.success`     | `Status.successSurface` / `Status.successText`         | `checkmark.circle.fill`       |
| `.warning`     | `Status.warningSurface` / `Status.warningText`         | `xmark.circle.fill`           |
| `.error`       | `Status.errorSurface` / `Status.errorText`             | `exclamationmark.circle.fill` |
| `.information` | `Status.informationSurface` / `Status.informationText` | `minus.circle.fill`           |

```swift
VGRFlagLabel("Taget", state: .success)
VGRFlagLabel("Varning", state: .warning)
VGRFlagLabel("Neutral")                                  // .information är default
VGRFlagLabel("Anpassad", symbolName: "star.fill", state: .success)
VGRFlagLabel("Lila",
             foregroundColor: .Accent.purple,
             backgroundColor: .Accent.purpleSurfaceMinimal)
```

| Parameter         | Typ                  | Default         | Beskrivning                                        |
|-------------------|----------------------|-----------------|----------------------------------------------------|
| `text`            | `LocalizedStringKey` | –               | Etikettens text (osatt etikett)                    |
| `symbolName`      | `String?`            | `nil`           | SF Symbol. `nil` ger tillståndets standardikon     |
| `state`           | `VGRFlagLabelState`  | `.information`  | Styr standardfärger och standardikon               |
| `foregroundColor` | `Color?`             | `nil`           | Ersätter tillståndets förgrundsfärg                |
| `backgroundColor` | `Color?`             | `nil`           | Ersätter tillståndets bakgrundsfärg                |

---

## VGRValidationLabel

Neutral hjälptext som byter till varningsikon och färgad text när `isWarning` är `true`. Använd `warningColor` när varningen är en uppmaning snarare än ett fel, t.ex. för att matcha en omslutande `VGRList` med annan `borderColor`.

```swift
VGRValidationLabel("Välj minst ett alternativ")
VGRValidationLabel("Välj minst ett alternativ", isWarning: true)
VGRValidationLabel("Välj en annan tid",
                   isWarning: true,
                   warningColor: Color.Primary.action)
```

| Parameter      | Typ                  | Default                  | Beskrivning                                  |
|----------------|----------------------|--------------------------|----------------------------------------------|
| `text`         | `LocalizedStringKey` | –                        | Texten (osatt etikett)                       |
| `isWarning`    | `Bool`               | `false`                  | Visar varningsikon och färgar texten         |
| `warningColor` | `Color`              | `Color.Status.errorText` | Färg för text och ikon i varningsläge        |
