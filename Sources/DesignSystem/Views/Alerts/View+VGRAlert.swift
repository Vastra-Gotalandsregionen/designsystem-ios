import SwiftUI
import UIKit

/// Bridges a ``VGRAlert?`` binding to `UIAlertController` so the alert renders
/// with the iOS 26 HIG anatomy — including the blue primary capsule for
/// buttons created via ``VGRAlertButton/confirm(_:action:)``.
private struct VGRAlertPresenter: UIViewControllerRepresentable {

    @Binding var alert: VGRAlert?

    /// Remembers which alert is on screen, so a re-render never presents the same alert twice
    final class Coordinator {
        var presentedAlertID: UUID?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let coordinator = context.coordinator

        guard let alert else {
            /// The binding was cleared by the owner while the alert was still up, so take it down
            if coordinator.presentedAlertID != nil,
               let presented = uiViewController.presentedViewController as? UIAlertController {
                presented.dismiss(animated: true)
            }
            coordinator.presentedAlertID = nil
            return
        }

        /// A button action may change state that re-renders this presenter before the binding has
        /// been cleared. Presenting once per alert id keeps that render from showing it again.
        guard coordinator.presentedAlertID != alert.id else { return }
        guard uiViewController.presentedViewController == nil else { return }
        coordinator.presentedAlertID = alert.id

        let controller = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert
        )

        var preferred: UIAlertAction?
        for button in alert.buttons {
            let action = UIAlertAction(title: button.title, style: button.style) { _ in
                /// Clear the binding before running the action, so whatever the action does cannot
                /// re-present this alert, and an action that sets a new alert is not wiped out
                coordinator.presentedAlertID = nil
                self.alert = nil
                button.action()
            }
            controller.addAction(action)
            if button.isPreferred {
                preferred = action
            }
        }
        if let preferred {
            controller.preferredAction = preferred
        }

        DispatchQueue.main.async {
            uiViewController.present(controller, animated: true)
        }
    }
}

private extension VGRAlertButton {
    var style: UIAlertAction.Style {
        switch role {
        case .destructive: return .destructive
        case .cancel: return .cancel
        default: break
        }
        if #available(iOS 26.0, *), role == .close {
            return .cancel
        }
        return .default
    }
}

private struct VGRAlertModifier: ViewModifier {

    @Binding var alert: VGRAlert?

    func body(content: Content) -> some View {
        content.background(VGRAlertPresenter(alert: $alert))
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
