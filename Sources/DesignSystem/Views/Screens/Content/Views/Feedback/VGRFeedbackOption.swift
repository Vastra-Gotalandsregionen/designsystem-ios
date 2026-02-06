import Foundation

/// Represents the available feedback options when a user indicates the content was not helpful.
public enum VGRFeedbackOption: String, CaseIterable, Identifiable {
    case notRelevant = "not_relevant"
    case unsureNextStep = "unsure_next_step"
    case alreadyKnew = "already_knew"
    case feelsRepetitive = "feels_repetitive"
    case other = "other"
    
    public var id: String { rawValue }
    
    /// Localized display text for the option
    public var displayText: String {
        switch self {
        case .notRelevant:
            return "feedback.option.not_relevant".localizedBundle
        case .unsureNextStep:
            return "feedback.option.unsure_next_step".localizedBundle
        case .alreadyKnew:
            return "feedback.option.already_knew".localizedBundle
        case .feelsRepetitive:
            return "feedback.option.feels_repetitive".localizedBundle
        case .other:
            return "feedback.option.other".localizedBundle
        }
    }
}
