import UIKit

/// Creates the compositional layout for the calendar collection view
/// The layout consists of a 7-column grid (days of the week) with month headers
enum VGRCalendarLayout {

    /// Element kind identifier for month section headers
    static let monthHeaderKind = "month-header"

    /// Estimated row height (actual height determined by cell content)
    static let estimatedRowHeight: CGFloat = 60

    /// Creates the compositional layout for the calendar
    /// - Returns: A configured UICollectionViewCompositionalLayout
    @MainActor
    static func createLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = sectionSpacing

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { sectionIndex, environment in
                return createMonthSection(environment: environment)
            },
            configuration: configuration
        )

        /// Register the section background decoration view
        layout.register(
            VGRCalendarSectionBackground.self,
            forDecorationViewOfKind: VGRCalendarSectionBackground.elementKind
        )

        return layout
    }

    /// Spacing constants
    private static let horizontalItemSpacing: CGFloat = 2
    private static let verticalRowSpacing: CGFloat = 8
    private static let horizontalInset: CGFloat = 16
    private static let sectionSpacing: CGFloat = 32

    /// Creates a section layout for a month
    /// - Parameter environment: The layout environment providing container size info
    /// - Returns: A configured NSCollectionLayoutSection
    @MainActor
    private static func createMonthSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        /// Item - single day cell with fractional width (1/7 of group)
        /// Using fractional width ensures items fill the space exactly like the weekday header stack
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .estimated(estimatedRowHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        /// Group - horizontal row of 7 days (one week)
        /// All items in the group will have the same height (tallest cell wins)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedRowHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 7
        )
        /// No inter-item spacing to match the weekday header stack layout
        group.interItemSpacing = .fixed(0)

        /// Section - one month
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = verticalRowSpacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontalInset, bottom: 16, trailing: horizontalInset)

        /// Month header (dynamic height for Dynamic Type support)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(78)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: monthHeaderKind,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]

        /// Section background (white rounded box)
        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: VGRCalendarSectionBackground.elementKind
        )
        section.decorationItems = [backgroundItem]

        return section
    }
}
