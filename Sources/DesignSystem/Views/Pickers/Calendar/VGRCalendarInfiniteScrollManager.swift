import UIKit

/// Manages infinite scrolling for the calendar by dynamically expanding the date window
/// as the user scrolls near the boundaries
@MainActor
final class VGRCalendarInfiniteScrollManager {

    /// The calendar used for date calculations
    private let calendar = Calendar.current

    /// Current window bounds
    private(set) var windowStartDate: Date
    private(set) var windowEndDate: Date

    /// Threshold in points from edge to trigger expansion (approximately 3 screen heights)
    private let expansionThreshold: CGFloat = 2500

    /// Number of months to add when expanding
    private let expansionMonths = 24

    /// Flag to prevent concurrent expansions
    private var isExpanding = false

    /// Callback when the window needs to expand backward (into the past)
    var onExpandBackward: ((_ newStartDate: Date) -> Void)?

    /// Callback when the window needs to expand forward (into the future)
    var onExpandForward: ((_ newEndDate: Date) -> Void)?

    /// Initializes the manager with an initial date window
    /// - Parameters:
    ///   - centerDate: The date to center the initial window around (defaults to today)
    ///   - initialMonthsBack: Number of months before center date
    ///   - initialMonthsForward: Number of months after center date
    init(
        centerDate: Date = Date(),
        initialMonthsBack: Int = 36,
        initialMonthsForward: Int = 36
    ) {
        let start = calendar.date(byAdding: .month, value: -initialMonthsBack, to: centerDate) ?? centerDate
        let end = calendar.date(byAdding: .month, value: initialMonthsForward, to: centerDate) ?? centerDate

        self.windowStartDate = calendar.startOfMonth(for: start)
        self.windowEndDate = calendar.endOfMonth(for: end)
    }

    /// Call this from scrollViewDidScroll to check if expansion is needed
    /// - Parameters:
    ///   - scrollView: The scroll view being scrolled
    func handleScroll(_ scrollView: UIScrollView) {
        guard !isExpanding else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height

        /// Check if approaching top (scrolling into the past)
        if offsetY < expansionThreshold {
            expandBackward()
        }

        /// Check if approaching bottom (scrolling into the future)
        if offsetY + frameHeight > contentHeight - expansionThreshold {
            expandForward()
        }
    }

    /// Expands the window backward into the past
    private func expandBackward() {
        guard !isExpanding else { return }
        isExpanding = true

        guard let newStart = calendar.date(byAdding: .month, value: -expansionMonths, to: windowStartDate) else {
            isExpanding = false
            return
        }

        windowStartDate = calendar.startOfMonth(for: newStart)

        onExpandBackward?(windowStartDate)

        /// Reset expansion flag after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isExpanding = false
        }
    }

    /// Expands the window forward into the future
    private func expandForward() {
        guard !isExpanding else { return }
        isExpanding = true

        guard let newEnd = calendar.date(byAdding: .month, value: expansionMonths, to: windowEndDate) else {
            isExpanding = false
            return
        }

        windowEndDate = calendar.endOfMonth(for: newEnd)

        onExpandForward?(windowEndDate)

        /// Reset expansion flag after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isExpanding = false
        }
    }

    /// Resets the window to a new center date
    /// - Parameter centerDate: The new center date
    func resetWindow(to centerDate: Date) {
        let start = calendar.date(byAdding: .month, value: -36, to: centerDate) ?? centerDate
        let end = calendar.date(byAdding: .month, value: 36, to: centerDate) ?? centerDate

        windowStartDate = calendar.startOfMonth(for: start)
        windowEndDate = calendar.endOfMonth(for: end)
    }
}

// MARK: - Calendar Extension

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }

    func endOfMonth(for date: Date) -> Date {
        guard let startOfMonth = self.date(from: dateComponents([.year, .month], from: date)),
              let nextMonth = self.date(byAdding: .month, value: 1, to: startOfMonth),
              let endOfMonth = self.date(byAdding: .day, value: -1, to: nextMonth) else {
            return date
        }
        return endOfMonth
    }
}
