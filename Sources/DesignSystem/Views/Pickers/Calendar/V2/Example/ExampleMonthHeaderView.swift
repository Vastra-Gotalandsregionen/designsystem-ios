import SwiftUI

struct ExampleMonthHeaderView: View {
    let calendar: Calendar
    let index: VGRCalendarIndexKey
    let data: [ExampleEventData]

    private var eventCount: Int {
        data.reduce(0) { $0 + $1.events.count }
    }

    var body: some View {
        HStack(alignment: .center) {
            Text(index.monthName(calendar))
                .font(.title2).fontWeight(.bold)

            if eventCount > 0 {
                Text(eventCount, format: .number)
                    .font(.caption).fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ExampleMonthHeaderView(
        calendar: .current,
        index: VGRCalendarIndexKey(year: 2026, month: 2, day: 1),
        data: [
            ExampleEventData(events: [
                ExampleEvent(type: .work),
                ExampleEvent(type: .personal)
            ])
        ]
    )
    .padding()
}
