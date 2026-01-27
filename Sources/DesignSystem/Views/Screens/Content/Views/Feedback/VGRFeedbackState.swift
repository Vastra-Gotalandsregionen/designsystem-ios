import Foundation

/// Represents the current state of the feedback component.
public enum VGRFeedbackState: Equatable {
    /// Initial state - user hasn't responded yet
    case unanswered
    /// User indicated the content was helpful
    case positive
    /// User indicated the content was not helpful, with selected reasons
    case negative(reasons: Set<VGRFeedbackOption>)

    public var isAnswered: Bool {
        switch self {
        case .unanswered:
            return false
        case .positive, .negative:
            return true
        }
    }
}

/// Result of feedback submission, used for callbacks.
public struct VGRFeedbackResult {
    /// Whether the user found the content helpful
    public let wasHelpful: Bool
    /// If not helpful, the reasons selected (empty if helpful or no reasons given)
    public let reasons: Set<VGRFeedbackOption>

    public init(wasHelpful: Bool, reasons: Set<VGRFeedbackOption> = []) {
        self.wasHelpful = wasHelpful
        self.reasons = reasons
    }
}
