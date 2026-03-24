import SwiftUI

struct ExampleWeekView: View {

    var calendar: Calendar

    @State var viewModel: ExampleViewModel
    @State var scrollPosition: ScrollPosition

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        self._viewModel = State(initialValue: ExampleViewModel(calendar: calendar))
        self._scrollPosition = State(initialValue: ScrollPosition(id: VGRCalendarIndexKey(from: Date(), using: calendar).weekID))
    }

    var body: some View {
        VStack(spacing: 0) {
            VGRCalendarWeekViewV2(
                calendar: calendar,
                interval: viewModel.calendarDateInterval,
                data: $viewModel.data,
                selectedDate: $viewModel.selectedDate,
                scrollPosition: $scrollPosition
            ) { index, data, selected in
                ExampleDayView(index: index, data: data, selected: selected)
                    .equatable()
                    .onTapGesture { viewModel.selectedDate = index }

            }
            .background(.gray.opacity(0.2))

            ScrollView {
                if let entry = viewModel.data[viewModel.selectedDate], !entry.events.isEmpty {
                    VStack(spacing: 16) {
                        ForEach(entry.events) { event in
                            Text(event.type.rawValue.capitalized)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(event.type.color.opacity(0.1))
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    ContentUnavailableView("No events", systemImage: "calendar")
                }
            }
            .contentMargins(.top, 16)
            .background(Color.gray.opacity(0.1))
        }
        .navigationTitle("ExampleWeekView")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    scrollPosition.scrollTo(id: VGRCalendarIndexKey(from: Date(), using: calendar).weekID)
                    viewModel.selectedDate = VGRCalendarIndexKey(from: Date(), using: calendar)
                } label: {
                    Text("Idag")
                }
            }
        }
        .task {
            await viewModel.loadEvents()
        }
    }
}

#Preview {
    NavigationStack {
        ExampleWeekView()
    }
}
