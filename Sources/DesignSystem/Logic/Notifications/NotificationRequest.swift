import Foundation
import UserNotifications

/// Scheduler-level notification request. Produced by the manager from
/// `NotificationSettings`, consumed by `NotificationScheduling`.
public struct NotificationRequest: Sendable, Equatable, Hashable {
    public let identifier: String
    public let content: NotificationContent
    public let trigger: NotificationTrigger
    public let scheduledAt: Date

    public init(
        identifier: String,
        content: NotificationContent,
        trigger: NotificationTrigger,
        scheduledAt: Date
    ) {
        self.identifier = identifier
        self.content = content
        self.trigger = trigger
        self.scheduledAt = scheduledAt
    }
}

public enum NotificationTrigger: Sendable, Equatable, Hashable {
    /// Fires when the wall clock matches every component set in `components`.
    /// Used for both one-shot and OS-repeating schedules.
    case calendar(DateComponents, repeats: Bool)
}

extension NotificationTrigger {
    func makeSystemTrigger() -> UNNotificationTrigger {
        switch self {
        case .calendar(let components, let repeats):
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        }
    }
}

extension NotificationRequest {
    /// Bridge to the system request type.
    func makeSystemRequest(contextId: String) -> UNNotificationRequest {
        UNNotificationRequest(
            identifier: identifier,
            content: content.makeSystemContent(contextId: contextId, scheduledAt: scheduledAt),
            trigger: trigger.makeSystemTrigger()
        )
    }
}
