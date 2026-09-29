# VGRButton

Mappen innehåller två generationer av designsystemets knapp:

| Komponent     | Status                                      | Mapp   |
|---------------|---------------------------------------------|--------|
| `VGRButtonV2` | **Aktuell**                                 | `V2/`  |
| `VGRButton`   | **Deprecated** – ger kompileringsvarning, migrera till `VGRButtonV2` | `V1/`  |

Båda är variantbaserade: en `variant` skickas in i konstruktorn och en struct som implementerar variantprotokollet styr hur knappen renderas. Skillnaden är att V2 exponerar storlek, bredd och en generisk ikon-slot, och styr aktivt/inaktivt-läge via SwiftUI:s `.disabled(_:)` i stället för en `Binding`.

---

## VGRButton (V1, deprecated)

> Hela V1-familjen (`VGRButton`, `VGRButtonVariant`, `VGRButtonVariantProtocol` och varianterna) är märkt `@available(*, deprecated)`. Dokumentationen nedan finns kvar för befintlig kod.

### ✨ Funktioner

- 🔹 Sex visuella varianter (`primary`, `secondary`, `vertical`, `tertiary`, `listRow`, `listRowDestructive`)
- 🧩 Stöd för ikon (valfri) tillsammans med label
- 🔒 Möjlighet att disabla knappen (`isEnabled`)
- ⏳ Laddningstillstånd (`isLoading`) som visar en spinner och blockerar tryck
- 🧑‍🦯 Inbyggt stöd för `accessibilityHint`
- 🧱 Extenderbar via `VGRButtonVariantProtocol`

### 🧪 Användning

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
    isLoading: $isSaving,
    accessibilityHint: "Avbryt formuläret",
    variant: .secondary
) {
    // Avbryt-logik
}
```

### 📦 Parametrar

| Parameter           | Typ                | Default           | Beskrivning                                        |
|---------------------|--------------------|-------------------|----------------------------------------------------|
| `label`             | `String`           | –                 | Texten som visas i knappen                         |
| `icon`              | `Image?`           | `nil`             | Valfri ikon som visas tillsammans med label        |
| `isEnabled`         | `Binding<Bool>`    | `.constant(true)` | Om knappen är klickbar                             |
| `isLoading`         | `Binding<Bool>`    | `.constant(false)`| Visar laddningsindikator och inaktiverar tryck     |
| `accessibilityHint` | `String`           | `""`              | Tillgänglighetsbeskrivning                         |
| `variant`           | `VGRButtonVariant` | `.primary`        | Visuell stil för knappen                           |
| `action`            | `() -> Void`       | –                 | Action som triggas vid tryck                       |

### 🎨 Tillgängliga varianter

| Variant               | Beskrivning                                                        |
|-----------------------|--------------------------------------------------------------------|
| `.primary`            | Fylld knapp för huvudhandlingar                                    |
| `.secondary`          | Konturknapp för alternativa/kompletterande handlingar              |
| `.vertical`           | Vertikal layout, ikon ovanför text, för kort-liknande knappar      |
| `.tertiary`           | Diskret bakgrund med låg visuell tyngd                             |
| `.listRow`            | List-rad-stil för tryckbara rader i listor, formulär och tabeller  |
| `.listRowDestructive` | List-rad-stil för destruktiva handlingar (t.ex. ta bort)           |

### 👷‍♂️ För att lägga till fler varianter

1. Skapa en ny struct som implementerar `VGRButtonVariantProtocol`
2. Lägg till fallet i `VGRButtonVariant` och returnera din variant i `.resolve()`

---

## VGRButtonV2

Protokolldriven knapp där basen äger action, enabled-state och tillgänglighet och varianten äger allt visuellt. Ikonen är generisk över `View`, så anroparen styr dess färg och storlek medan varianten styr placering.

### 🧪 Användning

```swift
VGRButtonV2("Spara") { save() }

VGRButtonV2("Avbryt", variant: .secondary) { cancel() }

// Kompakt knapp som bara omsluter sitt innehåll
VGRButtonV2("Filter", variant: .tonal, size: .small, fullWidth: false) { showFilter() }

// SF Symbol skalad efter storleken
VGRButtonV2("Lägg till", systemImage: "plus") { add() }

// Egen ikonvy
VGRButtonV2("Lägg till ny", variant: .inline) {
    addNew()
} icon: {
    Image(systemName: "plus.circle.fill")
        .foregroundStyle(Color.Status.successText)
}

// Inaktivera via SwiftUI
VGRButtonV2("Skicka") { send() }
    .disabled(!isValid)
```

### 📦 Parametrar

| Parameter           | Typ                              | Default      | Beskrivning                                                        |
|---------------------|----------------------------------|--------------|--------------------------------------------------------------------|
| `label`             | `String` (osatt etikett)         | –            | Knappens text                                                      |
| `variant`           | `VGRButtonV2Variant`             | `.primary`   | Inbyggd variant (se nedan)                                         |
| `customVariant`     | `any VGRButtonV2VariantProtocol` | –            | Egen variant. Används i stället för `variant`                      |
| `size`              | `VGRButtonV2Size`                | `.medium`    | `.medium` eller `.small`. Styr font, padding och ikonstorlek       |
| `fullWidth`         | `Bool`                           | `true`       | `false` låter knappen omsluta sitt innehåll                        |
| `accessibilityHint` | `String`                         | `""`         | VoiceOver-hint                                                     |
| `systemImage`       | `String?`                        | `nil`        | SF Symbol-namn. Ersätter `icon` och skalas enligt `size.iconSize`  |
| `action`            | `() -> Void`                     | –            | Körs vid tryck                                                     |
| `icon`              | `@ViewBuilder`                   | `EmptyView`  | Egen ikonvy. Ignoreras när `systemImage` är satt                   |

### 🎨 Tillgängliga varianter

| Variant               | Beskrivning                                                       |
|-----------------------|-------------------------------------------------------------------|
| `.primary`            | Huvudåtgärd, fylld och framträdande                               |
| `.primaryInverted`    | Huvudåtgärd på färgad yta, inverterade färger                     |
| `.tonal`              | Mjuk tintad yta med actionfärgad text                             |
| `.secondary`          | Alternativ åtgärd, konturstil                                     |
| `.secondaryInverted`  | Alternativ åtgärd på färgad yta, inverterade färger               |
| `.inline`             | Inline-åtgärd i ett listkort, t.ex. "+ Lägg till ny" i `VGRList`  |
| `.destructive`        | Destruktiv åtgärd                                                 |
| `.destructiveInline`  | Destruktiv inline-åtgärd i ett listkort                           |
| `.verticalPrimary`    | Vertikalt staplad huvudåtgärd, ikon över text                     |

### 👷‍♂️ Egna varianter

Implementera `VGRButtonV2VariantProtocol`. `makeBody(configuration:)` får en `VGRButtonV2Configuration` med `label`, `icon` (typraderad `AnyView`), `isEnabled`, `fullWidth`, `size`, `accessibilityHint` och `action`. Skicka in instansen via `customVariant:`.

```swift
struct MyVariant: VGRButtonV2VariantProtocol {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.action) {
            HStack {
                configuration.icon
                Text(configuration.label).font(configuration.size.font)
            }
        }
        .disabled(!configuration.isEnabled)
    }
}

VGRButtonV2("Special", customVariant: MyVariant()) { ... }
```
