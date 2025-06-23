import SwiftUI

public struct TrackerViewModifier: ViewModifier {
    var trackerScreen: TrackerScreen

    public func body(content: Content) -> some View {
        content
            .onAppear {
                Tracker.shared.trackScreen(trackerScreen)
            }
    }
}

public extension View {
    func track(_ screen: TrackerScreen) -> some View {
        modifier(TrackerViewModifier(trackerScreen: screen))
    }
}
