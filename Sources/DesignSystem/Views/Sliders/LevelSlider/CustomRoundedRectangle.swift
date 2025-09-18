import SwiftUI

public struct CustomRoundedRect: Shape {
    public var topLeadingRadius: CGFloat
        public var bottomLeadingRadius: CGFloat
        public var bottomTrailingRadius: CGFloat
        public var topTrailingRadius: CGFloat
        public var strokeWidth: CGFloat

        public init(
            topLeadingRadius: CGFloat = 0,
            bottomLeadingRadius: CGFloat = 0,
            bottomTrailingRadius: CGFloat = 0,
            topTrailingRadius: CGFloat = 0,
            strokeWidth: CGFloat = 0
        ) {
            self.topLeadingRadius = topLeadingRadius
            self.bottomLeadingRadius = bottomLeadingRadius
            self.bottomTrailingRadius = bottomTrailingRadius
            self.topTrailingRadius = topTrailingRadius
            self.strokeWidth = strokeWidth
        }

    public func path(in rect: CGRect) -> Path {

        /// Adjust the rect to account for stroke width
        let insetRect = rect.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2)

        /// Constrain radii to ensure it fits within the inset rect's bounds
        let maxRadius = min(insetRect.width, insetRect.height) / 2
        
        let topLeading = min(topLeadingRadius, maxRadius)
        let topTrailing = min(topTrailingRadius, maxRadius)
        let bottomLeading = min(bottomLeadingRadius, maxRadius)
        let bottomTrailing = min(bottomTrailingRadius, maxRadius)

        var path = Path()

        /// Start at the top left, accounting for the top leading radius
        path.move(to: CGPoint(x: insetRect.minX + topLeading, y: insetRect.minY))

        /// Top edge
        path.addLine(to: CGPoint(x: insetRect.maxX - topTrailing, y: insetRect.minY))

        /// Top right corner (top trailing radius)
        path.addArc(center: CGPoint(x: insetRect.maxX - topTrailing, y: insetRect.minY + topTrailing),
                    radius: topTrailing,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)

        /// Right edge
        path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY - bottomTrailing))

        /// Bottom right corner (bottom trailing radius)
        path.addArc(center: CGPoint(x: insetRect.maxX - bottomTrailing, y: insetRect.maxY - bottomTrailing),
                    radius: bottomTrailing,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        // Bottom edge
        path.addLine(to: CGPoint(x: insetRect.minX + bottomLeading, y: insetRect.maxY))

        /// Bottom left corner (bottom leading radius)
        path.addArc(center: CGPoint(x: insetRect.minX + bottomLeading, y: insetRect.maxY - bottomLeading),
                    radius: bottomLeading,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)

        /// Left edge
        path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.minY + topLeading))

        /// Top left corner (top leading radius)
        path.addArc(center: CGPoint(x: insetRect.minX + topLeading, y: insetRect.minY + topLeading),
                    radius: topLeading,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)

        return path
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            CustomRoundedRect(topLeadingRadius: 4,
                              bottomLeadingRadius: 4,
                              bottomTrailingRadius: 4,
                              topTrailingRadius: 4)
                .fill(Color.red)
                .frame(width: 50, height: 44)

            CustomRoundedRect(topLeadingRadius: 50,
                              bottomLeadingRadius: 50,
                              bottomTrailingRadius: 4,
                              topTrailingRadius: 4,
                              strokeWidth: 2)
            .stroke(Color.black, lineWidth: 2)
            .frame(width: 50, height: 44)

        }

    }
}
