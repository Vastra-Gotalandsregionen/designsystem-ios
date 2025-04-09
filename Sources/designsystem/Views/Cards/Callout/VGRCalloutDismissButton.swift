import SwiftUI

/// En återanvändbar cirkulär knapp för att stänga vyer eller varningar.
/// Visar en "xmark"-ikon från SF Symbols med en streckad cirkel och anpassad stil.
public struct VGRCalloutDismissButton: View {
    /// Den closure som körs när knappen trycks.
    let dismiss: (() -> Void)
    
    /// Skapar en `DismissButton`.
    /// - Parameter dismiss: En closure som anropas när knappen trycks.
    public init(dismiss: @escaping (() -> Void)) {
        self.dismiss = dismiss
    }
    
    /// - Returns: En stylad cirkulär knapp med ett "x"-symbol.
    public var body: some View {
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
            .accessibilityLabel("") //TODO: - Localize "Stäng"
    }
}

#Preview {
    VGRCalloutDismissButton {
        print("Dismiss")
    }
}
