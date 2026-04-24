import Foundation
import BackgroundTasks
import OSLog

/// Glue between `BGTaskScheduler` and `NotificationManager.refreshSchedules()`.
///
/// Apps that schedule complex recurrences (deviations, `frequency > 1`, finite
/// `endDate`) need to extend the rolling window periodically. This helper
/// handles the `BGAppRefreshTask` boilerplate.
///
/// Call `register()` once during app launch (before the scene connects), and
/// call `scheduleNext()` when the app enters background.
///
/// Requires the task identifier to be listed under
/// `BGTaskSchedulerPermittedIdentifiers` in the app's Info.plist.
public struct NotificationBackgroundRefresher: Sendable {

    private let manager: NotificationManager
    private let taskIdentifier: String
    private let refreshInterval: TimeInterval
    private let logger = Logger(subsystem: "DesignSystem.Notifications", category: "BackgroundRefresher")

    public init(
        manager: NotificationManager,
        taskIdentifier: String,
        refreshInterval: TimeInterval = 7 * 24 * 3600
    ) {
        self.manager = manager
        self.taskIdentifier = taskIdentifier
        self.refreshInterval = refreshInterval
    }

    /// Registers the handler with `BGTaskScheduler`. Must be called before the
    /// app finishes launching.
    public func register() {
        let registered = BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(refreshTask)
        }

        if !registered {
            logger.error("Failed to register BGAppRefreshTask '\(taskIdentifier, privacy: .public)' — check Info.plist BGTaskSchedulerPermittedIdentifiers")
        }
    }

    /// Submits the next refresh request.
    public func scheduleNext() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: refreshInterval)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.error("Failed to submit BGAppRefreshTaskRequest: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Runs the refresh and re-submits the next one — always. If the task is
    /// expired mid-flight, we still complete cleanly so the system doesn't
    /// throttle future runs.
    private func handle(_ task: BGAppRefreshTask) {
        // BGAppRefreshTask isn't Sendable, but its two mutations
        // (setTaskCompleted, expirationHandler) are single-shot and
        // BGTaskScheduler serializes them. Box it so the async Task below
        // captures a Sendable reference instead of the bare class.
        struct Box: @unchecked Sendable { let task: BGAppRefreshTask }
        let box = Box(task: task)

        let work = Task {
            do {
                try await manager.refreshSchedules()
                box.task.setTaskCompleted(success: true)
            } catch {
                logger.error("refreshSchedules failed: \(error.localizedDescription, privacy: .public)")
                box.task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            work.cancel()
            task.setTaskCompleted(success: false)
        }

        scheduleNext()
    }
}
