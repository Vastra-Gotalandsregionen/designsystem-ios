# VGRSurvey

Visar en **Microsoft Forms**-enkät i en SwiftUI-app som ett självständigt modalt flöde:
laddningsindikator, formuläret, och en kvittens när svaret har tagits emot.

Appen skickar in en URL och tar emot **en** händelse per visning. Allt annat – navigationsfält,
Avbryt/Klar-knappar, bekräftelse vid avbrott, spinner och kvittens – sköter skärmen själv.

---

## Komponenter

- `VGRSurveyScreen` – den publika skärmen. Avsedd att visas i en `.sheet`.
- `VGRSurveyEvent` – vad som hände: `.completed`, `.cancelled` eller `.failed(VGRSurveyError)`.
- `VGRSurveyError` – `.invalidURL` eller `.connectionFailed(underlying:)`.

Interna byggstenar (inte publika): `MicrosoftFormsWebView`, `VGRSurveyReceiptView`,
`VGRSurveyProgressSpinner`.

---

## Quick Start

```swift
import SwiftUI
import DesignSystem

struct ContentView: View {
    @State private var showSurvey = false
    @State private var surveyError: VGRSurveyError?

    let formsURL = "https://forms.office.com/Pages/ResponsePage.aspx?id=..."

    var body: some View {
        Button("Öppna enkät") { showSurvey = true }
            .sheet(isPresented: $showSurvey) {
                VGRSurveyScreen(urlString: formsURL) { event in
                    showSurvey = false
                    switch event {
                    case .completed:
                        // Markera enkäten som besvarad (UserDefaults etc.)
                        break
                    case .cancelled:
                        // Användaren hoppade över enkäten
                        break
                    case .failed(let error):
                        surveyError = error
                    }
                }
            }
            .alert(
                "Enkäten kunde inte visas",
                isPresented: Binding(
                    get: { surveyError != nil },
                    set: { if !$0 { surveyError = nil } }
                ),
                presenting: surveyError
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { error in
                Text(message(for: error))
            }
    }

    /// Översätt felet till något användaren kan agera på
    private func message(for error: VGRSurveyError) -> String {
        switch error {
        case .invalidURL:
            return "Länken till enkäten är felaktig. Uppdatera appen eller försök igen senare."
        case .connectionFailed(let underlying):
            return "Kontrollera din anslutning och försök igen.\n\n\(underlying.localizedDescription)"
        }
    }
}
```

`.failed` bär med sig ett `VGRSurveyError`. `.invalidURL` betyder att strängen inte gick att tolka
som en URL, `.connectionFailed(underlying:)` att sidan inte kunde laddas – `underlying` är felet
från WebKit, t.ex. ett `URLError`, och kan loggas eller visas.

`title:` kan anges för att byta rubrik i navigationsfältet. Standard är "Enkät".

---

## Händelser

| Händelse       | När                                                              |
|----------------|------------------------------------------------------------------|
| `.completed`   | Svaret har tagits emot och användaren tryckte Klar (i navigationsfältet eller på kvittensen), eller svepte bort arket efter inskick |
| `.cancelled`   | Användaren tryckte Avbryt och bekräftade                        |
| `.failed`      | URL:en kunde inte tolkas, eller sidan kunde inte laddas          |

Innan inskick går arket inte att svepa bort; efter inskick stänger en svepning arket.
Exakt en händelse skickas per visning. **Appen ansvarar för att stänga arket** när
händelsen kommer, så att den t.ex. hinner visa en felalert.

---

## Hur inskick upptäcks

Forms POST:ar svaret till en URL som slutar på `/responses` och godtar 200/201/202.
Ett injicerat skript rapporterar bara det anropet – telemetri och andra POST-anrop ignoreras,
annars skulle "klart" rapporteras även när obligatoriska frågor saknas. Som reserv bevakas
även DOM:en efter Forms tack-sida (`data-automation-id="thankYouMessage"`).

Detekteringen är knuten till Microsoft Forms. Andra enkätverktyg fungerar inte utan anpassning.
