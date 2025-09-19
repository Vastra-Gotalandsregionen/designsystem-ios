# VGRBodyPickerView

`VGRBodyPickerView` är en SwiftUI-komponent som gör det möjligt för användare att visuellt välja delar av kroppen, både fram- och baksida, via en interaktiv kroppsvy.

## Funktionalitet

- **Segmenterad vy**: Användare kan växla mellan fram- och baksida av kroppen med hjälp av en `Picker`.
- **Markeringslogik**: Markerade kroppsdelar färgläggs och kantmarkeras med särskilda färger.
- **Overlay-stöd**: Frontvyn innehåller valbara överlägg, t.ex. ansiktsdetaljer.

## Användning

```swift
@State var frontSelected: Set<VGRBodyPart> = []
@State var backSelected: Set<VGRBodyPart> = []

BodyPickerView(frontSelectedParts: $frontSelected,
               backSelectedParts: $backSelected)
```


# VGRBodyView

`VGRBodyView` är en SwiftUI-komponent som gör det att visa en kropp (både fram- och baksida) med valda delar.
