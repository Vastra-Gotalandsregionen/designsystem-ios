# 💠 VGR Designsystem iOS

Delat Swift Package för Västra Götalandsregionens iOS-appar (dermatologi, migrän, epilepsi med flera). Paketet innehåller Figma-kompatibla UI-komponenter, färg- och typografitokens, samt gemensam logik för notifikationer och spårning. Syftet är enhetligt utseende, mindre duplicerad kod och snabbare utveckling.

Alla publika komponenter är prefixade med `VGR` (t.ex. `VGRButton`, `VGRList`) för att undvika krockar med SwiftUI och tredjepartsbibliotek. Några äldre typer saknar prefix av historiska skäl (`Blob`, `LevelSlider`, `WebView`, `Recurrence`, `Tracker`, `Notification*`).

---

## 📋 Krav och beroenden

| | |
|---|---|
| Plattform | iOS 18.0+ |
| Swift tools | 6.0 |
| Standardspråk | Svenska (`defaultLocalization: "sv"`) |

Paketet drar in två externa beroenden. Du behöver inte lägga till dem själv, men de följer med i din app:

| Beroende | Version | Används av |
|---|---|---|
| [matomo-sdk-ios](https://github.com/matomo-org/matomo-sdk-ios) | 7.5+ | `Tracker` (Matomo-spårning) |
| [lottie-spm](https://github.com/airbnb/lottie-spm) | 4.5+ | `Blob` och kvittensanimationen i `VGRSurveyScreen` |

---

## 📦 Använda designpaketet i din app

1. Gå till **File > Add Package Dependencies**
2. Klistra in `https://github.com/Vastra-Gotalandsregionen/designsystem-ios.git`
3. Välj versionsregel **Up to Next Minor** eller pinna en exakt tagg (se [Versionshantering](#-versionshantering))
4. Importera i kod:

```swift
import DesignSystem
```

### Snabbstart

```swift
import SwiftUI
import DesignSystem

struct SettingsScreen: View {
    @State private var remindersOn = true
    @State private var name = ""

    var body: some View {
        VGRContainer {
            VGRSection(header: "Profil") {
                VGRList {
                    VGRTextInput(title: "Namn", value: $name)
                    VGRToggleRow(title: "Påminnelser", isOn: $remindersOn)
                    VGRNavRow(title: "Kontaktuppgifter") { ContactDetailsView() }
                }
            }

            VGRSection {
                VGRSimpleCallout(text: "Dina uppgifter sparas lokalt på enheten.",
                                 systemImage: "lock")
                VGRButton(label: "Spara") { save() }
            }
        }
        .navigationTitle("Inställningar")
    }
}
```

---

## 🎨 Design tokens

Färger, typografi och avstånd exponeras som statiska medlemmar på `Color`, `Font` och `CGFloat`. Alla färger har ljust och mörkt läge. Fullständig tabell finns i [Extensions/README](Sources/DesignSystem/Extensions/README.md).

### Färger

| Familj | Innehåll | Exempel |
|---|---|---|
| `Color.Primary` | Actionfärg, basfärg och blå i varianter för text, yta och grafik | `.action`, `.base`, `.blueSurfaceMinimal` |
| `Color.Accent` | Nio accentfärger (brown, cyan, green, lime, orange, pink, purple, red, yellow), var och en med `Graphic`, `Surface`, `SurfaceBold`, `SurfaceMinimal` | `.purple`, `.greenSurface`, `.redSurfaceBold` |
| `Color.Neutral` | Text, kanter, avdelare och inaktiverade tillstånd | `.text`, `.textVariant`, `.border`, `.divider` |
| `Color.Status` | Yta och text för `information`, `success`, `warning`, `error` | `.errorSurface`, `.successText` |
| `Color.Elevation` | Bakgrund och fem nivåer av upphöjda ytor | `.background`, `.elevation1` |

Namnkonventionen är `<färg>` för förgrund och grafik, `<färg>Surface` för bakgrund, `<färg>SurfaceMinimal` för den ljusaste ytan och `<färg>Fixed` för färger som inte byter i mörkt läge.

### Typografi

`Font` får viktade varianter av systemstilarna så att Dynamic Type bevaras: `.bodyRegular`, `.bodyMedium`, `.bodySemibold`, `.bodyBold`, `.footnoteRegular` … `.footnoteBold`, `.headlineSemibold`, `.headlineBold`, `.titleSemibold`, `.title2Bold`, `.title3Semibold`, `.subheadlineSemibold`, `.captionBold` med flera.

### Avstånd och radier

| Token | Värden |
|---|---|
| `CGFloat.Margins` | `xtraSmall` 8, `small` 12, `medium` 16, `large` 24, `xtraLarge` 32, `safeArea` 16 |
| `CGFloat.Radius` | `smallSchema` 8, `mainRadius` 26, `large38` 38, `vgrCorner` 40, `screen` 62 |
| `CGFloat.Letterspacing` | `small` 0.2, `medium` 0 |

```swift
VStack(spacing: .Margins.medium) { ... }
    .padding(.Margins.large)
    .background(Color.Elevation.elevation1)
    .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
```

---

## 🧩 Komponenter

Varje mapp under `Sources/DesignSystem/Views` har en README med parametrar och exempel. Översikten finns i [Views/README](Sources/DesignSystem/Views/README.md).

| Område | Komponenter | Dokumentation |
|---|---|---|
| Listor | `VGRContainer`, `VGRSection`, `VGRList` och rader: `VGRListRow`, `VGRLabelRow`, `VGRNavRow`, `VGRCheckRow`, `VGRSelectRow`, `VGRToggleRow`, `VGRMenuRow`, `VGRDatePickerRow`, `VGRNoteRow` | [Lists](Sources/DesignSystem/Views/Lists/README.md) |
| Knappar | `VGRButtonV2`, `VGRChip`, `VGRChipButton`, `VGRStepper`, `VGRFlexibleStepper`, `VGRToggle`, toolbar-knappar (`VGRCloseButton`, `VGRDoneButton`, `VGRSaveButton`, `VGRCancelButton`, `VGREditButton`) | [Button](Sources/DesignSystem/Views/Buttons/Button/README.md) |
| Kort och callouts | `VGRCalloutV3`, `VGRSimpleCallout`, `VGRCardView`, `VGRCardButton`, `VGRPanel`, `VGRDisclosureGroup` | [Callout](Sources/DesignSystem/Views/Cards/Callout/README.md) |
| Alerts | `VGRAlert`, `.vgrAlert(item:)` med iOS 26-anatomi | [Alerts](Sources/DesignSystem/Views/Alerts/README.md) |
| Inmatning | `VGRTextInput`, `VGRTextArea` | [Inputs](Sources/DesignSystem/Views/Inputs/README.md) |
| Etiketter | `VGRFlagLabel`, `VGRValidationLabel` | [Labels](Sources/DesignSystem/Views/Labels/README.md) |
| Väljare | `VGRBodyPickerView`, `VGRCalendarView`, `VGRCalendarWeekView`, `VGRDatePickerPopover`, `VGRDurationPicker`, `VGRMultiPickerView`, `VGRRecurrencePickerView`, `VGRSegmentedPicker`, `VGRSegmentedControl`, `VGRSingleSelectionList`, `VGRMultiSelectionList` | [Pickers](Sources/DesignSystem/Views/Pickers/README.md) |
| Layout | `VGRFlowLayout`, `VGRPortraitLandscapeView` | [Layouts](Sources/DesignSystem/Views/Layouts/README.md) |
| Skärmar | `VGRContentScreen`, `VGRWhatsNewScreen`, `VGRVideoCarousel`, `VGRVideoPlayer`, `VGRVideoListScreen`, `VGRFeedbackView`, `WebView` | [Screens](Sources/DesignSystem/Views/Screens/README.md) |
| Enkät | `VGRSurveyScreen` för Microsoft Forms | [WebSurvey](Sources/DesignSystem/Views/WebSurvey/README.md) |
| Tips | `VGRInlineTipView` (TipKit) | [Tips](Sources/DesignSystem/Views/Tips/README.md) |
| Slider | `LevelSlider` | [LevelSlider](Sources/DesignSystem/Views/Sliders/LevelSlider/README.md) |
| Designelement | `VGRIcon`, `VGRShape`, `VGRDivider`, `Blob` | Källfiler |

### Deprecated

Dessa finns kvar för bakåtkompatibilitet och ger kompileringsvarningar. Använd ersättaren.

| Deprecated | Ersätts av |
|---|---|
| `VGRCallout`, `CalloutView`, `VGRCalloutV2` och V2-byggstenarna | `VGRCalloutV3` |
| `VGRButton`, `ActionButton` | `VGRButtonV2` |
| `VGRTableRowNavigationLink` | `VGRNavRow` i en `VGRList` |
| `VGRTableRowDivider` | `VGRDivider` |
| `VGRVideoPlayerView` | `VGRVideoPlayer` |
| `TrackerScreen`, `.track(TrackerScreen)` | Egen `TrackableScreen`-enum i appen |

---

## ⚙️ Logik och hjälpare

| Modul | Innehåll | Dokumentation |
|---|---|---|
| `Logic/Notifications` | `NotificationManager` med lagring, schemaläggning, bakgrundsuppdatering och `@Environment(\.notifications)` | [Notifications](Sources/DesignSystem/Logic/Notifications/README.md) |
| `Logic/Matomo` | `Tracker.shared`, `TrackableScreen`, `TrackableInteraction`, `.track(_:)` | [Matomo](Sources/DesignSystem/Logic/Matomo/README.md) |
| `Logic/Haptics.swift` | `Haptics.lightImpact()`, `.mediumImpact()`, `.heavyImpact()`, `.success()`, `.warning()`, `.error()` | Källfil |
| `Logic/Accessibility` | `AccessibilityHelpers.postPrioritizedAnnouncement(_:withPriority:)`, `.postAnnouncementWithDelay(_:delay:)` | Källfil |
| `Modifiers` | `.onDayChange { }` – körs när enhetens datum byter dag | Källfil |
| `Gestures` | `.onSwipe { direction in }` med `SwipeGesture.Direction` | Källfil |
| `Extensions` | `Date`, `Calendar`, `DateInterval`, `String`, `Bundle` och `View`-hjälpare samt alla tokens | [Extensions](Sources/DesignSystem/Extensions/README.md) |

---

## 🌍 Lokalisering

Paketet är svenskspråkigt. Alla strängar ligger i `Sources/DesignSystem/Assets/sv.lproj/Localizable.strings` med prefix per komponent (`bodypicker.*`, `recurrence.*`, `alert.*`, `calendar.*` …). Komponenterna läser dem via `String.localizedBundle`, som alltid slår upp i paketets eget bundle.

Konsekvenser för din app:

- Komponenternas inbyggda texter (t.ex. "Avbryt", "Klar", kroppsdelsnamn) kan inte skrivas över från appen utan att ändra i paketet.
- Texter du själv skickar in (`title`, `label`, `header`) lokaliseras i appen som vanligt.
- Fler språk kräver en ny `<lang>.lproj` i paketet.

---

## 📌 Versionshantering

Versionen sätts automatiskt av GitHub Actions vid varje push till `main` (`.github/workflows/version.yml` kör `versioning.sh`):

| Ändring i commiten | Bump | Exempel |
|---|---|---|
| Filer tillagda eller borttagna | Minor | `0.73.0` → `0.74.0` |
| Endast befintliga filer ändrade | Patch | `0.73.0` → `0.73.1` |

Workflowen skriver `VERSION`, genererar `LibraryInfo.swift`, committar med `[CI]` i meddelandet och skapar en git-tagg med versionsnumret (utan `v`). Taggen är det du pinnar mot i din app. Det finns ingen CHANGELOG, så PR-titlarna mellan två taggar är releasenoteringen.

Kontrollera vilken version din app kör:

```swift
print("DesignSystem \(LibraryInfo.version)")
```

---

## 🚀 Bidra till designsystemet

### Utveckla med lokalt paket

1. Klona repot.
2. Öppna appen du vill utveckla i. Lägg till det klonade repot som **lokalt** paket: File > Add Package Dependencies > Add Local Package.
3. Xcode använder nu din lokala kopia i stället för taggen. Kom ihåg att byta tillbaka innan appen släpps.

### Arbetsflöde

1. Skapa en branch: `feature/<beskrivning>` för nytt, `fix/<beskrivning>` för rättningar.
2. Gör ändringen. Lägg till eller uppdatera `#Preview`-block och komponentens README.
3. Öppna en PR mot `main` och begär granskning. PR:er squash-mergas.
4. När PR:en mergas bumpas versionen automatiskt (se ovan).

### Testa

- Varje publik vy ska ha ett `#Preview`-block. Det är den primära testytan.
- Enhetstester ligger i `Tests/designsystem-Tests` och körs med **Product > Test** i Xcode med paketet öppet. Idag testas `Recurrence` och `VGRNavRow`.

### Dokumentation

- README-filer skrivs på **svenska**. Kodkommentarer och `///`-dokumentation skrivs på **engelska**.
- Varje mapp under `Views` med publika komponenter har en README med parametertabell och exempel.
- Nya publika typer får `///`-kommentarer. Länka relaterade typer med dubbla backticks (``VGRList``) så DocC kan följa dem.

### Prefix

Alla nya publika typer prefixas med `VGR`, även interna strukturer om de kan användas externt.
