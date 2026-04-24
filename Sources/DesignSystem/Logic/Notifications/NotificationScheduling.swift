import Foundation
@preconcurrency import UserNotifications

/// Low-level seam wrapping `UNUserNotificationCenter`.
///
/// The manager orchestrates; this protocol is the thin bridge to the system.
/// Kept narrow so tests can supply a recording fake.
public protocol NotificationScheduling: Sendable {
    func schedule(_ requests: [NotificationRequest], contextId: String) async throws
    func pendingIdentifiers(withPrefix prefix: String) async -> [String]
    func remove(identifiers: [String]) async
    func removeAll(withPrefix prefix: String) async
    func setCategories(_ categories: sending Set<UNNotificationCategory>) async
}

public struct SystemNotificationScheduler: NotificationScheduling {

    private let center: UNUserNotificationCenter

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    public func schedule(_ requests: [NotificationRequest], contextId: String) async throws {
        for request in requests {
            try await center.add(request.makeSystemRequest(contextId: contextId))
        }
    }

    public func pendingIdentifiers(withPrefix prefix: String) async -> [String] {
        let pending = await center.pendingNotificationRequests()
        return pending
            .map { $0.identifier }
            .filter { $0.hasPrefix(prefix) }
    }

    public func remove(identifiers: [String]) async {
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    public func removeAll(withPrefix prefix: String) async {
        let ids = await pendingIdentifiers(withPrefix: prefix)
        await remove(identifiers: ids)
    }

    public func setCategories(_ categories: sending Set<UNNotificationCategory>) async {
        center.setNotificationCategories(categories)
    }
}

/// In-memory scheduler for previews and tests. Records every request so a
/// preview or test can observe what the manager *would* have scheduled without
/// actually touching `UNUserNotificationCenter`.
public actor RecordingNotificationScheduler: NotificationScheduling {

    public private(set) var scheduled: [NotificationRequest] = []
    public private(set) var removed: [String] = []

    public init() {}

    public func schedule(_ requests: [NotificationRequest], contextId _: String) async throws {
        scheduled.append(contentsOf: requests)
    }

    public func pendingIdentifiers(withPrefix prefix: String) async -> [String] {
        scheduled.map(\.identifier).filter { $0.hasPrefix(prefix) }
    }

    public func remove(identifiers: [String]) async {
        scheduled.removeAll { identifiers.contains($0.identifier) }
        removed.append(contentsOf: identifiers)
    }

    public func removeAll(withPrefix prefix: String) async {
        let ids = scheduled.map(\.identifier).filter { $0.hasPrefix(prefix) }
        await remove(identifiers: ids)
    }

    public func setCategories(_: sending Set<UNNotificationCategory>) async {}
}
