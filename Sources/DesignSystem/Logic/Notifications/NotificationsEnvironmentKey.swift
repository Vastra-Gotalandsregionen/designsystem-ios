import SwiftUI

/// Default accessor for `NotificationManager` in SwiftUI view hierarchies.
///
/// Apps inject their manager on the root scene:
///
///     RootView().environment(\.notifications, notifications)
///
/// and views read it:
///
///     @Environment(\.notifications) private var notifications
///
/// The default is `nil`, so views that may render before injection (or in
/// previews without a manager) can safely read it and no-op.
private struct NotificationsEnvironmentKey: EnvironmentKey {
    static let defaultValue: NotificationManager? = nil
}

public extension EnvironmentValues {
    var notifications: NotificationManager? {
        get { self[NotificationsEnvironmentKey.self] }
        set { self[NotificationsEnvironmentKey.self] = newValue }
    }
}
