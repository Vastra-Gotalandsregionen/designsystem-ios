import SwiftUI
import Lottie

struct VGRSurveyReceiptView: View {
    private let onComplete: () -> Void
    
    /// Since this often opens in an Overlay, VoiceOver focus can be tricky; force focus to title on appear.
    @AccessibilityFocusState private var initialFocus: Bool
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack(spacing: .Margins.xtraLarge) {
            LottieView(animation: .named("feedback-animation", bundle: .module))
                .playing()
                .frame(width: 200, height: 200)
                .padding(.top, .Margins.medium)
                .accessibilityHidden(true)

            VStack(spacing: .Margins.medium) {
                Text(LocalizedStringKey("survey.receipt.title"), bundle: .module)
                    .font(.titleSemibold)
                    .accessibilityFocused($initialFocus)
                    .accessibilitySortPriority(1)

                Text(LocalizedStringKey("survey.receipt.text"), bundle: .module)
                    .font(.bodySemibold)
            }
            .foregroundStyle(Color.Neutral.text)

            VGRButtonV2("general.button.done".loc(in: .module)) {
                onComplete()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, .Margins.medium)
        .padding(.top, .Margins.xtraLarge)
        .onAppear { initialFocus = true }
        .background(Color.Elevation.background.ignoresSafeArea())
    }
}

#Preview("Receipt") {
    NavigationStack {
        ScrollView {
        }
    }
    .overlay {
        VGRSurveyReceiptView {
            print("Completed")
        }
    }
}
