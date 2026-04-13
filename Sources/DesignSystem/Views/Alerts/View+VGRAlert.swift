import SwiftUI

/// Bridges a ``VGRAlert?`` binding to SwiftUI's `isPresented`-based alert API.
private struct VGRAlertModifier: ViewModifier {

    @Binding var alert: VGRAlert?

    func body(content: Content) -> some View {
        let isPresented = Binding(
            get: { alert != nil },
            set: { if !$0 { alert = nil } }
        )

        content.alert(
            alert?.title ?? "",
            isPresented: isPresented,
            presenting: alert,
            actions: { presented in
                ForEach(presented.buttons) { button in
                    Button(role: button.role, action: button.action) {
                        Text(button.title)
                    }
                }
            },
            message: { presented in
                if let message = presented.message {
                    Text(message)
                }
            }
        )
    }
}

public extension View {

    /// Presents a ``VGRAlert`` when the binding is non-nil.
    ///
    /// ```swift
    /// // In your viewmodel:
    /// var alert: VGRAlert? = nil
    ///
    /// // In your view:
    /// .vgrAlert(item: $viewModel.alert)
    /// ```
    func vgrAlert(item: Binding<VGRAlert?>) -> some View {
        self.modifier(VGRAlertModifier(alert: item))
    }
}
