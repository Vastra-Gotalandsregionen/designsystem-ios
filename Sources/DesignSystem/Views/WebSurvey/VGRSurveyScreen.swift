import SwiftUI

/// What a ``VGRSurveyScreen`` reports back to the app. Exactly one event is delivered per presentation.
public enum VGRSurveyEvent {
    /// The user submitted the survey and closed the receipt
    case completed
    /// The user left before submitting
    case cancelled
    /// The survey could not be shown. Dismiss the screen and tell the user.
    case failed(VGRSurveyError)
}

/// Why a survey could not be shown
public enum VGRSurveyError: Error {
    /// The URL string could not be parsed
    case invalidURL
    /// The survey page could not be loaded
    case connectionFailed(underlying: Error)
}

/// Presents a Microsoft Forms survey as a self-contained modal flow: a loading spinner, the form,
/// and a receipt once the response has been accepted.
///
/// Designed for sheet presentation. The screen owns its navigation bar, toolbar and overlays, so the
/// app only supplies the URL and reacts to events:
/// ```swift
/// .sheet(isPresented: $showSurvey) {
///     VGRSurveyScreen(urlString: surveyURL) { event in
///         showSurvey = false
///         if case .failed = event { showSurveyError = true }
///     }
/// }
/// ```
/// Cancel asks for confirmation before reporting ``VGRSurveyEvent/cancelled``. Before submission the
/// sheet cannot be swiped away; afterwards a swipe dismisses freely and is reported as
/// ``VGRSurveyEvent/completed``.
public struct VGRSurveyScreen: View {
    private let urlString: String
    private let title: String
    private let onEvent: (VGRSurveyEvent) -> Void
    
    @State private var isLoading = true
    @State private var hasSubmitted = false
    @State private var hasEmittedEvent = false
    @State private var alert: VGRAlert?
    
    /// - Parameters:
    ///   - urlString: The Microsoft Forms response page to show
    ///   - title: Navigation bar title. Defaults to the localized "survey.title".
    ///   - onEvent: Called once, with what happened. The app is responsible for dismissing the screen.
    public init(urlString: String,
                title: String = "survey.title".localizedBundle,
                onEvent: @escaping (VGRSurveyEvent) -> Void) {
        self.urlString = urlString
        self.title = title
        self.onEvent = onEvent
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if let url = URL(string: urlString) {
                    MicrosoftFormsWebView(
                        url: url,
                        onLoaded: { isLoading = false },
                        onSubmitted: { withAnimation { hasSubmitted = true } },
                        onError: { emit(.failed($0)) }
                    )
                    /// SwiftUI lays the web view out inside the safe area, leaving a gap at the bottom and a
                    /// blank band under a translucent navigation bar. WKWebView insets its own content, so
                    /// hand it the full frame instead.
                    .ignoresSafeArea()
                } else {
                    Color.Elevation.background
                        .ignoresSafeArea()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VGRCancelButton {
                        confirmCancel()
                    }
                    .disabled(hasSubmitted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    VGRDoneButton {
                        emit(.completed)
                    }
                    .disabled(!hasSubmitted)
                }
            }
            .overlay {
                if isLoading {
                    VGRSurveyProgressSpinner()
                } else if hasSubmitted {
                    VGRSurveyReceiptView {
                        emit(.completed)
                    }
                    .transition(.opacity)
                }
            }
            .vgrAlert(item: $alert)
        }
        /// Before submission the sheet cannot be swiped away, so leaving always goes through Cancel and its confirmation
        .interactiveDismissDisabled(!hasSubmitted)
        .task {
            if URL(string: urlString) == nil {
                emit(.failed(.invalidURL))
            }
        }
        .onDisappear {
            /// The sheet was swiped away or dismissed by the app without a button press
            emit(hasSubmitted ? .completed : .cancelled)
        }
    }
    
    /// Leaving throws away any answers, so ask first
    private func confirmCancel() {
        alert = VGRAlert(
            title: "survey.cancel.title".loc(in: .module),
            message: "survey.cancel.message".loc(in: .module),
            buttons: [
                .destructive("survey.cancel.confirm".loc(in: .module)) { emit(.cancelled) },
                .cancel()
            ]
        )
    }
    
    private func emit(_ event: VGRSurveyEvent) {
        guard !hasEmittedEvent else { return }
        hasEmittedEvent = true
        onEvent(event)
    }
}

#Preview("Survey screen (sheet demo)") {
    @Previewable @State var isPresented = false
    @Previewable @State var lastEvent = "–"
    
    // Exempel-URL (ersätt med er riktiga Forms-länk)
    let url = "https://forms.cloud.microsoft/Pages/ResponsePage.aspx?id=VaJi_CBC5EebWkGO7jHaX9ivf1QuXQlGoxgA0GSzz9xUMFY1QTZZNTBWQVJaOUVUTllTUkpDU1FMQi4u"
    
    ScrollView {
        VStack(spacing: 32) {
            VGRCalloutV2(header: "Din åsikt gör stor skillnad",
                         description: "Hjälp oss att bli bättre genom att svara på vår enkät",
                         backgroundColor: Color.Primary.blueSurfaceMinimal) {
                VGRButton(label: "Gå till enkäten") {
                    isPresented = true
                }
            }
            Text("Senaste händelse: \(lastEvent)")
                .font(.footnote)
        }
        .padding(32)
    }
    .sheet(isPresented: $isPresented) {
        VGRSurveyScreen(urlString: url, title: "Hej") { event in
            lastEvent = String(describing: event)
            isPresented = false
        }
    }
}
