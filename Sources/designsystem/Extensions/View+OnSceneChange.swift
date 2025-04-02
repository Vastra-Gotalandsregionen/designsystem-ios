import SwiftUI
import Foundation

/// A view modifier that observes changes in the scene phase and triggers a callback when it changes.
public struct ScenePhaseModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let onSceneChange: (ScenePhase) -> Void

    /// Modifies the given content by observing scene phase changes.
    /// - Parameter content: The original view content.
    /// - Returns: A modified view that triggers `onSceneChange` when the scene phase changes.
    public func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { oldPhase, newPhase in
                onSceneChange(newPhase)
            }
    }
}

public extension View {
    /// Adds a modifier to observe changes in the scene phase and execute a given action.
    /// - Parameter action: A closure that is called when the scene phase changes.
    /// - Returns: A modified view that reacts to scene phase changes.
    func onSceneChange(_ action: @escaping (ScenePhase) -> Void) -> some View {
        self.modifier(ScenePhaseModifier(onSceneChange: action))
    }
}
