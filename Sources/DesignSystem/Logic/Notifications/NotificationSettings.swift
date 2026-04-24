import Foundation

/// Per-context configuration for a notification the manager owns.
///
/// One `NotificationSettings` value corresponds to one `contextId`. The manager
/// derives zero or more `UNNotificationRequest`s from it depending on the
/// recurrence shape.
public struct NotificationSettings: Sendable, Codable, Equatable, Hashable {

    public var enabled: Bool

    /// What the notification renders when it fires.
    public var content: NotificationContent

    /// The hour/minute-of-day component is honored; the date portion is ignored.
    public var timeOfDay: Date

    /// First day the schedule is active.
    public var startDate: Date

    /// Last day the schedule is active, or `nil` for perpetual.
    public var endDate: Date?

    /// Omit for a one-shot notification on `startDate` at `timeOfDay`.
    public var recurrence: Recurrence?

    /// Per-occurrence exceptions (reschedule / skip).
    public var deviations: [RecurrenceDeviation]

    /// Cursor: the last date the manager has already materialized into
    /// individual `UNNotificationRequest`s. Moved forward by the refresher.
    public var scheduledUntil: Date

    public init(
        enabled: Bool = true,
        content: NotificationContent,
        timeOfDay: Date,
        startDate: Date = Date(),
        endDate: Date? = nil,
        recurrence: Recurrence? = nil,
        deviations: [RecurrenceDeviation] = [],
        scheduledUntil: Date = Date()
    ) {
        self.enabled = enabled
        self.content = content
        self.timeOfDay = timeOfDay
        self.startDate = startDate
        self.endDate = endDate
        self.recurrence = recurrence
        self.deviations = deviations
        self.scheduledUntil = scheduledUntil
    }
}

public extension NotificationSettings {

    /// True when a simple repeating OS trigger (`UNCalendarNotificationTrigger` with
    /// `repeats: true`) can cover the whole schedule — no deviations, no end date,
    /// and `frequency == 1`. In that case no background refresh is needed.
    ///
    /// Weekly recurrences with more than one weekday fall through to individual
    /// scheduling because `DateComponents.weekday` only accepts a single value.
    var canUseNativeRepeatingTrigger: Bool {
        guard let recurrence else { return false }
        guard recurrence.frequency == 1, deviations.isEmpty, endDate == nil else { return false }
        if recurrence.period == .week, (recurrence.weekdays?.count ?? 0) > 1 { return false }
        return true
    }

    /// True when the rolling window has drained and the refresher should extend it.
    /// Native-repeat and finite-end schedules never need rescheduling.
    func needsRescheduling(asOf date: Date = Date(), leadTime: TimeInterval = 0) -> Bool {
        if canUseNativeRepeatingTrigger { return false }
        if let endDate, endDate <= date { return false }
        return scheduledUntil <= date.addingTimeInterval(leadTime)
    }
}
