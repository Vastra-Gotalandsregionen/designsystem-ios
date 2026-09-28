# LevelSlider

Diskret nivåväljare för t.ex. smärta eller besvär. Visar ett fält per nivå i ett givet intervall, färgat efter allvarlighetsgrad. Användaren trycker eller drar för att välja. Haptisk återkoppling ges vid varje byte.

---

## Användning

```swift
@State private var painLevel: Int? = nil

LevelSlider(selectedIndex: $painLevel,
            configuration: .migraine) { newIndex in
    save(level: newIndex)
}

// Går inte att avmarkera genom att trycka igen
LevelSlider(selectedIndex: $painLevel,
            isDeselectable: false,
            configuration: .dermatology)
```

| Parameter        | Typ                        | Default | Beskrivning                                                             |
|------------------|----------------------------|---------|-------------------------------------------------------------------------|
| `selectedIndex`  | `Binding<Int?>`            | –       | Vald nivå, `nil` när inget är valt                                      |
| `isDeselectable` | `Bool`                     | `true`  | Tryck på vald nivå nollställer valet                                    |
| `configuration`  | `LevelSliderConfiguration` | –       | Intervall och färger                                                    |
| `action`         | `((Int) -> Void)?`         | `nil`   | Anropas när gesten släpps. Får `selectedIndex ?? 0`                    |

Observera att `action` får `0` när valet nollställts. Läs `selectedIndex` för att skilja "nivå 0" från "inget valt".

---

## LevelSliderConfiguration

Beskriver intervallet och vilken färg varje nivå får i vilande respektive valt läge. Färgerna anges per delintervall. Nivåer utan matchande intervall blir grå.

```swift
let config = LevelSliderConfiguration(
    range: 0...5,
    backgroundRanges: [
        0...0: Color.Accent.greenSurface,
        1...2: Color.Accent.yellowSurface,
        3...5: Color.Accent.redSurface
    ],
    selectedRanges: [
        0...0: Color.Accent.green,
        1...2: Color.Accent.orange,
        3...5: Color.Accent.red
    ]
)
```

### Färdiga konfigurationer

| Konfiguration  | Intervall | Använd av        |
|----------------|-----------|------------------|
| `.migraine`    | `0...5`   | Migrän-appen     |
| `.dermatology` | `0...3`   | Dermatologi-appen |
| `.reumatology` | `0...4`   | Reumatologi      |

---

## Tillgänglighet

Varje nivå är ett eget element med nivåns index som etikett och ett lokaliserat värde ("vald"/"inte vald"). VoiceOver-användare väljer nivå genom att dubbeltrycka på ett element.

## Filer i mappen

| Fil                              | Roll                                       |
|----------------------------------|--------------------------------------------|
| `LevelSlider.swift`              | Vyn och draggesten                         |
| `LevelSliderConfiguration.swift` | Intervall, färger och färdiga konfigurationer |
| `Level.swift`                    | Intern modell för ett fält                 |
| `CustomRoundedRectangle.swift`   | Form med individuellt rundade hörn för ändfälten |
