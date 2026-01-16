import UIKit

/// Represents a month section in the calendar
public struct VGRCalendarSection: Hashable, Sendable {
    public let year: Int
    public let month: Int

    /// The first day of this month
    public var firstDayDate: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }

    public init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }

    public init(from date: Date) {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        self.year = components.year ?? 0
        self.month = components.month ?? 0
    }
}

/// Represents a day item in the calendar
public struct VGRCalendarItem: Hashable, Sendable {
    public let indexKey: VGRCalendarIndexKey

    /// Whether this is a placeholder for padding (days from adjacent months)
    public let isPlaceholder: Bool

    public init(indexKey: VGRCalendarIndexKey, isPlaceholder: Bool = false) {
        self.indexKey = indexKey
        self.isPlaceholder = isPlaceholder
    }
}

/// Manages the diffable data source for the calendar collection view
@MainActor
final class VGRCalendarDataSource {

    typealias DataSource = UICollectionViewDiffableDataSource<VGRCalendarSection, VGRCalendarItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<VGRCalendarSection, VGRCalendarItem>

    /// The underlying diffable data source (optional until configured)
    private(set) var dataSource: DataSource?

    /// The calendar used for date calculations
    private let calendar = Calendar.current

    /// Cache of generated sections to avoid regenerating
    private var sectionCache: [VGRCalendarSection: [VGRCalendarItem]] = [:]

    /// Whether the data source has been configured
    var isConfigured: Bool {
        dataSource != nil
    }

    /// Initializes the data source with the collection view and cell provider
    /// - Parameters:
    ///   - collectionView: The collection view to manage
    ///   - cellProvider: Closure that configures and returns cells
    ///   - supplementaryViewProvider: Closure that configures and returns supplementary views
    func configure(
        collectionView: UICollectionView,
        cellProvider: @escaping (UICollectionView, IndexPath, VGRCalendarItem) -> UICollectionViewCell?,
        supplementaryViewProvider: @escaping (UICollectionView, String, IndexPath) -> UICollectionReusableView?
    ) {
        let ds = DataSource(collectionView: collectionView, cellProvider: cellProvider)
        ds.supplementaryViewProvider = supplementaryViewProvider
        dataSource = ds
    }

    /// Generates a snapshot for the given date range
    /// - Parameters:
    ///   - startDate: The start of the date range
    ///   - endDate: The end of the date range
    /// - Returns: A configured snapshot
    func generateSnapshot(from startDate: Date, to endDate: Date) -> Snapshot {
        var snapshot = Snapshot()

        let sections = generateSections(from: startDate, to: endDate)
        snapshot.appendSections(sections)

        for section in sections {
            let items = generateItems(for: section)
            snapshot.appendItems(items, toSection: section)
        }

        return snapshot
    }

    /// Generates month sections for the date range
    private func generateSections(from startDate: Date, to endDate: Date) -> [VGRCalendarSection] {
        var sections: [VGRCalendarSection] = []

        var currentDate = calendar.startOfMonth(for: startDate)
        let endMonth = calendar.startOfMonth(for: endDate)

        while currentDate <= endMonth {
            let components = calendar.dateComponents([.year, .month], from: currentDate)
            if let year = components.year, let month = components.month {
                sections.append(VGRCalendarSection(year: year, month: month))
            }

            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextMonth
        }

        return sections
    }

    /// Generates day items for a month section, including padding days
    private func generateItems(for section: VGRCalendarSection) -> [VGRCalendarItem] {
        /// Check cache first
        if let cached = sectionCache[section] {
            return cached
        }

        var items: [VGRCalendarItem] = []

        guard let monthStart = calendar.date(from: DateComponents(year: section.year, month: section.month, day: 1)),
              let monthRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return items
        }

        /// Calculate the weekday of the first day (1 = Sunday in default calendar)
        let firstWeekday = calendar.component(.weekday, from: monthStart)

        /// Adjust for locale's first day of week
        let firstDayOfWeek = calendar.firstWeekday
        let paddingDays = (firstWeekday - firstDayOfWeek + 7) % 7

        /// Add placeholder items for padding at the start of the month
        if paddingDays > 0 {
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: monthStart),
                  let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth) else {
                return items
            }

            let previousMonthComponents = calendar.dateComponents([.year, .month], from: previousMonth)
            let startDay = previousMonthRange.upperBound - paddingDays

            for day in startDay..<previousMonthRange.upperBound {
                let indexKey = VGRCalendarIndexKey(
                    year: previousMonthComponents.year ?? 0,
                    month: previousMonthComponents.month ?? 0,
                    day: day
                )
                items.append(VGRCalendarItem(indexKey: indexKey, isPlaceholder: true))
            }
        }

        /// Add actual days of the month
        for day in monthRange {
            let indexKey = VGRCalendarIndexKey(year: section.year, month: section.month, day: day)
            items.append(VGRCalendarItem(indexKey: indexKey, isPlaceholder: false))
        }

        /// Add placeholder items for padding at the end (to complete the last week)
        let totalItems = items.count
        let remainder = totalItems % 7
        if remainder > 0 {
            let trailingPadding = 7 - remainder
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
                return items
            }

            let nextMonthComponents = calendar.dateComponents([.year, .month], from: nextMonth)

            for day in 1...trailingPadding {
                let indexKey = VGRCalendarIndexKey(
                    year: nextMonthComponents.year ?? 0,
                    month: nextMonthComponents.month ?? 0,
                    day: day
                )
                items.append(VGRCalendarItem(indexKey: indexKey, isPlaceholder: true))
            }
        }

        /// Cache the result
        sectionCache[section] = items

        return items
    }

    /// Applies the snapshot to the data source
    /// - Parameters:
    ///   - snapshot: The snapshot to apply
    ///   - animatingDifferences: Whether to animate the changes
    func apply(_ snapshot: Snapshot, animatingDifferences: Bool = false) {
        guard let dataSource else { return }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    /// Returns the current snapshot
    func snapshot() -> Snapshot {
        guard let dataSource else { return Snapshot() }
        return dataSource.snapshot()
    }

    /// Reconfigures items without regenerating the entire snapshot
    /// - Parameter items: The items to reconfigure
    func reconfigureItems(_ items: [VGRCalendarItem]) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    /// Clears the section cache
    func clearCache() {
        sectionCache.removeAll()
    }

    /// Returns the section for a given index path
    func section(at indexPath: IndexPath) -> VGRCalendarSection? {
        guard let dataSource else { return nil }
        let snapshot = dataSource.snapshot()
        let sections = snapshot.sectionIdentifiers
        guard indexPath.section < sections.count else { return nil }
        return sections[indexPath.section]
    }

    /// Returns the item for a given index path
    func item(at indexPath: IndexPath) -> VGRCalendarItem? {
        guard let dataSource else { return nil }
        return dataSource.itemIdentifier(for: indexPath)
    }

    /// Returns the index path for a given item
    func indexPath(for item: VGRCalendarItem) -> IndexPath? {
        guard let dataSource else { return nil }
        return dataSource.indexPath(for: item)
    }
}

// MARK: - Calendar Extension

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
