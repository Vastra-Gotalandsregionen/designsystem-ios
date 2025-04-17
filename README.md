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
import designsystem
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

## 🏷 Prefix

Alla komponenter använder prefixet `VGR` för att undvika konflikter med standardbiblioteket eller tredjepartspaket:

- ✅ `VGRButton`
- ✅ `VGRCallout`
- ✅ `VGRStepper`

Undvik att skapa komponenter utan prefix – även för interna strukturer om de kan användas externt.
