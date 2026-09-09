import SwiftUI
import Lottie

public struct VGRSurveyReceiptView: View {
    private let onComplete: () -> Void
    
    /// Since this often opens in an Overlay, VoiceOver focus can be tricky; force focus to title on appear.
    @AccessibilityFocusState private var initialFocus: Bool
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        VStack(spacing: .Margins.xtraLarge) {
            LottieView(animation: .named("feedback-animation", bundle: .module))
                .playing()
                .frame(width: 200, height: 200)
                .padding(.top, .Margins.medium)
                .accessibilityHidden(true)

            VStack(spacing: .Margins.medium) {
                Text(LocalizedStringKey("survey.receipt.title"), bundle: .module)
                    .font(.title)
                    .fontWeight(.semibold)
                    .accessibilityFocused($initialFocus)
                    .accessibilitySortPriority(1)

                Text(LocalizedStringKey("survey.receipt.text"), bundle: .module)
                    .font(.body)
            }
            .foregroundStyle(Color.primary)

            VGRButtonV2("general.button.done".loc(in: .module)) {
                onComplete()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, .Margins.medium)
        .padding(.top, .Margins.xtraLarge)
        .onAppear { initialFocus = true }
        .background(Color.Elevation.background)
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
//    .frame(height: 500)
//    .padding()
}
