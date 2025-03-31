import SwiftUI

// Represents predefined size categories for the illustration.
public enum VGRIconSizeCategory {
    case small
    case regular
    case large
    
    /// Returns the corresponding CGFloat value for the size.
    var value: CGFloat {
        switch self {
        case .small: return 16
        case .regular: return 25
        case .large: return 32
        }
    }
}
    
public struct VGRIcon: View {
    
    private let assetName: String
    private let size: VGRIconSizeCategory
    private let bundle: Bundle
    
    public init(
        assetName: String,
        size: VGRIconSizeCategory = .regular,
        bundle: Bundle? = nil
    ) {
        self.assetName = assetName
        self.size = size
        self.bundle = bundle ?? .module
    }
    
    public var body: some View {
        Image(assetName, bundle: bundle)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size.value, height: size.value)
            .accessibilityHidden(true)
    }
}

#Preview {
    VGRIcon(assetName: "listsearch")
}
