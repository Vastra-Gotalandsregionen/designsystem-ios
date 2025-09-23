import SwiftUI

public struct VGRSurveyReceiptView: View {
    private let onComplete: () -> Void
    
    /// Since this often opens in an Overlay, VoiceOver focus can be tricky; force focus to title on appear.
    @AccessibilityFocusState private var initialFocus: Bool
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        VStack(spacing: 32) {
            VGRLottieView(animationName: "feedback-animation", loopMode: .playOnce)
                .frame(width: 200, height: 200)
                .padding(.top, 16)
            
            VStack(spacing: 16) {
                Text(LocalizedStringKey("survey.reciept.title"), bundle: .module)
                    .font(.title)
                    .fontWeight(.semibold)
                    .accessibilityFocused($initialFocus)
                    .accessibilitySortPriority(1)
                Text(LocalizedStringKey("survey.reciept.text"), bundle: .module)
                    .font(.body)
            }
            .foregroundStyle(Color.primary)
            
            Button {
                onComplete()
            } label: {
                Text(LocalizedStringKey("general.button.done"), bundle: .module)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 32)
        .background(Color(.systemBackground))
        .onAppear { initialFocus = true }
    }
}

#Preview("Receipt") {
    VGRSurveyReceiptView {
        print("Completed")
    }
    .frame(height: 500)
    .padding()
}
