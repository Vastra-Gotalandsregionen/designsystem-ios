import SwiftUI
import Foundation

/// A view modifier that listens for device rotation changes and executes
/// a provided action when the device orientation changes.
public struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    /// Modifies the given content view to trigger an action when the device rotates.
    /// - Parameter content: The original view content.
    /// - Returns: A modified view that listens for orientation change notifications.
    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

public extension View {
    /// Attaches an action to be performed when the device orientation changes.
    /// - Parameter action: A closure that receives the new `UIDeviceOrientation`.
    /// - Returns: A modified view that responds to device rotation events.
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
