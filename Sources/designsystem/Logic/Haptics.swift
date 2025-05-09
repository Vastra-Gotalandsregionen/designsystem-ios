import SwiftUI
import UIKit

public struct Haptics {
    
    /// Light impact feedback (subtle tap)
    @MainActor public static func lightImpact() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.prepare()
        impact.impactOccurred()
    }
    
    /// Medium impact feedback (standard tap)
    @MainActor public static func mediumImpact() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
    }
    
    /// Heavy impact feedback (stronger tap)
    @MainActor public static func heavyImpact() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.prepare()
        impact.impactOccurred()
    }
    
    /// Success notification feedback
    @MainActor public static func success() {
        let notification = UINotificationFeedbackGenerator()
        notification.prepare()
        notification.notificationOccurred(.success)
    }
    
    /// Warning notification feedback
    @MainActor public static func warning() {
        let notification = UINotificationFeedbackGenerator()
        notification.prepare()
        notification.notificationOccurred(.warning)
    }
    
    /// Error notification feedback
    @MainActor public static func error() {
        let notification = UINotificationFeedbackGenerator()
        notification.prepare()
        notification.notificationOccurred(.error)
    }
}
