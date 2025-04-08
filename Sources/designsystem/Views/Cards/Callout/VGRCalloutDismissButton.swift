import SwiftUI

/// A reusable circular button for dismissing views or alerts.
/// Displays an "xmark" SF Symbol with a stroked circle outline and custom styling.
public struct VGRCalloutDismissButton: View {
    /// The optional closure to execute when the button is tapped.
    let dismiss: (() -> Void)?
    
    /// Creates a `DismissButton`.
    /// - Parameter dismiss: An optional closure called when the button is tapped.
    public init(dismiss: (() -> Void)?) {
        self.dismiss = dismiss
    }
    
    /// Conditionally renders the dismiss button if a closure is provided.
    /// - Returns: A styled circular button with an "x" symbol.
    public var body: some View {
        if let dismiss {
            Button(action: dismiss) {
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "xmark")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(Color.Primary.action)
            }
        }
    }
}

#Preview {
    VGRCalloutDismissButton {
        print("Dismiss")
    }
}
