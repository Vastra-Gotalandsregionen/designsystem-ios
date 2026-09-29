# Inputs

Textinmatning med designsystemets ram, rubrik och varningsläge.

| Komponent      | Användning                                  |
|----------------|---------------------------------------------|
| `VGRTextInput` | Enradigt fält. Fri text, formaterat värde eller `Formatter`-baserat värde |
| `VGRTextArea`  | Flerradigt fält för anteckningar             |

Båda visar en valfri rubrik ovanför fältet och ritar ett rundat, kantat fält. Tangentbordet stängs på Escape (externa tangentbord) via `dismissesKeyboardOnEscape()`.

---

## VGRTextInput

Tre initialiserare väljer hur värdet tolkas:

```swift
// Fri text
@State private var name = ""
VGRTextInput(title: "Namn", value: $name)

// Typat värde via ParseableFormatStyle (.number, .currency(code:), .percent ...)
@State private var age = 0
VGRTextInput(title: "Ålder", placeholder: "0", value: $age, format: .number)

// Legacy Formatter
@State private var amount: Decimal = 0
VGRTextInput(title: "Belopp", value: $amount, formatter: NumberFormatter())

// Varningsram vid valideringsfel
VGRTextInput(title: "E-post", value: $email, showWarning: !isValidEmail)
```

| Parameter      | Typ                     | Default                      | Beskrivning                                          |
|----------------|-------------------------|------------------------------|------------------------------------------------------|
| `title`        | `String?`               | `nil`                        | Rubrik ovanför fältet. `nil` ger fält utan rubrik    |
| `placeholder`  | `String`                | `""`                         | Platshållartext                                      |
| `value`        | `Binding`               | –                            | `String`, `F.FormatInput` eller generiskt `V`        |
| `showWarning`  | `Bool`                  | `false`                      | Ritar fältet med varningsfärgad kant                 |
| `format`       | `ParseableFormatStyle`  | –                            | Endast format-init. `FormatOutput` måste vara `String` |
| `formatter`    | `Formatter`             | –                            | Endast formatter-init                                |
| `keyboardType` | `UIKeyboardType`        | `.default` (`.numberPad` för format-init) | Tangentbord vid fokus                   |

Kombinera med `VGRValidationLabel` under fältet för att förklara varningen.

---

## VGRTextArea

```swift
@State private var notes = ""
VGRTextArea(title: "Anteckningar", value: $notes)

// Egen VoiceOver-etikett när rubriken saknas
VGRTextArea(accessibilityLabel: "Fritextsvar", value: $notes)
```

| Parameter            | Typ               | Default | Beskrivning                                   |
|----------------------|-------------------|---------|-----------------------------------------------|
| `title`              | `String?`         | `nil`   | Rubrik ovanför fältet                         |
| `accessibilityLabel` | `String?`         | `nil`   | VoiceOver-etikett för editorn                 |
| `value`              | `Binding<String>` | –       | Texten                                        |

Minsta höjd är 172 pt och skalar med Dynamic Type.
