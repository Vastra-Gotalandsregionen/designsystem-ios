import UIKit
import SwiftUI

/// A high-performance calendar view controller using UICollectionView with compositional layout
/// Supports infinite scrolling and custom SwiftUI day cell rendering
public final class VGRCalendarViewController<DayData: Hashable>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {

    /// The collection view displaying the calendar
    private(set) var collectionView: UICollectionView!

    /// The data source manager
    private let dataSourceManager = VGRCalendarDataSource()

    /// The infinite scroll manager
    private let infiniteScrollManager: VGRCalendarInfiniteScrollManager

    /// Calendar event data keyed by date
    var calendarData: [VGRCalendarIndexKey: DayData] = [:] {
        didSet {
            if isViewLoaded {
                reconfigureVisibleCells()
            }
        }
    }

    /// Month accessibility labels keyed by section
    var monthAccessibilityLabels: [VGRCalendarSection: String] = [:] {
        didSet {
            if isViewLoaded {
                reconfigureVisibleHeaders()
            }
        }
    }

    /// The currently selected date
    var selectedDate: VGRCalendarIndexKey? {
        didSet {
            if oldValue != selectedDate {
                handleSelectionChange(from: oldValue, to: selectedDate)
            }
        }
    }

    /// Callback when a date is selected
    var onDateSelected: ((VGRCalendarIndexKey) -> Void)?

    /// Closure that builds the SwiftUI view for each day cell (type-erased)
    private let dayContentBuilder: (VGRCalendarIndexKey, DayData?, Bool, Bool) -> AnyView

    /// Today's date index for highlighting
    private let todayIndex = VGRCalendarIndexKey(from: Date())

    /// Flag to track if initial scroll has occurred
    private var hasScrolledToInitialDate = false

    /// The initial date to scroll to on first load
    private let initialDate: Date

    // MARK: - Initialization

    /// Initializes the calendar view controller
    /// - Parameters:
    ///   - initialDate: The date to initially scroll to (defaults to today)
    ///   - dayContentBuilder: Closure that creates the SwiftUI view for each day (type-erased)
    init(
        initialDate: Date = Date(),
        dayContentBuilder: @escaping (VGRCalendarIndexKey, DayData?, Bool, Bool) -> AnyView
    ) {
        self.initialDate = initialDate
        self.dayContentBuilder = dayContentBuilder
        self.infiniteScrollManager = VGRCalendarInfiniteScrollManager(centerDate: initialDate)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupCollectionView()
        setupDataSource()
        setupInfiniteScroll()
        loadInitialData()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !hasScrolledToInitialDate {
            hasScrolledToInitialDate = true
            scrollToDate(initialDate, animated: false)
        }
    }

    // MARK: - Setup

    private func setupCollectionView() {
        let layout = VGRCalendarLayout.createLayout()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.delegate = self

        /// Disable scroll-to-top on status bar tap
        collectionView.scrollsToTop = false

        /// Hide scroll indicators for infinite scroll
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        /// Register cell and supplementary views
        collectionView.register(
            VGRCalendarDayCell.self,
            forCellWithReuseIdentifier: VGRCalendarDayCell.reuseIdentifier
        )
        collectionView.register(
            VGRCalendarPlaceholderCell.self,
            forCellWithReuseIdentifier: VGRCalendarPlaceholderCell.reuseIdentifier
        )
        collectionView.register(
            VGRCalendarMonthHeader.self,
            forSupplementaryViewOfKind: VGRCalendarLayout.monthHeaderKind,
            withReuseIdentifier: VGRCalendarMonthHeader.reuseIdentifier
        )

        /// Enable prefetching for smoother scrolling
        collectionView.prefetchDataSource = self

        view.addSubview(collectionView)
    }

    private func setupDataSource() {
        dataSourceManager.configure(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                self?.configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
            },
            supplementaryViewProvider: { [weak self] collectionView, kind, indexPath in
                self?.configureSupplementaryView(collectionView: collectionView, kind: kind, indexPath: indexPath)
            }
        )
    }

    private func setupInfiniteScroll() {
        infiniteScrollManager.onExpandBackward = { [weak self] newStartDate in
            self?.handleExpandBackward(newStartDate: newStartDate)
        }

        infiniteScrollManager.onExpandForward = { [weak self] newEndDate in
            self?.handleExpandForward(newEndDate: newEndDate)
        }
    }

    private func loadInitialData() {
        let snapshot = dataSourceManager.generateSnapshot(
            from: infiniteScrollManager.windowStartDate,
            to: infiniteScrollManager.windowEndDate
        )
        dataSourceManager.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Cell Configuration

    private func configureCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        item: VGRCalendarItem
    ) -> UICollectionViewCell? {
        let indexKey = item.indexKey
        let isPlaceholder = item.isPlaceholder

        /// Use simple UIKit cell for placeholders to avoid SwiftUI overhead
        if isPlaceholder {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: VGRCalendarPlaceholderCell.reuseIdentifier,
                for: indexPath
            )
        }

        /// Use SwiftUI cell only for actual day content
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VGRCalendarDayCell.reuseIdentifier,
            for: indexPath
        ) as? VGRCalendarDayCell else {
            return nil
        }

        let eventData = calendarData[indexKey]
        let isCurrent = indexKey == todayIndex
        let isSelected = indexKey == selectedDate
        let content = dayContentBuilder(indexKey, eventData, isCurrent, isSelected)
        cell.configure(indexKey: indexKey, content: content)

        return cell
    }

    private func configureSupplementaryView(
        collectionView: UICollectionView,
        kind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        guard kind == VGRCalendarLayout.monthHeaderKind,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: VGRCalendarMonthHeader.reuseIdentifier,
                for: indexPath
              ) as? VGRCalendarMonthHeader else {
            return nil
        }

        if let section = dataSourceManager.section(at: indexPath) {
            let label = monthAccessibilityLabels[section]
            header.configure(with: section, accessibilityLabel: label)
        }

        return header
    }

    // MARK: - Selection Handling

    private func handleSelectionChange(from oldValue: VGRCalendarIndexKey?, to newValue: VGRCalendarIndexKey?) {
        var itemsToReconfigure: [VGRCalendarItem] = []

        if let old = oldValue {
            itemsToReconfigure.append(VGRCalendarItem(indexKey: old))
        }

        if let new = newValue {
            itemsToReconfigure.append(VGRCalendarItem(indexKey: new))
        }

        guard !itemsToReconfigure.isEmpty else { return }

        /// Filter to only items that exist in the current snapshot
        let snapshot = dataSourceManager.snapshot()
        let existingItems = itemsToReconfigure.filter { snapshot.itemIdentifiers.contains($0) }

        if !existingItems.isEmpty {
            dataSourceManager.reconfigureItems(existingItems)
        }
    }

    // MARK: - Infinite Scroll Handling

    private func handleExpandBackward(newStartDate: Date) {
        let oldContentHeight = collectionView.contentSize.height
        let oldOffsetY = collectionView.contentOffset.y

        /// Generate new snapshot with expanded range
        let snapshot = dataSourceManager.generateSnapshot(
            from: newStartDate,
            to: infiniteScrollManager.windowEndDate
        )

        /// Apply without animation
        dataSourceManager.apply(snapshot, animatingDifferences: false)

        /// Force layout to calculate new content size
        collectionView.layoutIfNeeded()

        /// Adjust content offset to maintain visual position
        let newContentHeight = collectionView.contentSize.height
        let heightDifference = newContentHeight - oldContentHeight
        collectionView.contentOffset.y = oldOffsetY + heightDifference
    }

    private func handleExpandForward(newEndDate: Date) {
        /// Generate new snapshot with expanded range
        let snapshot = dataSourceManager.generateSnapshot(
            from: infiniteScrollManager.windowStartDate,
            to: newEndDate
        )

        /// Apply without animation - no offset adjustment needed for forward expansion
        dataSourceManager.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Public Methods

    /// Scrolls to a specific date
    /// - Parameters:
    ///   - date: The date to scroll to
    ///   - animated: Whether to animate the scroll
    func scrollToDate(_ date: Date, animated: Bool = true) {
        let targetIndex = VGRCalendarIndexKey(from: date)
        let targetItem = VGRCalendarItem(indexKey: targetIndex)

        /// Check if date is within current window
        if let indexPath = dataSourceManager.indexPath(for: targetItem) {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
            return
        }

        /// Date is outside current window - reset window to center on target date
        infiniteScrollManager.resetWindow(to: date)

        /// Clear the section cache since we're rebuilding the data
        dataSourceManager.clearCache()

        /// Regenerate snapshot with new window
        let snapshot = dataSourceManager.generateSnapshot(
            from: infiniteScrollManager.windowStartDate,
            to: infiniteScrollManager.windowEndDate
        )
        dataSourceManager.apply(snapshot, animatingDifferences: false)

        /// Now scroll to the target date
        if let indexPath = dataSourceManager.indexPath(for: targetItem) {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
        }
    }

    /// Reconfigures visible cells when data changes
    func reconfigureVisibleCells() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        var itemsToReconfigure: [VGRCalendarItem] = []

        for indexPath in visibleIndexPaths {
            if let item = dataSourceManager.item(at: indexPath) {
                itemsToReconfigure.append(item)
            }
        }

        if !itemsToReconfigure.isEmpty {
            dataSourceManager.reconfigureItems(itemsToReconfigure)
        }
    }

    /// Reconfigures visible month headers when labels change
    func reconfigureVisibleHeaders() {
        let visibleHeaders = collectionView.visibleSupplementaryViews(
            ofKind: VGRCalendarLayout.monthHeaderKind
        )

        for case let header as VGRCalendarMonthHeader in visibleHeaders {
            guard let section = header.section else { continue }
            let label = monthAccessibilityLabels[section]
            header.configure(with: section, accessibilityLabel: label)
        }
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSourceManager.item(at: indexPath),
              !item.isPlaceholder else {
            return
        }

        selectedDate = item.indexKey
        onDateSelected?(item.indexKey)
    }

    // MARK: - UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        infiniteScrollManager.handleScroll(scrollView)
    }

    // MARK: - UICollectionViewDataSourcePrefetching

    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        /// Prefetching hint - the collection view is about to display these items
        /// We can use this to pre-warm caches if needed in the future
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        /// Cancelled prefetch - user scrolled in a different direction
    }
}
