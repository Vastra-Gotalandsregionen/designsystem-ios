import Foundation
import SwiftUI

// MARK: - Size

/// Storlek på knappen. Påverkar font, padding och ikonens storlek.
/// Alla varianter respekterar samma storleksskala.
public enum VGRButtonV2Size: Equatable, Hashable, Sendable {
    case medium
    case small

    public var font: Font {
        switch self {
            case .medium: return .bodyRegular
            case .small:  return .subheadline
        }
    }

    public var padding: CGFloat {
        switch self {
            case .medium: return .Margins.medium
            case .small:  return .Margins.large
        }
    }

    public var verticalPadding: CGFloat {
        switch self {
            case .medium: return .Margins.small
            case .small:  return .Margins.xtraSmall
        }
    }

    public var iconSize: CGFloat {
        switch self {
            case .medium: return 20
            case .small:  return 14
        }
    }
}
