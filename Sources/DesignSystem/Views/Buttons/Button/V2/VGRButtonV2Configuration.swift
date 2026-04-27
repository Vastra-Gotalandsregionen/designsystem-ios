import SwiftUI

// MARK: - Configuration

/// Datan som skickas till en variant när den ska rendera knappen.
/// Icon är typraderad (`AnyView`) så alla varianter kan ta emot samma
/// configuration oavsett vilken vy anroparen har skickat in.
public struct VGRButtonV2Configuration {
    public let label: String
    public let icon: AnyView
    public let isEnabled: Bool
    public let fullWidth: Bool
    public let size: VGRButtonV2Size
    public let accessibilityHint: String
    public let action: () -> Void

    public init(
        label: String,
        icon: AnyView,
        isEnabled: Bool,
        fullWidth: Bool = true,
        size: VGRButtonV2Size = .medium,
        accessibilityHint: String,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.size = size
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
}
