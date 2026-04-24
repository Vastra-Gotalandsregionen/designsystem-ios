import Foundation
import OSLog

/// Persistence seam for the per-context `NotificationSettings` map.
///
/// Apps inject a concrete store on `NotificationManager.init`. A
/// `UserDefaults`-backed implementation is provided; tests can substitute an
/// in-memory actor.
public protocol NotificationStoring: Sendable {
    func all() async -> [String: NotificationSettings]
    func get(contextId: String) async -> NotificationSettings?
    func set(_ settings: NotificationSettings, for contextId: String) async
    func remove(contextId: String) async
    func remove(contextIdsWithPrefix prefix: String) async -> [String]

    /// App-level master switch. Defaults to `true`.
    func isGlobalEnabled() async -> Bool
    func setGlobalEnabled(_ enabled: Bool) async
}

/// `UserDefaults`-backed implementation. Holds the full settings map in memory
/// and writes through on every mutation.
///
/// The `suite` defaults to `.standard`; inject a specific `UserDefaults` for
/// app-group or test isolation.
public actor UserDefaultsNotificationStore: NotificationStoring {

    private let suite: UserDefaults
    private let key: String
    private let globalKey: String
    private let logger = Logger(subsystem: "DesignSystem.Notifications", category: "Store")
    private var cache: [String: NotificationSettings]
    private var globalEnabledCache: Bool

    public init(suite: sending UserDefaults = .standard, key: String = "designsystem.notifications.v1") {
        self.suite = suite
        self.key = key
        self.globalKey = "\(key).globalEnabled"
        self.cache = Self.load(from: suite, key: key)
        self.globalEnabledCache = Self.loadGlobalEnabled(from: suite, key: "\(key).globalEnabled")
    }

    public func all() -> [String: NotificationSettings] {
        cache
    }

    public func get(contextId: String) -> NotificationSettings? {
        cache[contextId]
    }

    public func set(_ settings: NotificationSettings, for contextId: String) {
        cache[contextId] = settings
        flush()
    }

    public func remove(contextId: String) {
        cache.removeValue(forKey: contextId)
        flush()
    }

    public func remove(contextIdsWithPrefix prefix: String) -> [String] {
        let matches = cache.keys.filter { $0.hasPrefix(prefix) }
        for contextId in matches {
            cache.removeValue(forKey: contextId)
        }
        flush()
        return Array(matches)
    }

    public func isGlobalEnabled() -> Bool {
        globalEnabledCache
    }

    public func setGlobalEnabled(_ enabled: Bool) {
        globalEnabledCache = enabled
        suite.set(enabled, forKey: globalKey)
    }

    private func flush() {
        do {
            let data = try JSONEncoder().encode(cache)
            suite.set(data, forKey: key)
        } catch {
            logger.error("Failed to persist notification settings: \(error.localizedDescription, privacy: .public)")
        }
    }

    private static func load(from suite: UserDefaults, key: String) -> [String: NotificationSettings] {
        guard let data = suite.data(forKey: key) else { return [:] }
        do {
            return try JSONDecoder().decode([String: NotificationSettings].self, from: data)
        } catch {
            Logger(subsystem: "DesignSystem.Notifications", category: "Store")
                .error("Failed to decode notification settings, starting empty: \(error.localizedDescription, privacy: .public)")
            return [:]
        }
    }

    /// Default is `true`. Stored as a separate key so unsetting the main settings
    /// dict doesn't clobber the master switch.
    private static func loadGlobalEnabled(from suite: UserDefaults, key: String) -> Bool {
        suite.object(forKey: key) as? Bool ?? true
    }
}

/// In-memory store for unit tests and previews.
public actor InMemoryNotificationStore: NotificationStoring {

    private var cache: [String: NotificationSettings]
    private var globalEnabledCache: Bool

    public init(initial: [String: NotificationSettings] = [:], globalEnabled: Bool = true) {
        self.cache = initial
        self.globalEnabledCache = globalEnabled
    }

    public func all() -> [String: NotificationSettings] { cache }
    public func get(contextId: String) -> NotificationSettings? { cache[contextId] }
    public func set(_ settings: NotificationSettings, for contextId: String) { cache[contextId] = settings }
    public func remove(contextId: String) { cache.removeValue(forKey: contextId) }

    public func remove(contextIdsWithPrefix prefix: String) -> [String] {
        let matches = cache.keys.filter { $0.hasPrefix(prefix) }
        for contextId in matches { cache.removeValue(forKey: contextId) }
        return Array(matches)
    }

    public func isGlobalEnabled() -> Bool { globalEnabledCache }
    public func setGlobalEnabled(_ enabled: Bool) { globalEnabledCache = enabled }
}
