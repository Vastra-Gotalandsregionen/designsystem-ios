import Foundation
import SwiftUI

/// An enumeration representing the device's orientation.
/// Can be either portrait or landscape.
enum DeviceOrientation {
    /// The device is in portrait mode.
    case portrait
    /// The device is in landscape mode.
    case landscape
}

/// A SwiftUI view modifier that observes changes in the device's orientation.
/// Reads the size of the modified view and determines orientation based on width and height.
struct OrientationChangeModifier: ViewModifier {
    /// The current orientation of the device.
    @State private var currentOrientation: DeviceOrientation = .portrait

    /// A closure called when the orientation changes.
    let onChange: (DeviceOrientation) -> Void

    /// Observes the size of the underlying view and updates the orientation.
    ///
    /// The size is read with `onGeometryChange`, which leaves layout untouched. Wrapping the
    /// content in a `GeometryReader` instead would hand it the modifier's own greedy size, and
    /// collapse any view that is offered no size of its own — such as one inside a scroll view.
    /// - Parameter content: The underlying view being modified.
    /// - Returns: A view that reacts to orientation changes.
    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                updateOrientation(size: newSize)
            }
    }

    /// Updates the current orientation based on the given size.
    /// If the orientation changes, the `onChange` closure is called.
    /// - Parameter size: The current size of the view.
    private func updateOrientation(size: CGSize) {
        let newOrientation: DeviceOrientation = size.width > size.height ? .landscape : .portrait
        if newOrientation != currentOrientation {
            currentOrientation = newOrientation
            onChange(newOrientation)
        }
    }
}

/// An extension for `View` that adds a method to react to orientation changes.
extension View {
    /// Adds a modifier that calls a closure when the device's orientation changes.
    /// - Parameter action: A closure that receives the new orientation.
    /// - Returns: A view that reacts to orientation changes.
    func onOrientationChange(_ action: @escaping (DeviceOrientation) -> Void) -> some View {
        self.modifier(OrientationChangeModifier(onChange: action))
    }
}
