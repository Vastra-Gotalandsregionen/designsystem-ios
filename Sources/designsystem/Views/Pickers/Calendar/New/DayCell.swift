import Foundation
import SwiftUI

struct NewDayCell: View {
    @ScaledMetric private var height: CGFloat = 42
    @ScaledMetric private var circleSize: CGFloat = 32
    @ScaledMetric private var attackIconSize: CGFloat = 9

    let date: CalendarIndexKey
    let data: MyCalendarData?
    let current: Bool
    let selected: Bool

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
            }

            if current {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color.Custom.healthcare20, lineWidth: 2)
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
                                .frame(width: attackIconSize+1, height: attackIconSize+1)

                            Image(systemName: "heart.fill")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: attackIconSize-2, height: attackIconSize-2)
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
    let dataEvent: MyCalendarData = .init(hasEvent: true, isRecurring: false)

    NavigationStack {
        ScrollView {
            VStack(spacing: 8) {
                HStack(spacing: 2) {
                    NewDayCell(date: .init(year: 2021, month: 1, day: 1), data: dataEvent, current: false, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 2), data: nil, current: false, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 3), data: nil, current: false, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 4), data: nil, current: false, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 5), data: nil, current: false, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 6), data: nil, current: false, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 7), data: nil, current: false, selected: false)
                }
                HStack(spacing: 2) {
                    NewDayCell(date: .init(year: 2021, month: 1, day: 1), data: dataEvent, current: true, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 2), data: nil, current: true, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 3), data: nil, current: true, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 4), data: nil, current: true, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 5), data: nil, current: true, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 6), data: nil, current: true, selected: false)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 7), data: nil, current: true, selected: false)
                }
                HStack(spacing: 2) {
                    NewDayCell(date: .init(year: 2021, month: 1, day: 1), data: dataEvent, current: false, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 2), data: nil, current: false, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 3), data: nil, current: false, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 4), data: nil, current: false, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 5), data: nil, current: false, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 6), data: nil, current: false, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 7), data: nil, current: false, selected: true)
                }
                HStack(spacing: 2) {
                    NewDayCell(date: .init(year: 2021, month: 1, day: 1), data: dataEvent, current: true, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 2), data: nil, current: true, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 3), data: nil, current: true, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 4), data: nil, current: true, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 5), data: nil, current: true, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 6), data: nil, current: true, selected: true)
                    NewDayCell(date: .init(year: 2021, month: 1, day: 7), data: nil, current: true, selected: true)
                }
            }
            .padding(12)
        }
    }
}
