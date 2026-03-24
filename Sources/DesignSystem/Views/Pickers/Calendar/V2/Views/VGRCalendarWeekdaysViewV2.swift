import SwiftUI

struct VGRCalendarWeekdaysViewV2: View {
    var calendar: Calendar = .current

    private var weekdays: [VGRCalendarWeekday] {
        let start = VGRCalendarWeekday(calendar.firstWeekday)
        let all = VGRCalendarWeekday.allCases
        guard let index = all.firstIndex(of: start) else { return Array(all) }
        return Array(all[index...]) + Array(all[..<index])
    }

    private func symbol(for weekday: VGRCalendarWeekday) -> String {
        calendar.shortWeekdaySymbols[weekday.rawValue - 1]
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(symbol(for: weekday).capitalized)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(weekday.isWeekend ? .secondary : .primary)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    let locales: [(String, String)] = [
        ("sv", "Swedish (Monday first)"),
        ("en_US", "US English (Sunday first)"),
        ("ja", "Japanese (Sunday first)"),
        ("ar", "Arabic (Saturday first)")
    ]

    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(locales, id: \.0) { identifier, label in
                    let locale = Locale(identifier: identifier)
                    var calendar: Calendar = {
                        var cal = Calendar(identifier: .gregorian)
                        cal.locale = locale
                        return cal
                    }()

                    Text(label)
                        .font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                    VGRCalendarWeekdaysViewV2(calendar: calendar)
                }
            }
            .padding()
        }
        .navigationTitle("VGRCalendarWeekdaysViewV2")
        .navigationBarTitleDisplayMode(.inline)
    }
}
