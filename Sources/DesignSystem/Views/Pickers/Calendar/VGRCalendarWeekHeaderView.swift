import SwiftUI

public struct VGRCalendarWeekHeaderView: View {
    let spacing: CGFloat

    public init(spacing: CGFloat = 2) {
        self.spacing = spacing
    }

    private let symbols = Calendar.current.shortStandaloneWeekdaySymbols
    private let firstWeekdayIndex = Calendar.current.firstWeekday - 1 /// calendar is 1-indexed
    private var orderedWeekdays: [String] {
        Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(orderedWeekdays, id: \.self) { day in
                Text(day.capitalized(with: .autoupdatingCurrent))
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.Neutral.text)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
        }
    }
}

#Preview {
    VGRCalendarWeekHeaderView()
}
