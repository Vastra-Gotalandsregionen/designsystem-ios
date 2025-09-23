import SwiftUI
import WebKit
import OSLog

public struct VGRSurveyWebView: UIViewRepresentable {
    let logger = Logger(subsystem: "Survey", category: "WebView")
    let url: URL?
    
    public init(urlString: String) {
         url = URL(string: urlString)
    }
    
    /// Skapar en koordinator som fungerar som en brygga mellan WebView och SwiftUI
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Skapar och konfigurerar WKWebView med en JavaScript-listener
    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        /// JavaScript-kod som letar efter en specifik knapp och lyssnar på klickhändelser
        let script = """
function setupButtonListener() {
    let button = document.querySelector('[data-automation-id="submitButton"]');
    if (button) {
        console.log("✅ Button found, adding event listener...");
        button.addEventListener('click', function() {
            alert("Button clicked! Sending message to Swift...");
            window.webkit.messageHandlers.buttonClicked.postMessage('Submit Button Pressed');
        });
    }
}

// Anropa funktionen direkt för att söka efter knappen
setupButtonListener();

// Övervaka DOM-förändringar om knappen inte finns vid första försöket
const observer = new MutationObserver(function(mutations, obs) {
    let button = document.querySelector('[data-automation-id="submitButton"]');
    if (button) {
        console.log("✅ Button detected via MutationObserver!");
        setupButtonListener();
        obs.disconnect(); // Stoppar observering när knappen har hittats
    }
});

observer.observe(document.body, { childList: true, subtree: true });
"""

        
        /// JavaScript för att fånga XHR (AJAX) requests
        let xhrScript = """
    (function() {
        var open = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function(method, url) {
            this.addEventListener('load', function() {
                if (this.status === 200 && method === 'POST') {
                    window.webkit.messageHandlers.surveySubmitted.postMessage('Status 200, POST-method executed');
                }
            });
            open.apply(this, arguments);
        };
    })();
    """
        
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let xhrUserScript = WKUserScript(source: xhrScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        contentController.addUserScript(xhrUserScript)
        
        /// Lägger till JavaScript-message-handler för att ta emot händelser från webbsidan
        contentController.add(context.coordinator, name: "buttonClicked")
        contentController.add(context.coordinator, name: "surveySubmitted")
        
        /// Tilldelar contentController till konfigurationen
        config.userContentController = contentController
        
        /// Skapar och returnerar en WKWebView med den specificerade konfigurationen
        let webView = WKWebView(frame: .zero, configuration: config)

        /// Knyt en delegat till webView'n, för att kunna känna av när vyn är färdigladdad.
        webView.navigationDelegate = context.coordinator

        if let url = url {
            webView.load(URLRequest(url: url))
        } else {
            logger.error("Invalid URL")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .webUrlError, object: nil)
            }
        }
        return webView
    }
    
    /// Uppdaterar WKWebView vid behov (ej använd i detta fall)
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    /// Koordinator som hanterar kommunikationen mellan WKWebView och SwiftUI
    public class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        let logger = Logger(subsystem: "Survey", category: "Coordinators")
        var parent: VGRSurveyWebView
        var hasClickedSubmit = false
        
        public init(_ parent: VGRSurveyWebView) {
            self.parent = parent
        }
        
        // MARK: - WKScriptMessageHandler
        
        /// Hanterar inkommande meddelanden från JavaScript
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "buttonClicked", let body = message.body as? String {
                logger.info("JavaScript sent: \(body)")
                logger.info("☑️ User tapped Submit-button...")
                hasClickedSubmit = true
            }
            
            if message.name == "surveySubmitted", let body = message.body as? String {
                logger.info("JavaScript sent: \(body)")
                if hasClickedSubmit {
                    logger.info("✅ Survey submitted successfully")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .surveySubmissionSuccess, object: nil)
                    }
                }
            }
        }
        
        // MARK: - WKNavigationDelegate
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            /// Skickar en notifikation för att låta SwiftUI-appen reagera på när webViewn laddat in sitt innehåll
            DispatchQueue.main.async {
                self.logger.info("WebView Loaded")
                NotificationCenter.default.post(name: .webViewLoaded, object: nil)
            }
        }
        
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            /// Skickar en notifikation för att låta SwiftUI-appen reagera på misslyckade anrop i webviewn (t.ex. om uppkopplingen är dålig eller servern inte svarar, triggas om en påbörjad sidladdning avbryts)
            DispatchQueue.main.async {
                self.logger.error("WebView didFail \(error)")
                NotificationCenter.default.post(name: .webConnectionFailure, object: nil)
            }
        }
        
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            /// Skickar en notifikation för att låta SwiftUI-appen reagera på om webbadressen inte kan laddas (t.ex. om internet är avstängt).
            DispatchQueue.main.async {
                self.logger.error("WebView didFailProvisionalNavigation \(error)")
                NotificationCenter.default.post(name: .webConnectionFailure, object: nil)
            }
        }
    }
}

/// Extension för att definiera en anpassad notifikation som används när knappen klickas
public extension Notification.Name {
    static let webUrlError = Notification.Name("webUrlError")
    static let webConnectionFailure = Notification.Name("webConnectionFailure")
    static let webViewLoaded = Notification.Name("webViewLoaded")
    static let surveySubmissionSuccess = Notification.Name("surveySubmissionSuccess")
}
