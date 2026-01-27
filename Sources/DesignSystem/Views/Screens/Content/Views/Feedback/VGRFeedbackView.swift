import SwiftUI

/// A feedback component that asks users if the content was helpful.
///
/// Displays a question with Yes/No buttons, and shows a thank you message after response.
/// If the user responds "No", a sheet appears to collect one or more reasons.
public struct VGRFeedbackView: View {
    @State private var feedbackState: VGRFeedbackState = .unanswered
    @State private var showOptionsSheet = false

    private let onFeedbackSubmitted: ((VGRFeedbackResult) -> Void)?

    public init(onFeedbackSubmitted: ((VGRFeedbackResult) -> Void)? = nil) {
        self.onFeedbackSubmitted = onFeedbackSubmitted
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if feedbackState.isAnswered {
                answeredContent
            } else {
                unansweredContent
            }
        }
        .padding(16)
        .background(Color.Status.informationSurface)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .padding(.horizontal, VGRSpacing.horizontal)
        .sheet(isPresented: $showOptionsSheet) {
            VGRFeedbackOptionsSheet { selectedOptions in
                feedbackState = .negative(reasons: selectedOptions)
                onFeedbackSubmitted?(VGRFeedbackResult(wasHelpful: false, reasons: selectedOptions))
            }
            .interactiveDismissDisabled()
            .presentationDetents([.fraction(0.70), .large])
        }
    }

    // MARK: - Unanswered Content

    private var unansweredContent: some View {
        Group {
            Text("feedback.question".localizedBundle)
                .font(.footnoteRegular)
                .foregroundStyle(Color.Neutral.text)

            HStack(spacing: 16) {
                VGRButton(
                    label: "feedback.button.no".localizedBundle,
                    icon: Image(systemName: "hand.thumbsdown.fill"),
                    variant: .secondary
                ) {
                    showOptionsSheet = true
                }

                VGRButton(
                    label: "feedback.button.yes".localizedBundle,
                    icon: Image(systemName: "hand.thumbsup.fill"),
                    variant: .secondary
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        feedbackState = .positive
                    }
                    onFeedbackSubmitted?(VGRFeedbackResult(wasHelpful: true))
                }
            }
        }
    }

    // MARK: - Answered Content

    private var answeredContent: some View {
        (
            Text("feedback.thanks.prefix".localizedBundle)
                .foregroundStyle(Color.Neutral.text) +
            Text(emphasisText)
                .bold()
                .foregroundStyle(Color.Neutral.text) +
            Text(" ") +
            Text("feedback.undo".localizedBundle)
                .foregroundStyle(Color.Primary.action)
        )
        .font(.subheadline)
        .accessibilityElement(children: .combine)
        .accessibilityAction {
            withAnimation(.easeInOut(duration: 0.2)) {
                feedbackState = .unanswered
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                feedbackState = .unanswered
            }
        }
    }

    private var emphasisText: String {
        switch feedbackState {
        case .positive:
            return "feedback.thanks.positive.emphasis".localizedBundle
        case .negative:
            return "feedback.thanks.negative.emphasis".localizedBundle
        case .unanswered:
            return ""
        }
    }
}

#Preview("Unanswered") {
    VGRFeedbackView { result in
        print("Feedback: helpful=\(result.wasHelpful), reasons=\(result.reasons.map { $0.rawValue })")
    }
    .padding()
    .background(Color.Elevation.background)
}

#Preview("In Article Context") {
    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Article content here...")
                    .padding(.horizontal, 16)

                VGRFeedbackView { result in
                    print("Feedback submitted: \(result)")
                }

                Text("More content below...")
                    .padding(.horizontal, 16)
            }
        }
        .background(Color.Elevation.background)
        .navigationTitle("Meddelande")
        .navigationBarTitleDisplayMode(.inline)
    }
}
