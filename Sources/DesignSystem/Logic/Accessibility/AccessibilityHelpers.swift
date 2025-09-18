import SwiftUI
import UIKit

public struct AccessibilityHelpers {
    
    @MainActor public static func postPrioritizedAnnouncement(_ message: String, withPriority priority: UIAccessibilityPriority) {
        
        guard UIAccessibility.isVoiceOverRunning else { return }
        
        let attributedAnnouncement = NSAttributedString(string: message, attributes: [NSAttributedString.Key.accessibilitySpeechAnnouncementPriority: priority])
        
        UIAccessibility.post(notification: .announcement, argument: attributedAnnouncement)
    }
    
    @MainActor public static func postAnnouncementWithDelay(_ message: String, delay: TimeInterval) {
        
        guard UIAccessibility.isVoiceOverRunning else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
}
