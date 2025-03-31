import SwiftUI

// TODO: - Kolla med UX om detta är nödvändigt dunno (size cat)
// TODO: - Lottie?

// MARK: - Size Category Enum

/// Represents predefined size categories for the illustration.
public enum VGRIllustrationSizeCategory {
    case small
    case regular
    case large
    
    /// Returns the corresponding CGFloat value for the size.
    var value: CGFloat {
        switch self {
        case .small: return 50
        case .regular: return 100
        case .large: return 150
        }
    }
}

// MARK: - VGRIllustration View

/// A reusable illustration component that renders an asset with fixed size options.
/// Can be used both inside an SPM package and in host apps thanks to the configurable bundle.
public struct VGRIllustration: View {
    
    // MARK: Properties
    
    private let assetName: String
    private let size: VGRIllustrationSizeCategory
    private let bundle: Bundle
    
    // MARK: Init
    
    /// Initializes a new VGRIllustration.
    ///
    /// - Parameters:
    ///   - assetName: The name of the image asset to render.
    ///   - size: The desired size category. Defaults to `.regular`.
    ///   - bundle: The bundle to load the image from. Defaults to `.module` (for SPM).
    public init(
        assetName: String,
        size: VGRIllustrationSizeCategory = .regular,
        bundle: Bundle? = nil
    ) {
        self.assetName = assetName
        self.size = size
        self.bundle = bundle ?? .module
    }
    
    // MARK: Body
    
    public var body: some View {
        Image(assetName, bundle: bundle)
            .resizable()
            .scaledToFit()
            .frame(width: size.value, height: size.value)
            .accessibilityHidden(true)
    }
}

// MARK: - Preview

#Preview {
    VGRIllustration(assetName: "illustration_presenting")
}
