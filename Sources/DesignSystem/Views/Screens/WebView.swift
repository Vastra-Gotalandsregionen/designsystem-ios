import SwiftUI
import WebKit

/// En SwiftUI-komponent som visar en webbsida med hjälp av WKWebView.
public struct WebView: UIViewRepresentable {
    
    /// Webbadressen som ska laddas, som en sträng.
    let urlString: String

    /// Initierar `WebView` med en URL-sträng.
    /// - Parameter urlString: Webbadressen som ska visas.
    public init(urlString: String) {
        self.urlString = urlString
    }
    
    /// Skapar och returnerar en `WKWebView` med angiven URL.
    public func makeUIView(context _: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    /// Uppdaterar inte `WKWebView` efter att den har skapats.
    public func updateUIView(_: WKWebView, context _: Context) {}
}

#Preview("WebView") {
    return NavigationStack {
        WebView(urlString: "https://www.vgregion.se")
            .navigationTitle("WebView")
            .navigationBarTitleDisplayMode(.inline)
    }
}
