# VGRSegmentedPicker och VGRSegmentedControl

Två segmenterade val med samma API men olika utseende. Båda är generiska över `Item: Hashable`, stödjer fast layout eller horisontell scroll beroende på antal objekt, och sätter ett tillgänglighets-id per val.

| Komponent              | Utseende                                                                    | Default `nonScrollableItemCount` |
|------------------------|-----------------------------------------------------------------------------|----------------------------------|
| `VGRSegmentedPicker`   | Rektangulära segment, valt segment markeras med fylld bakgrund              | `4`                              |
| `VGRSegmentedControl`  | Kapselformad behållare med tunn kant, valt segment blir en fylld kapsel med bock (som `VGRChip`) | `5`                 |

---

## ✨ Funktioner

- Dynamisk visning av segment baserat på antal objekt
- Automatisk horisontell scrollning vid fler objekt än `nonScrollableItemCount`
- Visuell markering av valt segment
- Generisk över typ – strängar fungerar direkt, egna typer via `displayText`
- Tillgänglighetsidentifiering för varje val

---

## 🧩 Användning

Med strängar:

```swift
@State private var selectedItem: String? = nil
let items = ["Första", "Andra", "Tredje", "Fjärde", "Femte"]

VGRSegmentedPicker(items: items, selectedItem: $selectedItem)
```

Ange hur många objekt som får plats innan scrollning aktiveras:

```swift
VGRSegmentedPicker(items: items,
                   nonScrollableItemCount: 3,
                   selectedItem: $selectedItem)
```

Med en egen typ:

```swift
enum Period: Hashable, CaseIterable { case day, week, month }
@State private var period: Period? = .week

VGRSegmentedControl(items: Period.allCases,
                    selectedItem: $period,
                    displayText: { $0.title },
                    accessibilityId: { "period_\($0)" })
```

---

## ⚙️ Initialisering

Generisk init (båda komponenterna):

```swift
init(items: [Item],
     nonScrollableItemCount: Int = 4,   // 5 för VGRSegmentedControl
     itemIdealWidth: CGFloat = 100,
     selectedItem: Binding<Item?>,
     displayText: @escaping (Item) -> String,
     accessibilityId: @escaping (Item) -> String = { "\($0)" })
```

Convenience-init när `Item == String` (använder strängen som både text och tillgänglighets-id):

```swift
init(items: [String],
     nonScrollableItemCount: Int = 4,   // 5 för VGRSegmentedControl
     itemIdealWidth: CGFloat = 100,
     selectedItem: Binding<String?>)
```

| Parameter                | Beskrivning                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `items`                  | Objekten som visas som val                                                  |
| `nonScrollableItemCount` | Antal val som får plats innan scrollning aktiveras                          |
| `itemIdealWidth`         | Önskad bredd per objekt i scrollande läge                                   |
| `selectedItem`           | `Binding` till det valda objektet, `nil` när inget är valt                  |
| `displayText`            | Returnerar texten för ett objekt                                            |
| `accessibilityId`        | Returnerar tillgänglighets-id för ett objekt. Default är `"\(item)"`        |

---

## 🧱 Beroenden

- Inga externa beroenden.
- Använder färgtokens `Color.Primary.action` och `Color.Elevation.elevation1`.

## 📄 Licens

Detta är en intern komponent utvecklad för Västra Götalandsregionen. Kontakta utvecklingsteamet för vidare användning utanför projektets ram.
