import SwiftUI
import WebKit
import OSLog

public struct VGRSurveyWebView: UIViewRepresentable {
    private let logger = Logger(subsystem: "VGRSurvey", category: "WebView")
    private let url: URL?
    
    public init(urlString: String) {
        self.url = URL(string: urlString)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // JS: lyssna på submit-knapp + MutationObserver fallback
        let script = """
function setupButtonListener() {
    let button = document.querySelector('[data-automation-id="submitButton"]');
    if (button) {
        console.log("✅ Button found, adding event listener...");
        button.addEventListener('click', function() {
            try { window.webkit.messageHandlers.buttonClicked.postMessage('Submit Button Pressed'); } catch(e){}
        }, { once: false });
    }
}
setupButtonListener();
const observer = new MutationObserver(function(mutations, obs) {
    let button = document.querySelector('[data-automation-id="submitButton"]');
    if (button) {
        console.log("✅ Button detected via MutationObserver!");
        setupButtonListener();
        obs.disconnect();
    }
});
observer.observe(document.body, { childList: true, subtree: true });
"""
        // JS: hooka XHR för att se POST 200
        let xhrScript = """
(function() {
    var open = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url) {
        this.addEventListener('load', function() {
            if (this.status === 200 && method === 'POST') {
                try { window.webkit.messageHandlers.surveySubmitted.postMessage('Status 200, POST-method executed'); } catch(e){}
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
        
        contentController.add(context.coordinator, name: "buttonClicked")
        contentController.add(context.coordinator, name: "surveySubmitted")
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        if let url {
            webView.load(URLRequest(url: url))
        } else {
            logger.error("Invalid URL")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .webUrlError, object: nil)
            }
        }
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    public final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        private let logger = Logger(subsystem: "VGRSurvey", category: "Coordinator")
        private let parent: VGRSurveyWebView
        private var hasClickedSubmit = false
        
        init(_ parent: VGRSurveyWebView) { self.parent = parent }
        
        // MARK: - WKScriptMessageHandler
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "buttonClicked" {
                logger.info("☑️ User tapped Submit-button…")
                hasClickedSubmit = true
            } else if message.name == "surveySubmitted" {
                logger.info("XHR POST 200 observed")
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
            DispatchQueue.main.async {
                self.logger.info("WebView Loaded")
                NotificationCenter.default.post(name: .webViewLoaded, object: nil)
            }
        }
        
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            DispatchQueue.main.async {
                self.logger.error("WebView didFail \(String(describing: error))")
                NotificationCenter.default.post(name: .webConnectionFailure, object: nil)
            }
        }
        
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
            DispatchQueue.main.async {
                self.logger.error("WebView didFailProvisionalNavigation \(String(describing: error))")
                NotificationCenter.default.post(name: .webConnectionFailure, object: nil)
            }
        }
    }
}

#Preview("Survey WebView (sheet demo)") {
    @Previewable @State var isPresented = false
    @Previewable @State var isLoading = true
    @Previewable @State var hasSubmitted = false
    
    // Exempel-URL (ersätt med er riktiga Forms-länk)
    let url = "https://forms.office.com/Pages/ResponsePage.aspx?id=VaJi_CBC5EebWkGO7jHaX3x25RhL2dFPhFDutmaTHW5UMloyN01DVzM0TjFYVUZLSTZINUNCS0dJTS4u"
    
    return ZStack {
        
        ScrollView {
            VGRCalloutV2(header: "Din åsikt gör stor skillnad", description: "Hjälp oss att bli bättre genom att svara på vår enkät", backgroundColor: Color.Primary.blueSurfaceMinimal) {
                VGRButton(label: "Gå till enkäten") {
                    isPresented = true
                }
            }
            .padding(32)
        }
        
    }
    .sheet(isPresented: $isPresented) {
        NavigationStack {
            VGRSurveyWebView(urlString: url)
                .navigationTitle("Survey")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            isPresented = false
                            isLoading = true
                        }
                        .disabled(hasSubmitted) // host policy
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            isPresented = false
                            // reset if you want
                        }
                        .disabled(!hasSubmitted) // host policy
                    }
                }
                .overlay {
                    if isLoading {
                        VGRSurveyProgressSpinner()
                    } else if hasSubmitted {
                        VGRSurveyReceiptView {
                            isPresented = false
                        }
                        .transition(.opacity)
                    }
                }
            // Event wiring (host ansvar)
                .onReceive(NotificationCenter.default.publisher(for: .webViewLoaded)) { _ in
                    isLoading = false
                }
                .onReceive(NotificationCenter.default.publisher(for: .surveySubmissionSuccess)) { _ in
                    hasSubmitted = true
                }
                .onReceive(NotificationCenter.default.publisher(for: .webUrlError)) { _ in
                    isPresented = false
                }
                .onReceive(NotificationCenter.default.publisher(for: .webConnectionFailure)) { _ in
                    isPresented = false
                }
        }
    }
}
