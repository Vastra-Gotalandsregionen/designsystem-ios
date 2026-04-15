# VGRDurationPicker

`VGRDurationPicker` är en SwiftUI-komponent som specialiserar `VGRMultiPickerView` för att välja en tidsangivelse i minuter och sekunder. Komponenten visar två snurrhjul (0–59 vardera) med tillhörande etiketter — all annan layout (rubrik, sammanställning, expandera/komprimera, padding) ligger hos den anropande vyn.

---

## ✨ Funktioner

- Två snurrhjul (minuter och sekunder, 0–59 vardera)
- Etiketter efter respektive hjul som kan anpassas, med svenska standardvärden från komponentbiblioteket
- Ren komponent utan inramning — konsumenten styr layouten

---

## 🧩 Användning

```swift
@State private var minutes: Int = 0
@State private var seconds: Int = 0

VGRDurationPicker(minutes: $minutes, seconds: $seconds)
```

Med egna etiketter:

```swift
VGRDurationPicker(
    minutes: $minutes,
    seconds: $seconds,
    minutesLabel: "minutes",
    secondsLabel: "seconds"
)
```

## ⚙️ Initialisering

```swift
init(
    minutes: Binding<Int>,
    seconds: Binding<Int>,
    minutesLabel: String? = nil,
    secondsLabel: String? = nil
)
```

- `minutes` / `seconds`: bindningar till valda värden (0–59).
- `minutesLabel` / `secondsLabel`: text efter respektive hjul. Om `nil` används värdena `durationpicker.minutes.full` / `durationpicker.seconds.full` från komponentbibliotekets bundle.

## 🧱 Beroenden

- Bygger ovanpå `VGRMultiPickerView`.

## 📄 Licens

Detta är en intern komponent utvecklad för Västra Götalandsregionen. Kontakta utvecklingsteamet för vidare användning utanför projektets ram.
