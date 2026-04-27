import SwiftUI

/// An alert configuration that pairs a title, optional message, and buttons with their actions.
///
/// Use factory methods from ``VGRAlert+Common`` for common patterns, or create custom alerts inline:
/// ```swift
/// // In your viewmodel:
/// alert = VGRAlert(
///     title: "Ändra schema?",
///     message: "Detta påverkar alla doser.",
///     buttons: [
///         .confirm("Ändra") { performSave() },
///         .cancel()
///     ]
/// )
/// ```
///
/// Present it in your view with the `.vgrAlert(item:)` modifier:
/// ```swift
/// .vgrAlert(item: $viewModel.alert)
/// ```
public struct VGRAlert: Identifiable {
    public let id = UUID()
    public let title: String
    public let message: String?
    public let buttons: [VGRAlertButton]

    public init(
        title: String,
        message: String? = nil,
        buttons: [VGRAlertButton]
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
}

/// A button displayed within a ``VGRAlert``.
///
/// Use the factory methods for convenience:
/// ```swift
/// .default("OK") { handleOK() }
/// .confirm("Spara") { save() }             // blue primary capsule on iOS 26
/// .destructive("Ta bort") { delete() }
/// .close("Stäng") { dismiss() }            // iOS 26 close role
/// .cancel()                                // defaults to "Avbryt"
/// .cancel("Stäng")                         // custom label
/// ```
public struct VGRAlertButton: Identifiable {
    public let id = UUID()
    public let title: String
    public let role: ButtonRole?
    public let isPreferred: Bool
    public let action: () -> Void

    public init(
        title: String,
        role: ButtonRole? = nil,
        isPreferred: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.role = role
        self.isPreferred = isPreferred
        self.action = action
    }

    /// A standard button with no destructive or cancel role.
    /// Pass `isPreferred: true` to mark it as the preferred action.
    public static func `default`(
        _ title: String,
        isPreferred: Bool = false,
        action: @escaping () -> Void
    ) -> VGRAlertButton {
        VGRAlertButton(title: title, role: nil, isPreferred: isPreferred, action: action)
    }

    /// A confirm button. Rendered as the blue primary capsule on iOS 26.
    public static func confirm(_ title: String, action: @escaping () -> Void) -> VGRAlertButton {
        if #available(iOS 26.0, *) {
            VGRAlertButton(title: title, role: .confirm, isPreferred: true, action: action)
        } else {
            VGRAlertButton(title: title, role: nil, isPreferred: true, action: action)
        }
    }

    /// A close button (iOS 26+ with fallback to cancel role).
    /// Pass `isPreferred: true` to mark it as the preferred action (rare).
    public static func close(
        _ title: String,
        isPreferred: Bool = false,
        action: @escaping () -> Void
    ) -> VGRAlertButton {
        if #available(iOS 26.0, *) {
            VGRAlertButton(title: title, role: .close, isPreferred: isPreferred, action: action)
        } else {
            VGRAlertButton(title: title, role: nil, isPreferred: isPreferred, action: action)
        }
    }

    /// A destructive button, typically styled in red by the system.
    /// Pass `isPreferred: true` to mark it as the preferred action (use sparingly — see HIG).
    public static func destructive(
        _ title: String,
        isPreferred: Bool = false,
        action: @escaping () -> Void
    ) -> VGRAlertButton {
        VGRAlertButton(title: title, role: .destructive, isPreferred: isPreferred, action: action)
    }

    /// A cancel button. Defaults to the localized "general.cancel" string.
    public static func cancel(_ title: String? = nil) -> VGRAlertButton {
        VGRAlertButton(title: title ?? "general.cancel".localizedBundle, role: .cancel, action: {})
    }
}
