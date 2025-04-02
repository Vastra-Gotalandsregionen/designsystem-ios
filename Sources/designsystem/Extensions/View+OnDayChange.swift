import SwiftUI
import Foundation

/// A view modifier that listens for the `NSCalendarDayChanged` notification
/// and executes a provided action when the day changes.
struct OnDayChangeModifier: ViewModifier {
    let action: () -> Void

    /// Modifies the given content view to trigger an action when the day changes.
    /// - Parameter content: The original view content.
    /// - Returns: A modified view that listens for day change notifications.
    func body(content: Content) -> some View {
        content
            .onReceive(
                NotificationCenter.default.publisher(for: Notification.Name.NSCalendarDayChanged)
                    .receive(on: DispatchQueue.main)
            ) { _ in
                action()
            }
    }
}

public extension View {
    /// Attaches an action to be performed when the device's calendar day changes.
    /// - Parameter action: The closure to execute when the day changes.
    /// - Returns: A modified view that responds to day change events.
    func onDayChange(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnDayChangeModifier(action: action))
    }
}
