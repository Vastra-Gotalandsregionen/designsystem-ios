import UIKit
import SwiftUI

/// A supplementary view that displays the month and year as a section header
/// with weekday labels below
final class VGRCalendarMonthHeader: UICollectionReusableView {

    /// Reuse identifier for supplementary view registration
    static let reuseIdentifier = "VGRCalendarMonthHeader"

    /// Shared date formatter for performance (creating formatters is expensive)
    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale.current
        return formatter
    }()

    /// Cached weekday symbols for performance
    private static let weekdaySymbols: [String] = {
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday

        /// Reorder symbols to start from the locale's first day of week
        var reordered: [String] = []
        for i in 0..<7 {
            let index = (firstWeekday - 1 + i) % 7
            reordered.append(symbols[index])
        }
        return reordered
    }()

    /// The label displaying the month and year
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
        label.textColor = UIColor(Color.Neutral.text)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Stack view for weekday labels
    private let weekdayStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    /// The section this header represents (stored for reconfiguration)
    private(set) var section: VGRCalendarSection?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(weekdayStack)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),

            weekdayStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekdayStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            weekdayStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            weekdayStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])

        /// Create labels for each weekday
        for symbol in Self.weekdaySymbols {
            let label = UILabel()
            label.text = symbol.capitalized
            label.font = .preferredFont(forTextStyle: .footnote).withWeight(.semibold)
            label.textColor = UIColor(Color.Neutral.text)
            label.textAlignment = .center
            label.adjustsFontForContentSizeCategory = true
            label.isAccessibilityElement = false
            weekdayStack.addArrangedSubview(label)
        }
    }

    /// Configures the header with a section
    /// - Parameters:
    ///   - section: The calendar section representing the month
    ///   - accessibilityLabel: Optional custom accessibility label (defaults to month name)
    func configure(with section: VGRCalendarSection, accessibilityLabel: String? = nil) {
        self.section = section
        self.titleLabel.text = Self.monthFormatter.string(from: section.firstDayDate).capitalized

        /// Accessibility
        self.titleLabel.isAccessibilityElement = true
        self.titleLabel.accessibilityLabel = accessibilityLabel ?? titleLabel.text
        self.titleLabel.accessibilityTraits = .header
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        section = nil
    }
}

// MARK: - UIFont Extension

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
