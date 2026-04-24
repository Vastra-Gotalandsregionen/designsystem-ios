import Foundation
import UserNotifications

/// The payload a notification renders when it fires.
///
/// Kept free of `UNMutableNotificationContent` so it stays `Sendable`, `Codable`,
/// and safe to persist. Bridged to the system type inside the scheduler layer.
public struct NotificationContent: Sendable, Codable, Equatable, Hashable {

    public var title: String
    public var body: String
    public var sound: NotificationSound
    public var interruptionLevel: NotificationInterruptionLevel
    public var categoryIdentifier: String?
    public var threadIdentifier: String?
    public var badge: Int?

    /// Free-form payload. The manager reserves the `context_id` and `scheduled_at`
    /// keys — callers should not set them directly.
    public var userInfo: [String: String]

    public init(
        title: String,
        body: String,
        sound: NotificationSound = .default,
        interruptionLevel: NotificationInterruptionLevel = .active,
        categoryIdentifier: String? = nil,
        threadIdentifier: String? = nil,
        badge: Int? = nil,
        userInfo: [String: String] = [:]
    ) {
        self.title = title
        self.body = body
        self.sound = sound
        self.interruptionLevel = interruptionLevel
        self.categoryIdentifier = categoryIdentifier
        self.threadIdentifier = threadIdentifier
        self.badge = badge
        self.userInfo = userInfo
    }
}

public enum NotificationSound: Sendable, Codable, Equatable, Hashable {
    case none
    case `default`
    case named(String)
}

public enum NotificationInterruptionLevel: String, Sendable, Codable, Equatable, Hashable {
    case passive
    case active
    case timeSensitive
    case critical
}

extension NotificationContent {
    /// Bridge to the system content type.
    func makeSystemContent(contextId: String, scheduledAt: Date) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.sound = sound.systemValue
        content.interruptionLevel = interruptionLevel.systemValue
        if let categoryIdentifier { content.categoryIdentifier = categoryIdentifier }
        if let threadIdentifier { content.threadIdentifier = threadIdentifier }
        if let badge { content.badge = NSNumber(value: badge) }

        var info: [AnyHashable: Any] = userInfo
        info["context_id"] = contextId
        info["scheduled_at"] = scheduledAt
        content.userInfo = info
        return content
    }
}

extension NotificationSound {
    var systemValue: UNNotificationSound? {
        switch self {
            case .none: return nil
            case .default: return .default
            case .named(let name): return UNNotificationSound(named: UNNotificationSoundName(name))
        }
    }
}

extension NotificationInterruptionLevel {
    var systemValue: UNNotificationInterruptionLevel {
        switch self {
            case .passive: return .passive
            case .active: return .active
            case .timeSensitive: return .timeSensitive
            case .critical: return .critical
        }
    }
}
