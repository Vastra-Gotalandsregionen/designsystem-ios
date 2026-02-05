import SwiftUI

/// Content element view that displays a feedback component.
/// Converts the feedbackOptions strings from JSON to VGRFeedbackOption enum cases.
struct VGRContentFeedbackView: View {
    let element: VGRContentElement

    /// The article ID this feedback is for (used for tracking)
    let articleId: String

    /// Callback when feedback is submitted
    var onFeedbackSubmitted: ((VGRFeedbackResult) -> Void)?

    /// Convert string option keys to VGRFeedbackOption enum cases
    private var options: [VGRFeedbackOption] {
        element.feedbackOptions.compactMap { VGRFeedbackOption(rawValue: $0) }
    }

    var body: some View {
        VGRFeedbackView(
            articleId: articleId,
            options: options.isEmpty ? VGRFeedbackOption.allCases.map { $0 } : options,
            onFeedbackSubmitted: onFeedbackSubmitted
        )
        .padding(.vertical, VGRSpacing.verticalMedium)
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Article content here...")
                .padding(.horizontal, 16)

            VGRContentFeedbackView(
                element: VGRContentElement(
                    type: .feedback,
                    feedbackOptions: ["not_relevant", "already_knew", "other"]
                ),
                articleId: "preview-article"
            ) { result in
                print("Feedback: articleId=\(result.articleId), helpful=\(result.wasHelpful), reasons=\(result.reasonsString)")
            }
        }
    }
    .background(Color.Elevation.background)
}
