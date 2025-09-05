import SwiftUI

struct VGRSummaryRowView<
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    TrailingIcon: View
>: View {
    @ScaledMetric var contentWidth: CGFloat = 32
    @ScaledMetric var contentHeight: CGFloat = 32

    private let indicatorContent1: () -> Content1
    private let textContent2: () -> Content2
    private let valueContent3: () -> Content3
    private let trendContent4: () -> Content4
    private let trailingIcon: () -> TrailingIcon

    init(
        @ViewBuilder indicatorContent1: @escaping () -> Content1 = { EmptyView() },
        @ViewBuilder textContent2: @escaping () -> Content2,
        @ViewBuilder valueContent3: @escaping () -> Content3,
        @ViewBuilder trendContent4: @escaping () -> Content4 = { EmptyView() },
        @ViewBuilder trailingIcon: @escaping () -> TrailingIcon = { EmptyView() }
    ) {
        self.indicatorContent1 = indicatorContent1
        self.textContent2 = textContent2
        self.valueContent3 = valueContent3
        self.trendContent4 = trendContent4
        self.trailingIcon = trailingIcon
    }

    var body: some View {
        HStack {
            indicatorContent1()
                .frame(minWidth: contentWidth, minHeight: contentHeight)
            textContent2()
            Spacer()
            valueContent3()
            trendContent4()
            trailingIcon()
        }
        .padding([.leading, .trailing], 16)
    }
}

#Preview("Minimal effort") {
    HStack(spacing: 4) {
        VGRSummaryRowView(
            textContent2: { Text("Hur går det på en skala?") },
            valueContent3: { Text("3") },
        )
    }
}

#Preview("Everything applies") {
    HStack(spacing: 4) {
        VGRSummaryRowView(
            indicatorContent1: { Image(systemName: "heart.fill") },
            textContent2: { Text("Vilken raiting får vald modell?") },
            valueContent3: { Text("3310") },
            trailingIcon: { Image(systemName: "chevron.right") }
        )
    }
}
