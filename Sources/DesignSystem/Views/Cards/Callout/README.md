# VGRCallout

`VGRCallout` är en återanvändbar SwiftUI-komponent för att visa informations- eller varningsmeddelanden i olika visuella varianter. Den stödjer ikoner, illustrationer, åtgärdsknappar och stäng-knappar i ett flexibelt och tillgängligt format.

---

## ✨ Funktioner

- ℹ️ Visuella varianter för både `information` och `warning`
- 🖼️ Stöd för illustrationer (`VGRIllustration`) och ikoner (`VGRIcon`)
- 🔘 Valfri `VGRButton` för åtgärder
- ❌ Inbyggd stäng-knapp (`DismissButton`)
- 🧑‍🦯 Anpassar layout vid tillgänglighetsinställningar (t.ex. stor text)
- 🧱 Modulär uppbyggnad med återanvändbara komponenter

---

## 🧪 Användning

```swift
VGRCallout(
    text: VGRCalloutText(
        header: "⚠️ Uppmärksamma detta",
        description: "Du har använt läkemedel fler dagar än rekommenderat. Läs mer för att förstå riskerna."
    ),
    button: VGRButton(label: "Läs mer") {
        print("Tryck!")
    },
    variant: .warningWithIllustration(VGRIllustration(assetName: "illustration_warning"))
) {
    print("Stängd")
}
```

```swift
VGRCallout(
    text: VGRCalloutText(description: "Detta är en informationsruta."),
    variant: .information
)
```

---

## 🎨 Tillgängliga varianter

```swift
.information
.informationWithIcon(VGRIcon)
.informationWithIllustration(VGRIllustration)
.warning
.warningWithIcon(VGRIcon)
.warningWithIllustration(VGRIllustration)
```

---

## 🧱 Struktur

```text
VGRCallout
├── VGRCalloutText          // Visar header + beskrivning
├── VGRIcon                 // Ikon från asset eller SF Symbol
├── VGRIllustration         // Illustration i olika storlekar
├── VGRButton               // Valfri åtgärdsknapp
├── DismissButton           // Valfri stäng-knapp (xmark)
└── VGRCalloutShape         // Bakgrund baserat på variant
```

---

## ✅ Tillgänglighet

```swift
// Illustrationer och ikoner är .accessibilityHidden(true)
// Texten är korrekt stylad via .headline och .footnote
// DismissButton visas endast om dismiss-closure anges
// Layout byts från HStack → VStack vid stor text:
```

---

## 🧪 Exempel

```swift
VGRCallout(
    text: VGRCalloutText(
        header: "ℹ️ Info",
        description: "Detta är en enkel informationsruta med ikon."
    ),
    variant: .informationWithIcon(VGRIcon(system: "info.circle"))
)
```

---
