# Screens

Hela skärmar och de modeller som driver dem. Alla tre huvuddelarna är datadrivna: appen levererar JSON (vanligtvis som `NSDataAsset` eller från nätet), designsystemet renderar.

| Mapp        | Innehåll                                                                     |
|-------------|------------------------------------------------------------------------------|
| `Content/`  | `VGRContentScreen` – artikel-, FAQ-, policy- och videofeed-skärmar från `VGRContent` |
| `Content/Video/` | `VGRVideoPlayer`, `VGRVideoCarousel`, `VGRVideoCard`, `VGRVideoListScreen`, `VGRVideoStatusService` |
| `Content/Views/Feedback/` | `VGRFeedbackView` – "Var innehållet till hjälp?" med valbara orsaker |
| `WhatsNew/` | `VGRWhatsNewScreen` och `VGRWhatsNewService` – nyhetskarusell per appversion |
| `WebView.swift` | `WebView` – enkel `WKWebView`-wrapper för en URL                        |
| Content/Audio/| `VGRAudioCard` – kort för ett ljudklipp med ikon, titel och längd |

---

## Content

### VGRContentScreen

Renderar ett `VGRContent` som en scrollande skärm med navigationstitel, stängknapp och tillgänglighetsgruppering. Titeln härleds från `content.type` om `title` är tom.

```swift
VGRContentScreen(content: article) {
    dismiss()
}

// Med callbacks och egen rendering av .custom-element
VGRContentScreen(
    content: article,
    onFeedbackSubmitted: { result in track(result) },
    onActionCallout: { actionId in handle(actionId) },
    onVideoSelected: { video in selectedVideo = video }
) { element in
    MyCustomElementView(element)
}
```

| Parameter             | Typ                                 | Default | Beskrivning                                                         |
|-----------------------|-------------------------------------|---------|---------------------------------------------------------------------|
| `title`               | `String`                            | `""`    | Navigationstitel. Tom sträng ger typbaserad titel                   |
| `content`             | `VGRContent`                        | –       | Innehållet                                                          |
| `dismissAction`       | `(() -> Void)?`                     | `nil`   | Körs vid stäng. `nil` använder `@Environment(\.dismiss)`            |
| `onFeedbackSubmitted` | `((VGRFeedbackResult) -> Void)?`    | `nil`   | När ett `.feedback`-element besvaras                                |
| `onActionCallout`     | `((String) -> Void)?`               | `nil`   | När knappen i ett `.actionCallout`-element trycks, med `actionId`   |
| `onVideoSelected`     | `((VGRVideo) -> Void)?`             | `nil`   | När en video väljs. `nil` låter skärmen visa spelaren själv         |
| `customElementView`   | `(VGRContentElement) -> CustomView` | –       | Renderar `.custom`-element (egen init)                              |

### Modeller

`VGRContent` är `Decodable` och innehåller `id`, `type`, `title`, `subtitle`, `imageUrl`, `publishDate`, `tags` och en lista `elements`.

`VGRContentType` avgör skärmens rubrik och beteende: `article`, `tips`, `useragreement`, `privacypolicy`, `accessibilitystatement`, `faq`, `videofeed`, `warning`, `threshold`.

`VGRContentElementType` styr hur varje `VGRContentElement` renderas:

| Grupp      | Typer                                                                  |
|------------|------------------------------------------------------------------------|
| Text       | `h1`, `h2`, `h3`, `heading`, `subhead`, `body`, `footnote`             |
| Listor     | `list`, `ordered`, `faq`                                               |
| Media      | `image`, `video`                                                       |
| Länkar     | `link`, `webviewLink`, `internalLink`, `internalVideoSelectorLink`, `linkGroup` |
| Interaktion | `feedback`, `actionCallout`, `custom`                                 |

### Video

`VGRVideoCarousel` och `VGRVideoListScreen` visar `VGRVideoCard`-kort för videor i ett `VGRContent` av typen `videofeed`. Appen presenterar spelaren själv via `onItemTapped`/`onVideoSelected`, normalt i en `.fullScreenCover` med `VGRVideoPlayer`. Tittarstatus läses från `VGRVideoStatusService.shared` och skrivs av appen från spelarens callbacks. Se [VGRVideoStatusService_README](Content/Video/VGRVideoStatusService_README.md).

`VGRVideoPlayerView` är deprecated. Använd `VGRVideoPlayer`.

### Feedback

`VGRFeedbackView(articleId:options:onFeedbackSubmitted:)` ställer frågan om innehållet hjälpte. Vid "Nej" öppnas `VGRFeedbackOptionsSheet` med orsaker från `VGRFeedbackOption`. Resultatet levereras som `VGRFeedbackResult`. `VGRContentScreen` renderar den automatiskt för `.feedback`-element.

---

## WhatsNew

Visar vad som är nytt i appen som en sidindelad karusell med bakåt-, hoppa över- och nästa-knappar.

```swift
// Skapas en gång, t.ex. i appens root
let whatsNew = VGRWhatsNewService(assetName: "version_content",
                                  userDefaultsKey: "viewedNews")

// Vid start
if let version = whatsNew.getAllUnseenVersions().first {
    showWhatsNew = version
}

.fullScreenCover(item: $showWhatsNew) { version in
    VGRWhatsNewScreen(version.changes) {
        whatsNew.dismissVersion(version.id)
        showWhatsNew = nil
    }
}
```

### VGRWhatsNewService

Läser en JSON-array av `VGRWhatsNewVersion` från ett `NSDataAsset` och sparar sedda versions-id:n i `UserDefaults`.

| Metod                          | Beskrivning                                                |
|--------------------------------|------------------------------------------------------------|
| `getAllUnseenVersions(_ maxCount: Int = 2)` | Osedda versioner, nyast först, begränsat antal |
| `dismissVersion(_:)`           | Markerar en version som sedd                               |
| `undismissVersion(_:)`         | Ångrar markeringen                                         |
| `resetAllSeenVersions()`       | Tömmer listan över sedda versioner                         |
| `getSeenVersions()` / `setSeenVersions(_:)` | Läs eller skriv listan direkt                 |
| `getAllVersions()`             | Alla versions-id:n i assetfilen                            |

### JSON-format

```json
[
  {
    "id": "2.4.0",
    "title": "Nyheter i 2.4",
    "body": "Kort sammanfattning",
    "image": "whatsnew_240",
    "changes": [
      {
        "order": 1,
        "template": "full",
        "elements": [
          { "order": 1, "type": "h1", "text": "Ny kalender" },
          { "order": 2, "type": "body", "text": "Nu kan du ..." },
          { "order": 3, "type": "image", "text": "", "url": "calendar_promo",
            "width": 300, "height": 200, "padding": [0, 16, 0, 16] }
        ]
      }
    ]
  }
]
```

`id` måste vara en giltig semver-sträng och tolkas till `VGRSemver`. `template` är `"full"` eller `"half"` och styr hur stor del av sidan bakgrunden täcker. Elementtyper är `h1`, `subhead`, `body`, `image` och `panel` (en grupp av element). `padding` anges som `[top, leading, bottom, trailing]`. `text` stödjer markdown via `attributedText`.

---

## WebView

Minimal `UIViewRepresentable` runt `WKWebView` som laddar en URL-sträng en gång. Ingen navigering, laddningsindikator eller felhantering. För enkäter, använd `VGRSurveyScreen` i `WebSurvey/` i stället.

```swift
NavigationStack {
    WebView(urlString: "https://www.vgregion.se")
        .navigationTitle("VGR")
}
```

---

## Audio

`VGRAudioCard` visar ett ljudklipp som ett kort med en färgad cirkel med SF Symbol, titel och längd i minuter. Kortet har ingen egen tryckhantering. Appen lindar in det i en `Button` eller `NavigationLink` och presenterar ljudspelaren själv.

```swift
VGRAudioCard(
    title: "Andningsövning",
    iconName: "waveform",
    duration: 5
)
.frame(width: 192)

// Med egen cirkelfärg
VGRAudioCard(
    title: "Avslappning",
    circleColor: Color.Accent.greenSurface,
    iconName: "waveform",
    duration: 12
)
```

| Parameter     | Typ     | Default                         | Beskrivning                                              |
|---------------|---------|---------------------------------|----------------------------------------------------------|
| `title`       | `String` | –                              | Ljudklippets titel. Trunkeras efter två rader            |
| `circleColor` | `Color` | `Color.Accent.purpleSurface`    | Bakgrundsfärg på cirkeln bakom ikonen                    |
| `iconName`    | `String` | –                              | Namn på SF Symbol som visas i cirkeln                    |
| `duration`    | `Int`   | –                               | Längd i hela minuter. Visas som "1 minut" eller "12 minuter" |

Kortet fyller all yta föräldern erbjuder, så kort i en rad eller ett rutnät får samma höjd. Ange bredd (eller låt layouten göra det) med `.frame(width:)`.

**Tillgänglighet:** Kortet är ett enda VoiceOver-element med etiketten "Ljudklipp, titel, längd".
