# VGRBodyPickerView

`VGRBodyPickerView` är en SwiftUI-komponent som gör det möjligt för användare att visuellt välja delar av kroppen, både fram- och baksida, via en interaktiv kroppsvy.

## Funktionalitet

- **Segmenterad vy**: Användare kan växla mellan fram- och baksida av kroppen med hjälp av en `Picker`.
- **Markeringslogik**: Markerade kroppsdelar färgläggs och kantmarkeras med särskilda färger.
- **Overlay-stöd**: Frontvyn innehåller valbara överlägg, t.ex. ansiktsdetaljer.

## Användning

```swift
@State var selected: Set<String> = []

VGRBodyPickerView(selectedParts: $selected)
```

## Spårning

Skicka med skärmen som `trackOn` så rapporteras varje tryck på en region i kroppsvyn, och varje chip-tryck i regionarket, som en Matomo-händelse med skärmen som kategori. Utan `trackOn` spåras ingenting.

```swift
VGRBodyPickerView(selectedParts: $selected,
                  trackOn: AppScreen.assessment(action: .create))
```

Endast själva trycket rapporteras, aldrig härledda ändringar (att en region auto-markeras när sista delen väljs, att "övrigt" tas bort, översättning av äldre id:n, eller programmatiska ändringar av bindningen). Varje typ av tryck har en egen action så de kan segmenteras i Matomo utan att tolka id:n. Kroppsdelens id skickas som namn.

| Action | Namn | När |
|--------|------|-----|
| `region_show` | t.ex. `head` | En region i kroppsvyn trycks och arket öppnas |
| `bodypart_selected` / `bodypart_deselected` | t.ex. `head.scalp` | En enskild del trycks |
| `region_selected` / `region_deselected` | t.ex. `head` | Chippen för hela regionen trycks |

Händelserna definieras av `VGRBodyPickerInteraction`.


# VGRBodyView

`VGRBodyView` är en SwiftUI-komponent som gör det att visa en kropp (både fram- och baksida) med valda delar.
