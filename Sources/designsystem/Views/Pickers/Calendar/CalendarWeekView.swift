import SwiftUI

struct CalendarWeekView: View {
    @Binding var selectedIndex: CalendarIndexKey

    var body: some View {
        VStack {
            Text("Hello, World!")
            Text(selectedIndex.id)
        }
        .navigationTitle(selectedIndex.id)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var selectedIndex: CalendarIndexKey = CalendarIndexKey(from: .now)

    NavigationStack {
        CalendarWeekView(selectedIndex: $selectedIndex)
    }
}
