import SwiftUI
import TipKit

// MARK: - VGRTipCorner

/// Corner to apply smaller radius for visual connection with adjacent UI
public enum VGRTipCorner {
    case none
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

// MARK: - VGRInlineTipViewStyle

/// Custom TipViewStyle for inline tips with configurable colors and optional asymmetric corners.
/// Use this for tips embedded in the content flow, not for popover-style tips.
public struct VGRInlineTipViewStyle: TipViewStyle {
    public var smallCorner: VGRTipCorner
    public var backgroundColor: Color
    public var borderColor: Color
    public var foregroundColor: Color
    public var onDismiss: (() -> Void)?
    public var onAppear: (() -> Void)?

    private let standardRadius: CGFloat = 26
    private let smallRadius: CGFloat = 2

    public init(
        smallCorner: VGRTipCorner = .none,
        backgroundColor: Color = Color.Accent.purpleSurfaceMinimal,
        borderColor: Color = Color.Accent.purple,
        foregroundColor: Color = Color.Accent.purple,
        onDismiss: (() -> Void)? = nil,
        onAppear: (() -> Void)? = nil
    ) {
        self.smallCorner = smallCorner
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.foregroundColor = foregroundColor
        self.onDismiss = onDismiss
        self.onAppear = onAppear
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: smallCorner == .topLeading ? smallRadius : standardRadius,
            bottomLeadingRadius: smallCorner == .bottomLeading ? smallRadius : standardRadius,
            bottomTrailingRadius: smallCorner == .bottomTrailing ? smallRadius : standardRadius,
            topTrailingRadius: smallCorner == .topTrailing ? smallRadius : standardRadius
        )
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            configuration.image?
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                configuration.title
                    .font(.body)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                configuration.message?
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilitySortPriority(2)

            Button {
                onDismiss?()
            } label: {
                Image(systemName: "xmark")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(foregroundColor)
                    .frame(width: 16, height: 16)
            }
            .accessibilityLabel("tips.close.a11y".localizedBundle)
            .accessibilitySortPriority(1)
        }
        .padding(16)
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .clipShape(shape)
        .overlay(shape.strokeBorder(borderColor, lineWidth: 2))
        .onAppear {
            onAppear?()
        }
    }
}
