import SwiftUI

/// Factory methods for common alert patterns.
///
/// Each method provides sensible defaults that can be overridden:
/// ```swift
/// // Use defaults:
/// alert = .unsavedChanges { dismiss() }
///
/// // Override title and message:
/// alert = .unsavedChanges(
///     title: "Ändringar finns",
///     message: "Vill du fortsätta utan att spara?"
/// ) { dismiss() }
/// ```
public extension VGRAlert {

    /// Presents an "unsaved changes" confirmation with a destructive discard action.
    /// - Parameters:
    ///   - title: Alert title. Defaults to localized "alert.unsaved.title".
    ///   - message: Alert message. Defaults to localized "alert.unsaved.message".
    ///   - onDiscard: Called when the user chooses to discard changes.
    static func unsavedChanges(
        title: String? = nil,
        message: String? = nil,
        onDiscard: @escaping () -> Void
    ) -> VGRAlert {
        VGRAlert(
            title: title ?? "alert.unsaved.title".localizedBundle,
            message: message ?? "alert.unsaved.message".localizedBundle,
            buttons: [
                .destructive("alert.unsaved.discard".localizedBundle, action: onDiscard),
                .cancel()
            ]
        )
    }

    /// Presents a delete confirmation alert for a named item.
    /// - Parameters:
    ///   - name: The name of the item being deleted, shown in the default title.
    ///   - title: Alert title. Defaults to localized "alert.delete.title" with name.
    ///   - message: Alert message. Defaults to localized "alert.delete.message".
    ///   - onDelete: Called when the user confirms deletion.
    static func confirmDelete(
        name: String,
        title: String? = nil,
        message: String? = nil,
        onDelete: @escaping () -> Void
    ) -> VGRAlert {
        VGRAlert(
            title: title ?? "alert.delete.title".localizedBundleFormat(arguments: name),
            message: message ?? "alert.delete.message".localizedBundle,
            buttons: [
                .destructive("alert.delete.confirm".localizedBundle, action: onDelete),
                .cancel()
            ]
        )
    }

    /// Presents an error alert showing the error's localized description.
    /// - Parameters:
    ///   - error: The error to display. Falls back to localized "alert.error.unknown" if nil.
    ///   - title: Alert title. Defaults to localized "alert.error.title".
    static func error(
        _ error: Error?,
        title: String? = nil
    ) -> VGRAlert {
        VGRAlert(
            title: title ?? "alert.error.title".localizedBundle,
            message: error?.localizedDescription ?? "alert.error.unknown".localizedBundle,
            buttons: [.default("OK", action: {})]
        )
    }
}
