# VGRSurvey

Ett litet tillägg för att visa **Microsoft Forms** i en SwiftUI-app.  
Består av en `WKWebView` med JS-injektion som detekterar **Submit**, samt delvyer för **spinner** och **kvittens**.  
Appen (hosten) styr sheet, toolbar, overlay och persistens.

---

## Komponenter

- `VGRSurveyWebView` – WebView för MS Forms, postar notiser.  
- `VGRSurveyReceiptView` – Kvittensvy (Lottie-animation).  
- `VGRSurveyProgressSpinner` – Laddningsindikator.  
- `VGRSurveyNotifications` – Notisnamn (`Notification.Name`).  
- `VGRLottieView` – Wrapper för Lottie-animationer.

---

## Notiser (Notification.Name)

| Notis                        | När                                     | Använd i appen |
|------------------------------|-----------------------------------------|----------------|
| `.webViewLoaded`             | Sida laddad                             | Slå av spinner |
| `.surveySubmissionSuccess`   | Submit-knapp klickad **och** POST 200   | Visa kvittens, enable “Klar” |
| `.webUrlError`               | Ogiltig URL                             | Stäng sheet, visa fel |
| `.webConnectionFailure`      | Nätverksfel / laddning bruten           | Stäng sheet, visa fel |

---

## Quick Start

```swift
import SwiftUI
import VGRSurvey

struct ContentView: View {
    @State private var showSurvey = false
    @State private var isLoading = true
    @State private var hasSubmitted = false
    
    @State private var showGeneralErrorAlert = false
    @State private var showConnectionFailureAlert = false
    @State private var showDismissSurveyAlert = false

    let formsURL = "https://forms.office.com/Pages/ResponsePage.aspx?id=..."

    var body: some View {
        Button("Öppna enkät") { showSurvey = true }
            .sheet(isPresented: $showSurvey) {
                NavigationStack {
                    VGRWebSurveyView(urlString: formsURL)
                        .navigationTitle("Enkät")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Avbryt") { showDismissSurveyAlert = true }
                                    .disabled(hasSubmitted)
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Klar") { showSurvey = false }
                                    .disabled(!hasSubmitted)
                            }
                        }
                        .overlay {
                            if isLoading {
                                VGRSurveyProgressSpinner()
                            } else if hasSubmitted {
                                VGRSurveyReceiptView { showSurvey = false }
                            }
                        }
                        // Events
                        .onReceive(NotificationCenter.default.publisher(for: .webViewLoaded)) { _ in
                            isLoading = false
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .surveySubmissionSuccess)) { _ in
                            hasSubmitted = true
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .webUrlError)) { _ in
                            showSurvey = false
                            showGeneralErrorAlert = true
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .webConnectionFailure)) { _ in
                            showSurvey = false
                            showConnectionFailureAlert = true
                        }
                        // Alerts
                        .alert("Enkät", isPresented: $showDismissSurveyAlert) {
                            Button("Avbryt", role: .cancel) {}
                            Button("Hoppa över", role: .destructive) {
                                hasSubmitted = true
                                showSurvey = false
                            }
                        } message: {
                            Text("Vill du hoppa över enkäten?")
                        }
                        .alert("Fel", isPresented: $showGeneralErrorAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("Något gick fel, försök igen.")
                        }
                        .alert("Anslutningsfel", isPresented: $showConnectionFailureAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("Kunde inte ladda enkäten på grund av nätverksproblem.")
                        }
                }
            }
    }
}
```

## Att tänka på 

- **Hosten** styr `isLoading`, `hasSubmitted`, `showSurvey` och persistens (`UserDefaults` etc.).  
- **Avbryt** i navbar: enabled före submit, disabled efter.  
- **Klar** i navbar: disabled före submit, enabled efter.  
- Kvittens och spinner är valfria delvyer – kan bytas ut.  

### Alerts

För att ge bra UX behöver appen visa alerts för olika fel- och avbrottsscenarion.  
Vanliga mönster:

- **Avbryt enkät**: visa en bekräftelsedialog om användaren vill hoppa över enkäten.  
- **Allmänt fel** (`.webUrlError`): stäng sheet och visa en generisk felalert.  
- **Anslutningsfel** (`.webConnectionFailure`): stäng sheet och visa en alert om nätverksproblem.  
- **Dismissal**: vissa appar kan låta användaren markera enkäten som “inte relevant” via en destruktiv knapp.

> **Tips:** lägg alerts i hosten, kopplat till state som triggas av notiserna. Då blir det lätt att anpassa språk och design utan att ändra biblioteket.
