import SwiftUI

public struct VGRShape<Content: View>: View {
    let content: Content
    var backgroundColor: Color = Color.Primary.blueSurfaceMinimal
    var bend: [Alignment]
    var radius: CGFloat = 40

    public init(bend: [Alignment] = [.topLeading],
         backgroundColor: Color? = nil,
         radius: CGFloat = 40,
         @ViewBuilder _ content: () -> Content) {

        self.bend = bend
        self.content = content()
        self.radius = radius
        if let bg = backgroundColor {
            self.backgroundColor = bg
        }

    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(backgroundColor)
        .clipShape(
            .rect(
                topLeadingRadius: bend.contains(.topLeading) ? radius : 0,
                bottomLeadingRadius: bend.contains(.bottomLeading) ? radius : 0,
                bottomTrailingRadius: bend.contains(.bottomTrailing) ? radius : 0,
                topTrailingRadius: bend.contains(.topTrailing) ? radius : 0
            )
        )
    }
}

#Preview {
    let alignments: [Alignment] = [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing]

    return ScrollView {
        VStack(spacing: 16) {
            ForEach(Array(zip(alignments.indices, alignments)), id: \.0) { index, item in
                VGRShape(bend: [item]) {
                    Text("Hello, world domination!")
                        .padding(.vertical, 16)
                }
            }
        }
        .padding(16)
    }
}
