import SwiftUI
import UIKit

/// Bridges a ``VGRAlert?`` binding to `UIAlertController` so the alert renders
/// with the iOS 26 HIG anatomy — including the blue primary capsule for
/// buttons created via ``VGRAlertButton/confirm(_:action:)``.
private struct VGRAlertPresenter: UIViewControllerRepresentable {

    @Binding var alert: VGRAlert?

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let alert else { return }
        guard uiViewController.presentedViewController == nil else { return }

        let controller = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert
        )

        var preferred: UIAlertAction?
        for button in alert.buttons {
            let action = UIAlertAction(title: button.title, style: button.style) { _ in
                button.action()
                self.alert = nil
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
