# VGRButton

`VGRButton` är en återanvändbar och stilbar SwiftUI-komponent för att skapa knappar med olika visuella varianter. Den är designad för att vara tillgänglig, flexibel och enkel att använda i olika sammanhang.

---

## ✨ Funktioner

- 🔹 Flera visuella varianter (`primary`, `secondary`, `vertical`, `tertiary`)
- 🧩 Stöd för ikon (valfri) tillsammans med label
- 🔒 Möjlighet att disabla knappen (`isEnabled`)
- 🧑‍🦯 Inbyggt stöd för `accessibilityHint`
- 🧱 Extenderbar via `VGRButtonVariantProtocol`

---

## 🧪 Användning

```swift
VGRButton(label: "Spara", variant: .primary) {
    // Action här
}
```

```swift
VGRButton(
    label: "Avbryt",
    icon: Image(systemName: "xmark"),
    isEnabled: $isFormActive,
    accessibilityHint: "Avbryt formuläret",
    variant: .secondary
) {
    // Avbryt-logik
}
```

---

## 📦 Parametrar

| Parameter           | Typ                | Default         | Beskrivning                                        |
|---------------------|--------------------|------------------|----------------------------------------------------|
| `label`             | `String`           | –                | Texten som visas i knappen                         |
| `icon`              | `Image?`           | `nil`            | Valfri ikon som visas tillsammans med label        |
| `isEnabled`         | `Binding<Bool>`    | `.constant(true)`| Om knappen är klickbar                             |
| `accessibilityHint` | `String`           | `""`             | Tillgänglighetsbeskrivning                         |
| `variant`           | `VGRButtonVariant` | `.primary`       | Visuell stil för knappen                           |
| `action`            | `() -> Void`       | –                | Action som triggas vid tryck                       |

---

## 🎨 Tillgängliga varianter

| Variant     | Beskrivning                            |
|-------------|----------------------------------------|
| `.primary`  | Fylld knapp med vit text               |
| `.secondary`| Transparent knapp med färgad kant      |
| `.vertical` | Vertikal layout, ikon ovanför text     |
| `.tertiary` | Ljus bakgrund med låg visuell vikt     |

---

## 🧱 Struktur

Komponenten är uppbyggd enligt en **variantbaserad design**, där varje stil implementerar `VGRButtonVariantProtocol`. En `variant` skickas in i konstruktorn och styr hur knappen renderas.

---

## 📁 Exempel

```swift
VGRButton(label: "Skicka", icon: Image(systemName: "paperplane"), variant: .primary) {
    print("Skickat!")
}
```

---

## ✅ Tillgänglighet

- `accessibilityHint` kan anges för att hjälpa VoiceOver-användare.
- Om den utelämnas används ett tomt strängvärde.

---

## 👷‍♂️ För att lägga till fler varianter

1. Skapa en ny struct som implementerar `VGRButtonVariantProtocol`
2. Lägg till fallet i `VGRButtonVariant` och returnera din variant i `.resolve()`

---

Made with ❤️ by [Ditt Team / Företag]
