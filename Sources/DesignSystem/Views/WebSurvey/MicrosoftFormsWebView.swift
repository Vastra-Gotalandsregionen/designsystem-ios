import SwiftUI
import WebKit
import OSLog

/// WKWebView pads its scroll view by the safe area on every edge, which leaves a strip of web view
/// background below the page at the bottom of the screen. This subclass keeps only the top inset, so the
/// page still clears the navigation bar but draws all the way to the bottom edge.
private final class EdgeToEdgeWebView: WKWebView {
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        let previous = scrollView.contentInset.top
        let top = safeAreaInsets.top
        guard previous != top else { return }
        scrollView.contentInset.top = top
        scrollView.verticalScrollIndicatorInsets.top = top
        /// Keep the page pinned to the top when the inset appears or changes, otherwise its first rows hide under the bar
        if scrollView.contentOffset.y <= -previous {
            scrollView.contentOffset.y = -top
        }
    }
}

/// Hosts a Microsoft Forms response page and reports what happens to it through closures. The submission
/// detection is tied to how Forms posts responses and renders its thank-you page, so it is not a general web view.
/// Internal building block of ``VGRSurveyScreen``; apps never see this type.
struct MicrosoftFormsWebView: UIViewRepresentable {
    private let url: URL
    
    /// The page has finished loading
    let onLoaded: () -> Void
    /// The response was submitted and accepted by Forms
    let onSubmitted: () -> Void
    /// The page could not be loaded
    let onError: (VGRSurveyError) -> Void
    
    init(url: URL,
         onLoaded: @escaping () -> Void,
         onSubmitted: @escaping () -> Void,
         onError: @escaping (VGRSurveyError) -> Void) {
        self.url = url
        self.onLoaded = onLoaded
        self.onSubmitted = onSubmitted
        self.onError = onError
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // JS: rapportera när själva svaret har skickats. Microsoft Forms POST:ar svaret till
        // en URL som slutar på "/responses" och godtar 200/201/202. Övriga POST-anrop (telemetri,
        // autosparande) ignoreras, annars rapporteras "klart" även när obligatoriska fält saknas.
        let submissionScript = """
(function() {
    function isResponseSubmission(method, url, status) {
        if (String(method).toUpperCase() !== 'POST') { return false; }
        if (status < 200 || status >= 300) { return false; }
        var path;
        try { path = new URL(url, location.href).pathname; } catch (e) { path = String(url).split('?')[0]; }
        return /\\/responses$/.test(path);
    }
    function report() {
        try { window.webkit.messageHandlers.surveySubmitted.postMessage('Response POST succeeded'); } catch (e) {}
    }
    var open = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url) {
        this.addEventListener('load', function() {
            if (isResponseSubmission(method, url, this.status)) { report(); }
        });
        return open.apply(this, arguments);
    };
    if (window.fetch) {
        var originalFetch = window.fetch;
        window.fetch = function(input, init) {
            var url = typeof input === 'string' ? input : (input && input.url);
            var method = (init && init.method) || (input && input.method) || 'GET';
            return originalFetch.apply(this, arguments).then(function(response) {
                if (isResponseSubmission(method, url, response.status)) { report(); }
                return response;
            });
        };
    }
})();
"""
        // JS: fallback som känner igen tack-sidan i DOM:en, oberoende av nätverkstrafiken
        let thankYouScript = """
(function() {
    var selector = '[data-automation-id="thankYouMessage"]';
    function check() {
        if (!document.querySelector(selector)) { return false; }
        try { window.webkit.messageHandlers.surveySubmitted.postMessage('Thank-you page shown'); } catch (e) {}
        return true;
    }
    if (check()) { return; }
    var observer = new MutationObserver(function() {
        if (check()) { observer.disconnect(); }
    });
    observer.observe(document.body, { childList: true, subtree: true });
})();
"""
        let submissionUserScript = WKUserScript(source: submissionScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        let thankYouUserScript = WKUserScript(source: thankYouScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(submissionUserScript)
        contentController.addUserScript(thankYouUserScript)
        
        contentController.add(context.coordinator, name: "surveySubmitted")
        config.userContentController = contentController
        
        let webView = EdgeToEdgeWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        /// Show the design system background instead of WebKit's white while the page loads and beyond its edges
        let background = UIColor(Color.Elevation.background)
        webView.isOpaque = false
        webView.backgroundColor = background
        webView.scrollView.backgroundColor = background
        webView.underPageBackgroundColor = background
        
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        /// Keep the coordinator's callbacks current; the screen re-renders as its state changes
        context.coordinator.parent = self
    }
    
    /// WebKit calls its delegates on the main actor, so the callbacks can be forwarded directly
    @MainActor
    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        private let logger = Logger(subsystem: "VGRSurvey", category: "Coordinator")
        var parent: MicrosoftFormsWebView
        private var hasReportedSubmission = false
        
        init(_ parent: MicrosoftFormsWebView) { self.parent = parent }
        
        // MARK: - WKScriptMessageHandler
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "surveySubmitted" else { return }
            logger.info("Survey submission signal: \(String(describing: message.body))")
            
            /// Both the network hook and the thank-you page observer report success, so only forward the first
            guard !hasReportedSubmission else { return }
            hasReportedSubmission = true
            logger.info("✅ Survey submitted successfully")
            parent.onSubmitted()
        }
        
        // MARK: - WKNavigationDelegate
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            logger.info("WebView Loaded")
            parent.onLoaded()
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            report(error, in: "didFail")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
            report(error, in: "didFailProvisionalNavigation")
        }
        
        private func report(_ error: any Error, in callback: String) {
            /// A navigation replaced by another (redirects, reloads) is not a connection problem
            guard (error as NSError).code != NSURLErrorCancelled else { return }
            logger.error("WebView \(callback) \(String(describing: error))")
            parent.onError(.connectionFailed(underlying: error))
        }
    }
}
