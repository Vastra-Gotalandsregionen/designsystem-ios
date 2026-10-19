import SwiftUI

public extension View {
    /// Tracks `screen` as a view when this view appears. See `Tracker.trackScreen(_:note:)`.
    ///
    /// - Parameters:
    ///   - screen: The screen to track, conforming to `TrackableScreen`.
    ///   - note: An optional additional note to include with the screen tracking, e.g. where the
    ///     user came from or which variant of the screen is shown.
    func track(_ screen: TrackableScreen, note: String? = nil) -> some View {
        modifier(TrackableScreenViewModifier(trackableScreen: screen, note: note))
    }
}

public struct TrackableScreenViewModifier: ViewModifier {
    var trackableScreen: TrackableScreen
    var note: String?

    public func body(content: Content) -> some View {
        content
            .onAppear {
                Tracker.shared.trackScreen(trackableScreen, note: note)
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

