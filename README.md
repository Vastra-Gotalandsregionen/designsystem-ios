# 💠 VGR Designsystem iOS

Detta är ett delat Swift Package för våra iOS-appar.

Syftet är att tillhandahålla generiska, design/figma-kompatibla UI-komponenter, färger och typografi – allt för att förenkla utveckling, förbättra konsekvens och minska duplicerad kod.

Alla komponenter är prefixed med `VGR` (t.ex. `VGRButton`, `VGRCallout`) för att undvika krock med inbyggda SwiftUI-komponenter och andra externa ramverk.

---

## 📦 Använda designpaketet i din app

Lägg enkelt till det som ett Swift Package i ditt Xcode-projekt:

1. Gå till **File > Add Package Dependencies**
2. Klistra in GitHub-URL:  
   `https://github.com/Vastra-Gotalandsregionen/designsystem-ios.git`
3. Add Package 
4. Importera det i kod:

```swift
import DesignSystem
```

---

## 🚀 Bidra till designsystemet

Vill du _utveckla_ komponenter eller förbättra designsystemet? Följ dessa steg:

### 1. Klona repo:t

### 2. Öppna projektet som du vill utveckla i

- Lägg till det klonade repo:t som ett **local Swift Package** i Xcode (File > Add Package Dependencies > Add Local Package...)
- Peka på din klonade mapp (`designsystem-ios`)

> Nu kan du se och redigera komponenterna direkt från din app.

### 3. Skapa en ny branch

```
git checkout -b feat/namn-på-förändring
```

### 4. Gör dina ändringar och testa dem lokalt

- Bygg och testa i din app med det lokala paketet kopplat.
- Lägg till nya previews där det är relevant.

### 5. Commit + Push

### 6. Skapa en Pull Request

Gör en PR mot `main` via GitHub, begär kodgranskning.

---

## 🧪 Testa komponenter

Komponenter bör ha tydliga `#Preview`-block för att enkelt kunna testas i Xcode.

---

## 🧩 Tillgängliga komponenter

### Knappar & Kontroller
- `VGRButton` - Konfigurerbar knapp med olika stilar (primary, secondary, tertiary, vertical, listRow, listRowDestructive)
- `VGRCloseButton` - Standardiserad stäng-knapp
- `VGRDoneButton` - Klar-knapp med iOS 26-stöd och fallback
- `VGRStepper` - Steg-kontroll för att öka/minska värden
- `VGRToggle` - Anpassad toggle-switch
- `VGRTableRowNavigationLink` - Navigationslänk för tabellrader

### Kort & Utrop
- `VGRCallout` - Informations-/varningsruta med valfria ikoner och illustrationer
- `VGRCalloutV2` - Uppdaterad version av callout-komponenten
- `VGRDisclosureGroup` - Utfällbar innehållsgrupp
- `VGRCalloutDismissButton` - Stäng-knapp för callouts
- `VGRCalloutIllustration` - Illustration för callouts
- `VGRCalloutShape` - Formkomponent för callout-styling
- `VGRCalloutText` - Textkomponent för callouts

### Designelement
- `VGRIcon` - Återanvändbar ikonkomponent med stöd för assets och SF Symbols
- `VGRShape` - Formcontainer med anpassningsbar stil
- `VGRTableRowDivider` - Avdelare för tabellrader
- `Blob` - Animerad blob med Lottie-animationer

### Väljare (Pickers)
- `VGRBodyPickerView` - Kroppsdelväljare för medicinska applikationer
- `VGRCalendarView` - Anpassningsbar kalendervy med dagval
- `VGRCalendarWeekView` - Veckovy för kalendrar
- `VGRCalendarWeekHeaderView` - Header för kalenderveckor
- `VGRCalendarMonthView` - Månadsvy för kalendrar
- `VGRDatePickerPopover` - Datumväljare i popover
- `VGRMultiPickerView` - Flerkolumnsväljare
- `VGRRecurrencePickerView` - Väljare för upprepningsmönster
- `VGRSegmentedPicker` - Segmenterad kontrollväljare

### Layout
- `VGRPortraitLandscapeView` - Vy som anpassar innehåll baserat på enhetens orientering

### Artikelkomponenter
- `VGRContentScreen` - Komplett artikelvy
- `VGRContent` - Datamodell för artiklar
- `VGRContentElement` - Datamodell för artikelelement

### Datamodeller
- `VGRBodyPartData` - Datamodell för kroppsdelsinformation
- `VGRBodyView` - Vykomponent för kroppsdiagram
- `VGRCalendarPeriodModel` - Datamodell för kalenderperioder
- `VGRCalendarIndexKey` - Indexnyckel för kalenderidentifiering

### Stilar & Modifierare
- `VGRDisclosureStyle` - Anpassad stil för disclosure groups
- `vgrTimePickerPopover` - View modifier för tidsväljare i popover

## 🏷 Prefix

Alla komponenter använder prefixet `VGR` för att undvika konflikter med standardbiblioteket eller tredjepartspaket. Undvik att skapa komponenter utan prefix – även för interna strukturer om de kan användas externt.

---

## 📌 Versionsinformation

Paketet inkluderar automatisk version via `LibraryInfo.version`. Du kan enkelt kontrollera vilken version av designsystemet din app använder:

```swift
import DesignSystem

print("Använder DesignSystem version: \(LibraryInfo.version)")
// Output: Använder DesignSystem version: 0.20.0
```
