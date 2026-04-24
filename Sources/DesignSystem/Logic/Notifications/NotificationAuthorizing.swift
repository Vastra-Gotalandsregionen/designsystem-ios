import Foundation
@preconcurrency import UserNotifications

/// Authorization seam — wraps `UNUserNotificationCenter` authorization so
/// apps can swap in a stub during tests / previews.
public protocol NotificationAuthorizing: Sendable {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func authorizationStatus() async -> UNAuthorizationStatus
    func notificationSettings() async -> UNNotificationSettings
}

public struct SystemNotificationAuthorizer: NotificationAuthorizing {

    public init() {}

    public func requestAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound]) async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }

    public func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationSettings().authorizationStatus
    }

    public func notificationSettings() async -> UNNotificationSettings {
        await UNUserNotificationCenter.current().notificationSettings()
    }
}

/// Stub authorizer for previews and tests.
public struct PreviewNotificationAuthorizer: NotificationAuthorizing {

    private let granted: Bool

    public init(granted: Bool = true) {
        self.granted = granted
    }

    public func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool { granted }
    public func authorizationStatus() async -> UNAuthorizationStatus { granted ? .authorized : .denied }
    public func notificationSettings() async -> UNNotificationSettings {
        // No public init for UNNotificationSettings; callers that need a real value
        // should inject `SystemNotificationAuthorizer` instead.
        fatalError("PreviewNotificationAuthorizer.notificationSettings is not implemented — use SystemNotificationAuthorizer in production paths")
    }
}
