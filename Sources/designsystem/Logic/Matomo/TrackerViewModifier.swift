import SwiftUI

public extension View {
    func track(_ screen: TrackableScreen) -> some View {
        modifier(TrackableScreenViewModifier(trackableScreen: screen))
    }
}

public struct TrackableScreenViewModifier: ViewModifier {
    var trackableScreen: TrackableScreen

    public func body(content: Content) -> some View {
        content
            .onAppear {
                Tracker.shared.trackScreen(trackableScreen)
            }
    }
}

//MARK: - Deprecated

public extension View {
    @available(*, deprecated, message: "Use track(_ screen: TrackableScreen) instead.")
    func track(_ screen: TrackerScreen) -> some View {
        modifier(TrackerViewModifier(trackerScreen: screen))
    }
}

@available(*, deprecated, message: "Do not use this modifier, use the one that accepts a TrackableScreen instead.")
public struct TrackerViewModifier: ViewModifier {
    var trackerScreen: TrackerScreen

    public func body(content: Content) -> some View {
        content
            .onAppear {
                Tracker.shared.trackScreen(trackerScreen)
            }
    }
}

