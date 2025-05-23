import Foundation
import SwiftUI

/*
    OnDayChange modifier
    This modifier adds the convenience of having a single modifier that is called
    whenever there are significant date-changes.
*/
struct OnDayChangeModifier: ViewModifier {
    let action: () -> Void

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
    /// onDayChange is triggered whenever there is a signficant change in the devices date
    func onDayChange(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnDayChangeModifier(action: action))
    }
}
