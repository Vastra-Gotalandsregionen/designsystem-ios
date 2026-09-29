# Callouts

Callouts är rundade kort som lyfter fram information, varningar eller bekräftelser inline i innehållet. Mappen innehåller tre generationer:

| Komponent          | Status                                | Använd när                                                        |
|--------------------|---------------------------------------|-------------------------------------------------------------------|
| `VGRCalloutV3`     | **Aktuell**                           | Nya vyer. Slot-baserad med `icon`, `header` och `content`         |
| `VGRSimpleCallout` | Aktuell (bekvämlighet ovanpå V3)      | Rubrik/text plus en SF Symbol, inget annat                        |
| `VGRCalloutV2` och byggstenarna `VGRCalloutShape`, `VGRCalloutText`, `VGRCalloutIllustration`, `VGRCalloutDismissButton` | **Deprecated** | Befintlig kod. Migrera till `VGRCalloutV3` |
| `VGRCallout`, `CalloutView` | **Deprecated** | Ska inte användas i ny kod |

Alla varianter delar bakgrundsfärg via `Color.Status.*Surface`. Standard är `informationSurface`; skicka `errorSurface`, `warningSurface` eller `successSurface` för att förmedla allvarlighetsgrad.

---

## VGRCalloutV3

Fast textblock (`title` + `text`) plus tre valfria vy-slots:

- `icon` – glyf till vänster om texten. Döljs för VoiceOver automatiskt.
- `header` – innehåll direkt under texten, i samma rad som ikonen.
- `content` – fullbreddsinnehåll under raden, t.ex. en knapp eller toggle.

Skicka `onDismiss` för att visa en stäng-knapp. Det finns en convenience-init för varje kombination av utelämnade slots, så du anger bara de du behöver.

### Parametrar

| Parameter         | Typ                | Default                           | Beskrivning                                   |
|-------------------|--------------------|-----------------------------------|-----------------------------------------------|
| `title`           | `String`           | `""`                              | Rubrik. Döljs om tom                          |
| `text`            | `String`           | `""`                              | Brödtext under rubriken. Döljs om tom         |
| `backgroundColor` | `Color`            | `Color.Status.informationSurface` | Kortets yta                                   |
| `onDismiss`       | `(() -> Void)?`    | `nil`                             | Visar stäng-knapp när satt                    |
| `icon`            | `@ViewBuilder`     | –                                 | Valfri ledande ikon                           |
| `header`          | `@ViewBuilder`     | –                                 | Valfritt innehåll under texten                |
| `content`         | `@ViewBuilder`     | –                                 | Valfritt fullbreddsinnehåll                   |

### Användning

```swift
// Enbart text
VGRCalloutV3(title: "Uppmärksamma detta",
             text: "Du har använt läkemedel fler dagar än rekommenderat.")

// Ikon + stäng-knapp + varningsfärg
VGRCalloutV3(title: "Sessionen går ut snart",
             text: "Spara ditt arbete.",
             backgroundColor: Color.Status.warningSurface,
             onDismiss: { dismissed = true },
             icon: { Image(systemName: "clock") })

// Ikon + åtgärd i content-sloten
VGRCalloutV3(text: "Läs mer för att förstå riskerna.",
             icon: { Image(systemName: "info.circle") },
             content: {
                 VGRButton(label: "Läs mer", variant: .secondary) { openArticle() }
             })
```

---

## VGRSimpleCallout

Tunt lager ovanpå `VGRCalloutV3` för det vanligaste fallet: rubrik och/eller text med en ikon. Tar antingen en `@ViewBuilder icon` eller ett `systemImage`-namn som renderas via `VGRSystemIcon` (skalad 25 pt, `Color.Neutral.text`).

| Parameter         | Typ         | Default                           | Beskrivning                                |
|-------------------|-------------|-----------------------------------|--------------------------------------------|
| `title`           | `String`    | `""`                              | Rubrik                                     |
| `text`            | `String`    | `""`                              | Brödtext                                   |
| `backgroundColor` | `Color`     | `Color.Status.informationSurface` | Kortets yta                                |
| `iconAlignment`   | `Alignment` | `.top`                            | Ikonens vertikala placering mot texten     |
| `systemImage`     | `String`    | –                                 | SF Symbol-namn (alternativ till `icon`)    |

```swift
VGRSimpleCallout(title: "Nyhet", systemImage: "sparkles")

VGRSimpleCallout(text: "Kontrollera din anslutning.",
                 backgroundColor: Color.Status.errorSurface,
                 iconAlignment: .center,
                 systemImage: "wifi.slash")
```

---

## VGRCalloutV2 (deprecated)

Föregångaren till V3, märkt `@available(*, deprecated)`. Dokumentationen finns kvar för befintlig kod. Tar en färdig `Image` och en `imageType` som styr storleken (`.icon` 25 pt, `.illustration` 100 pt). Extra innehåll läggs i en `content`-closure under texten.

| Parameter         | Typ                 | Default                           | Beskrivning                                   |
|-------------------|---------------------|-----------------------------------|-----------------------------------------------|
| `header`          | `String?`           | `nil`                             | Rubrik                                        |
| `description`     | `String`            | –                                 | Brödtext (obligatorisk)                       |
| `backgroundColor` | `Color`             | `Color.Status.informationSurface` | Kortets yta                                   |
| `image`           | `Image?`            | `nil`                             | Ikon eller illustration                       |
| `imageType`       | `ImageType`         | `.none`                           | `.none`, `.icon` eller `.illustration`        |
| `dismiss`         | `(() -> Void)?`     | `nil`                             | Visar stäng-knapp när satt                    |
| `content`         | `@ViewBuilder`      | `EmptyView`                       | Valfritt innehåll under texten                |

```swift
VGRCalloutV2(description: "Enklaste varianten, enbart text")

VGRCalloutV2(header: "Rubrik",
             description: "Text med illustration",
             image: Image("illustration_presenting", bundle: .module),
             imageType: .illustration,
             dismiss: { hide() })
```

Byggstenarna `VGRCalloutShape`, `VGRCalloutText`, `VGRCalloutIllustration` och `VGRCalloutDismissButton` är deprecated tillsammans med V2. V3 använder dem inte.

---

## Illustrationer

Paketet levererar illustrationer i `Assets.xcassets/Callouts` (t.ex. `illustration_notice`, `illustration_presenting`, `illustration_settings`). Ladda dem med `Image("illustration_notice", bundle: .module)` eller via `VGRCalloutIllustration(assetName:)`.

---

## Tillgänglighet

- Ikoner är `.accessibilityHidden(true)` i både V2 och V3. Förmedla betydelsen i `title`/`text`.
- Stäng-knappen visas bara när `onDismiss`/`dismiss` anges.
- Texten använder designsystemets typografi och följer Dynamic Type.
