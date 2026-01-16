import Foundation

/// Protocol for providing calendar data with generic day data type
/// Conforming types must be Equatable for SwiftUI diffing
public protocol VGRCalendarDataProviding<DayData>: Equatable {
    associatedtype DayData: Hashable

    /// All day data keyed by calendar index
    /// Used by the calendar view to efficiently update the underlying view controller
    var dayData: [VGRCalendarIndexKey: DayData] { get }

    /// All month accessibility labels keyed by section
    /// Used by the calendar view to update month headers
    var monthLabels: [VGRCalendarSection: String] { get }

    /// Returns the event data for a specific day
    /// - Parameter day: The day index key
    /// - Returns: The data for that day, or nil if none exists
    func eventData(for day: VGRCalendarIndexKey) -> DayData?

    /// Returns the accessibility label for a month header
    /// - Parameter month: The month section
    /// - Returns: The accessibility label, or nil to use default (month name)
    func accessibilityLabel(for month: VGRCalendarSection) -> String?
}

/// Default implementations
public extension VGRCalendarDataProviding {
    func eventData(for day: VGRCalendarIndexKey) -> DayData? {
        dayData[day]
    }

    func accessibilityLabel(for month: VGRCalendarSection) -> String? {
        monthLabels[month]
    }

    var monthLabels: [VGRCalendarSection: String] {
        [:]
    }
}

/// Default struct implementation of VGRCalendarDataProviding
public struct VGRCalendarData<DayData: Hashable>: VGRCalendarDataProviding {

    /// Day data keyed by calendar index
    public var dayData: [VGRCalendarIndexKey: DayData]

    /// Month accessibility labels keyed by section
    public var monthLabels: [VGRCalendarSection: String]

    /// Initialize with day data only (no custom month labels)
    public init(dayData: [VGRCalendarIndexKey: DayData]) {
        self.dayData = dayData
        self.monthLabels = [:]
    }

    /// Initialize with both day data and month labels
    public init(dayData: [VGRCalendarIndexKey: DayData], monthLabels: [VGRCalendarSection: String]) {
        self.dayData = dayData
        self.monthLabels = monthLabels
    }
}
