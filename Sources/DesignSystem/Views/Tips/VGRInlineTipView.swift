import SwiftUI
import TipKit

// MARK: - Preview Tip

private struct PreviewTip: Tip {
    var title: Text { Text("Tips") }
    var message: Text? { Text("This is an example tip message with some helpful guidance.") }
    var image: Image? { Image(systemName: "lightbulb.fill") }
}

// MARK: - VGRInlineTipView

/// Inline tip view embedded in the content flow.
/// Use this for tips that appear within the UI layout, not as popovers.
/// Supports asymmetric corners to visually connect with adjacent UI elements.
public struct VGRInlineTipView<T: Tip>: View {
    let tip: T
    var smallCorner: VGRTipCorner
    var backgroundColor: Color
    var borderColor: Color
    var foregroundColor: Color
    var onDismiss: (() -> Void)?
    var onAppear: (() -> Void)?

    public init(
        tip: T,
        smallCorner: VGRTipCorner = .none,
        backgroundColor: Color = Color.Accent.purpleSurfaceMinimal,
        borderColor: Color = Color.Accent.purple,
        foregroundColor: Color = Color.Accent.purple,
        onDismiss: (() -> Void)? = nil,
        onAppear: (() -> Void)? = nil
    ) {
        self.tip = tip
        self.smallCorner = smallCorner
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.foregroundColor = foregroundColor
        self.onDismiss = onDismiss
        self.onAppear = onAppear
    }

    public var body: some View {
        TipView(tip) { _ in }
            .tipViewStyle(VGRInlineTipViewStyle(
                smallCorner: smallCorner,
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                foregroundColor: foregroundColor,
                onDismiss: onDismiss,
                onAppear: onAppear
            ))
            .tipBackground(Color.clear)
            .tipCornerRadius(0)
    }
}

// MARK: - Previews

#Preview("Default (purple)") {
    VGRInlineTipView(tip: PreviewTip())
        .padding()
        .task {
            try? Tips.resetDatastore()
            try? Tips.configure([.displayFrequency(.immediate)])
        }
}

#Preview("With small corner") {
    VGRInlineTipView(tip: PreviewTip(), smallCorner: .topLeading)
        .padding()
        .task {
            try? Tips.resetDatastore()
            try? Tips.configure([.displayFrequency(.immediate)])
        }
}

#Preview("Custom colors") {
    VStack(spacing: 16) {
        VGRInlineTipView(
            tip: PreviewTip(),
            smallCorner: .topLeading,
            backgroundColor: Color.Primary.blueSurfaceMinimal,
            borderColor: Color.Primary.blue,
            foregroundColor: Color.Primary.blue
        )
        VGRInlineTipView(
            tip: PreviewTip(),
            smallCorner: .bottomTrailing,
            backgroundColor: Color.Accent.greenSurfaceMinimal,
            borderColor: Color.Accent.green,
            foregroundColor: Color.Accent.green
        )
    }
    .padding()
    .task {
        try? Tips.resetDatastore()
        try? Tips.configure([.displayFrequency(.immediate)])
    }
}
