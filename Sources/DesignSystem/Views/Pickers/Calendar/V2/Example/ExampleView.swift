import SwiftUI

struct ExampleView: View {

    var calendar: Calendar

    @State var viewModel: ExampleViewModel
    @State var monthScrollPosition: ScrollPosition
    @State var weekScrollPosition: ScrollPosition = .init(idType: String.self)
    @State var showWeekView: Bool = false

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        self._viewModel = State(initialValue: ExampleViewModel(calendar: calendar))
        self._monthScrollPosition = State(initialValue: ScrollPosition(id: VGRCalendarIndexKey(calendar, Date()).monthID, anchor: .top))
    }

    var body: some View {
        NavigationStack {
            VGRCalendarViewV2(calendar: calendar,
                              interval: viewModel.calendarDateInterval,
                              data: $viewModel.data,
                              selectedDate: $viewModel.selectedDate,
                              scrollPosition: $monthScrollPosition
            ) { month, data in

                /// Month header view
                ExampleMonthHeaderView(calendar: calendar,
                                       index: month,
                                       data: data)

            } dayContent: { index, data, _ in

                /// Dayview for the month view
                ExampleDayView(index: index,
                               data: data,
                               selected: false)
                .equatable()
                .onTapGesture {
                    /// Set selected date
                    viewModel.selectedDate = index
                    showWeekView = true
                }
            }
            .navigationTitle("ExampleView")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: showWeekView) { _, isShowingWeekView in
                /// If we're returning from the weekView, ensure the MonthView is scrolled
                /// into the currently selected date
                if !isShowingWeekView {
                    monthScrollPosition.scrollTo(id: viewModel.selectedDate.monthID)
                } else {
                    weekScrollPosition.scrollTo(id: viewModel.selectedDate.weekID)
                }
            }
            .navigationDestination(isPresented: $showWeekView) {
                VStack(spacing: 0) {
                    VGRCalendarWeekViewV2(
                        calendar: calendar,
                        interval: viewModel.calendarDateInterval,
                        data: $viewModel.data,
                        selectedDate: $viewModel.selectedDate,
                        scrollPosition: $weekScrollPosition
                    ) { index, data, selected in
                        ExampleDayView(index: index,
                                       data: data,
                                       selected: selected)
                        .equatable()
                        .onTapGesture {
                            viewModel.selectedDate = index
                        }
                    }

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
                .toolbar {
                    todayButton(placement: .topBarLeading, isWeek: true)
                    randomizeButton(placement: .topBarTrailing)
                }
            }
            .toolbar {
                todayButton(placement: .topBarLeading)

                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.randomizeDateInterval()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            monthScrollPosition.scrollTo(id: viewModel.selectedDate.monthID)
                        }
                    } label: {
                        Image(systemName: "dice")
                    }
                }
            }
            .task {
                guard viewModel.data.isEmpty else { return }
                await viewModel.loadEvents()
            }

        }
    }

    func todayButton(placement: ToolbarItemPlacement, isWeek: Bool = false) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button {
                withAnimation {
                    viewModel.selectedDate = .init(calendar, Date())
                    if isWeek {
                        weekScrollPosition.scrollTo(id: viewModel.selectedDate.weekID)
                    } else {
                        monthScrollPosition.scrollTo(id: viewModel.selectedDate.monthID)
                    }
                }
            } label: {
                Text("Idag")
            }
        }
    }

    func randomizeButton(placement: ToolbarItemPlacement) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button {
                Task {
                    await viewModel.updateEvents()
                }
            } label: {
                Text("Random")
            }
        }
    }
}

#Preview {
    let locale = Locale(identifier: "sv")
    var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = locale
        return cal
    }()

    ExampleView(calendar: calendar)
}
