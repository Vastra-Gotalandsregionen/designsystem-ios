import SwiftUI

// MARK: - Illustration View

/// A reusable illustration component that renders an asset for Callouts.
/// Can be used both inside an SPM package and in host apps thanks to the configurable bundle.
public struct VGRCalloutIllustration: View {
    
    // MARK: Properties
    
    private let assetName: String
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
        bundle: Bundle? = nil
    ) {
        self.assetName = assetName
        self.bundle = bundle ?? .module
    }
    
    // MARK: Body
    
    public var body: some View {
        Image(assetName, bundle: bundle)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .accessibilityHidden(true)
    }
}

// MARK: - Preview

#Preview {
    VGRCalloutIllustration(assetName: "illustration_presenting")
}
