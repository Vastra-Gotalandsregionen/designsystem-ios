import UIKit

public extension UIAccessibility {

    /// Posts an accessibility announcement with a specified priority, ensuring VoiceOver is running before proceeding.
    /// - Note: Available from iOS 17.0 and later.
    /// - Parameters:
    ///   - message: The announcement message to be spoken.
    ///   - priority: The priority level for the announcement.
    @MainActor @available(iOS 17.0, *)
    static func postPrioritizedAnnouncement(_ message: String, withPriority priority: UIAccessibilityPriority) {

        guard UIAccessibility.isVoiceOverRunning else { return }

        let attributedAnnouncement = NSAttributedString(string: message, attributes: [NSAttributedString.Key.accessibilitySpeechAnnouncementPriority: priority])

        UIAccessibility.post(notification: .announcement, argument: attributedAnnouncement)
    }

    /// Posts an accessibility announcement after a specified delay, ensuring VoiceOver is running before proceeding.
    /// - Parameters:
    ///   - message: The announcement message to be spoken.
    ///   - delay: The time interval (in seconds) after which the announcement will be posted.
    @MainActor static func postAnnouncementWithDelay(_ message: String, delay: TimeInterval) {

        guard UIAccessibility.isVoiceOverRunning else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
}
