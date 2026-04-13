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
///         .destructive("Ändra") { performSave() },
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
    public let title: LocalizedStringKey
    public let message: LocalizedStringKey?
    public let buttons: [VGRAlertButton]

    public init(
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
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
/// .destructive("Ta bort") { performDelete() }
/// .cancel()                // defaults to "Avbryt"
/// .cancel("Stäng")         // custom label
/// ```
public struct VGRAlertButton: Identifiable {
    public let id = UUID()
    public let title: LocalizedStringKey
    public let role: ButtonRole?
    public let action: () -> Void

    public init(title: LocalizedStringKey, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }

    /// A standard button with no destructive or cancel role.
    public static func `default`(_ title: LocalizedStringKey, action: @escaping () -> Void) -> VGRAlertButton {
        VGRAlertButton(title: title, role: nil, action: action)
    }

    /// A destructive button, typically styled in red by the system.
    public static func destructive(_ title: LocalizedStringKey, action: @escaping () -> Void) -> VGRAlertButton {
        VGRAlertButton(title: title, role: .destructive, action: action)
    }

    /// A cancel button. Defaults to the localized "general.cancel" string.
    public static func cancel(_ title: LocalizedStringKey? = nil) -> VGRAlertButton {
        VGRAlertButton(title: title ?? "\("general.cancel".localizedBundle)", role: .cancel, action: {})
    }
}
