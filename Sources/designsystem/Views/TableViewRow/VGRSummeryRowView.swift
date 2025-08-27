import SwiftUI

/// A reusable SwiftUI row view that displays up to five customizable content views.
struct VGRSummaryRowView<
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    TrailingIcon: View
>: View {
    @ScaledMetric var contentWidth: CGFloat = 32
    @ScaledMetric var contentHeight: CGFloat = 32

    private let content1: () -> Content1
    private let content2: () -> Content2
    private let content3: () -> Content3
    private let content4: () -> Content4
    private let trailingIcon: () -> TrailingIcon

    init(
        @ViewBuilder content1: @escaping () -> Content1 = { EmptyView() },
        @ViewBuilder content2: @escaping () -> Content2,
        @ViewBuilder content3: @escaping () -> Content3,
        @ViewBuilder content4: @escaping () -> Content4 = { EmptyView() },
        @ViewBuilder trailingIcon: @escaping () -> TrailingIcon = { EmptyView() }
    ) {
        self.content1 = content1
        self.content2 = content2
        self.content3 = content3
        self.content4 = content4
        self.trailingIcon = trailingIcon
    }

    var body: some View {
        HStack {
            content1()
                .frame(minWidth: contentWidth, minHeight: contentHeight)
            content2()
            Spacer()
            content3()
            content4()
            trailingIcon()
        }
        .padding([.leading, .trailing], 16)
    }
}

#Preview("Minimal effort") {
    HStack(spacing: 4) {
        VGRSummaryRowView(
            content2: { Text("Hur går det på en skala?") },
            content3: { Text("3") },
        )
    }
}

#Preview("Everything applies") {
    HStack(spacing: 4) {
        VGRSummaryRowView(
            content1: { Text("4-6")
                    .font(.caption2)
                    .frame(width: 32, height: 32)
                .background(Color.Accent.limeSurface)},
            content2: { Text("Vilken raiting får vald modell?") },
            content3: { Text("3310") },
            content4: { Image(systemName: "heart.fill") },
            trailingIcon: { Image(systemName: "chevron.right") }
        )
    }
}
