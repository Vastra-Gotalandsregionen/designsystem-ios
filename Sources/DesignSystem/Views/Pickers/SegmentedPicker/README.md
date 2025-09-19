# VGRSegmentedPicker

`VGRSegmentedPicker` är en SwiftUI-komponent som visar ett anpassningsbart segmenterat val, liknande ett "segmented control" eller tabbval. Den stödjer både fast layout (utan scroll) och horisontell scrollning om antalet val överstiger en angiven gräns.

---

## ✨ Funktioner

- Dynamisk visning av segment baserat på antal objekt
- Automatisk horisontell scrollning vid fler än `nonScrollableItemCount`
- Visuell markering av valt segment
- Anpassningsbar layout
- Tillgänglighetsidentifiering för varje val

---

## 🧩 Användning

```swift
@State private var selectedItem: String? = nil
let items = ["Första", "Andra", "Tredje", "Fjärde", "Femte"]

VGRSegmentedPicker(
    items: items,
    selectedItem: $selectedItem
)
```

Du kan även ange ett valfritt antal som definierar hur många objekt som får plats utan att scrollning aktiveras:

```swift
VGRSegmentedPicker(
    items: items,
    nonScrollableItemCount: 3,
    selectedItem: $selectedItem
)
```

## ⚙️ Initialisering

```swift
init(
    items: [String],
    nonScrollableItemCount: Int = 4,
    selectedItem: Binding<String?>
)
```

- items: Array av strängar som ska visas som val
- nonScrollableItemCount: Antal val som får plats innan scrollning aktiveras
- selectedItem: Ett @Binding till det valda objektet

## 🧱 Beroenden
- Inga externa beroenden.
- Använder interna färgdefinitioner från Color.Primary.action och Color.Elevation.elevation1.


## 📄 Licens

Detta är en intern komponent utvecklad för Västra Götalandsregionen. Kontakta utvecklingsteamet för vidare användning utanför projektets ram.
