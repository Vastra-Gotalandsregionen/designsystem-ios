import Foundation
import SwiftUI

struct ExampleCalendarData: Hashable {
    let hasEvent: Bool
    let isRecurring: Bool
}

struct ExampleDayCell: View {
    @ScaledMetric private var height: CGFloat = 42
    @ScaledMetric private var circleSize: CGFloat = 32
    @ScaledMetric private var iconSize: CGFloat = 9

    let date: CalendarIndexKey
    let data: ExampleCalendarData?
    var current: Bool = false
    var selected: Bool = false

    private var textColor: Color {
        if let data, data.hasEvent {
            return selected ? Color.Neutral.textFixed : Color.Neutral.textFixed
        }
        return selected ? Color.Neutral.textInvertedFixed : Color.Neutral.text
    }

    var body: some View {
        ZStack {
            if selected {
                RoundedRectangle(cornerRadius: current ? 2 : 5)
                    .fill(Color.Custom.healthcare20)
                    .padding(current ? 4 : 0)
                    .allowsHitTesting(false)
            }

            if current {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color.Custom.healthcare20, lineWidth: 2)
                    .allowsHitTesting(false)
            }

            if let data, data.hasEvent {
                Circle()
                    .fill(Color.Accent.purpleGraphic)
                    .frame(maxWidth: circleSize, maxHeight: circleSize)
                    .overlay(alignment: .topTrailing) {
                        ZStack {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: iconSize+1, height: iconSize+1)

                            Image(systemName: "heart.fill")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: iconSize-2, height: iconSize-2)
                        }
                    }
            }

            Text(String(describing: date.day))
                .font(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(textColor)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(minHeight: height)
        .contentShape(Rectangle())
    }
}

#Preview {
    let dataEvent: ExampleCalendarData = .init(hasEvent: true, isRecurring: false)

    NavigationStack {
        ScrollView {
            VStack(spacing: 8) {
                HStack(spacing: 2) {
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 1), data: dataEvent, current: false, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 2), data: nil, current: false, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 3), data: nil, current: false, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 4), data: nil, current: false, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 5), data: nil, current: false, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 6), data: nil, current: false, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 7), data: nil, current: false, selected: false)
                }
                HStack(spacing: 2) {
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 1), data: dataEvent, current: true, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 2), data: nil, current: true, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 3), data: nil, current: true, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 4), data: nil, current: true, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 5), data: nil, current: true, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 6), data: nil, current: true, selected: false)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 7), data: nil, current: true, selected: false)
                }
                HStack(spacing: 2) {
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 1), data: dataEvent, current: false, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 2), data: nil, current: false, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 3), data: nil, current: false, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 4), data: nil, current: false, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 5), data: nil, current: false, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 6), data: nil, current: false, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 7), data: nil, current: false, selected: true)
                }
                HStack(spacing: 2) {
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 1), data: dataEvent, current: true, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 2), data: nil, current: true, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 3), data: nil, current: true, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 4), data: nil, current: true, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 5), data: nil, current: true, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 6), data: nil, current: true, selected: true)
                    ExampleDayCell(date: .init(year: 2021, month: 1, day: 7), data: nil, current: true, selected: true)
                }
            }
            .padding(12)
        }
    }
}
