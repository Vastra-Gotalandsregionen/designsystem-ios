import SwiftUI

/// Represents predefined size categories for an icon, mapped to fixed CGFloat values.
public enum VGRIconSizeCategory {
    case small
    case regular
    case large
    
    /// Returns the icon size in points as a CGFloat.
    var value: CGFloat {
        switch self {
        case .small: return 16
        case .regular: return 25
        case .large: return 32
        }
    }
}

/// Defines the source type for the icon, either from asset catalog or SF Symbols.
public enum VGRIconSource {
    case asset(name: String, bundle: Bundle)
    case system(name: String)
}

/// A reusable icon view that supports both asset-based and SF Symbol-based images, with predefined size options.
public struct VGRIcon: View {
    
    private let source: VGRIconSource
    private let size: VGRIconSizeCategory

    /// Creates a `VGRIcon` with the given source and size.
    /// - Parameters:
    ///   - source: The source of the icon (asset or system).
    ///   - size: The size category of the icon (default is `.regular`).
    public init(source: VGRIconSource, size: VGRIconSizeCategory = .regular) {
        self.source = source
        self.size = size
    }

    public var body: some View {
        image
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size.value, height: size.value)
            .accessibilityHidden(true)
    }

    /// Returns the appropriate `Image` based on the icon's source.
    private var image: Image {
        switch source {
        case .asset(let name, let bundle):
            return Image(name, bundle: bundle)
        case .system(let name):
            return Image(systemName: name)
        }
    }
}

public extension VGRIcon {
    /// Convenience initializer for asset-based icons.
    /// - Parameters:
    ///   - name: The name of the image asset.
    ///   - size: The size category of the icon.
    ///   - bundle: The bundle where the asset is located (default is `.module`).
    init(asset name: String, size: VGRIconSizeCategory = .regular, bundle: Bundle? = nil) {
        self.init(source: .asset(name: name, bundle: bundle ?? .module), size: size)
    }

    /// Convenience initializer for system (SF Symbol) icons.
    /// - Parameters:
    ///   - name: The system symbol name.
    ///   - size: The size category of the icon.
    init(system name: String, size: VGRIconSizeCategory = .regular) {
        self.init(source: .system(name: name), size: size)
    }
}

/// Preview showcasing `VGRIcon` with various sources and sizes.
#Preview {
    HStack (spacing: 16) {
        
        VGRIcon(asset: "listsearch")
                
        VGRIcon(source: .asset(name: "chatbubble", bundle: .module))
        
        VGRIcon(system: "heart.fill", size: .small)
        
        VGRIcon(system: "heart.fill")
        
        VGRIcon(system: "heart.fill", size: .large)

    }
}
