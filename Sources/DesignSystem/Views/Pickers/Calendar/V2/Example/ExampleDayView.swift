import SwiftUI

struct ExampleDayView: View, Equatable {

    nonisolated static func == (lhs: ExampleDayView, rhs: ExampleDayView) -> Bool {
        return lhs.index == rhs.index && lhs.selected == rhs.selected && lhs.data == rhs.data
    }
    
    let index: VGRCalendarIndexKey
    let data: ExampleEventData?
    let selected: Bool

    var dayTextColor: Color {
        if selected {
            return .white
        }

        return index.weekday.isWeekend ? .secondary : .primary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(index.day, format: .number)
                .font(.body).fontWeight(.regular)
                .foregroundStyle(dayTextColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 42)
                .background {
                    if data?.isToday == true {
                        if selected {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(.green)
                                .opacity(selected ? 1 : 0)
                                .padding(4)
                        }

                        RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(.green, lineWidth: 2)

                    } else {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.green.opacity(1))
                            .opacity(selected ? 1 : 0)
                    }
                }

            if let events = data?.events, !events.isEmpty {
                VStack(spacing: 2) {
                    ForEach(events) { event in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(event.type.color)
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                    }
                }
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 3))
    }
}

#Preview {
    let index: VGRCalendarIndexKey = VGRCalendarIndexKey(year: 1978, month: 9, day: 23)
    let todayData: ExampleEventData = .init(
        isToday: true,
        events: [.init(type: .family), .init(type: .personal), .init(type: .work)]
    )
    let selected: Bool = false

    NavigationStack {
        ScrollView {
            HStack(alignment: .top, spacing: 2) {
                ExampleDayView(index: index,
                               data: todayData,
                               selected: selected)

                ExampleDayView(index: index,
                               data: nil,
                               selected: true)

                ExampleDayView(index: index,
                               data: todayData,
                               selected: true)
            }
            .padding()
        }
    }
}
