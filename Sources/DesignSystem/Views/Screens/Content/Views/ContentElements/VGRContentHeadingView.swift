import SwiftUI

struct VGRContentHeadingView: View {
    let element: VGRContentElement
    @ScaledMetric private var iconWidth: CGFloat = 16
    @ScaledMetric private var horizontalSpacing: CGFloat = 8


    var body: some View {
        Grid(horizontalSpacing: horizontalSpacing,
             verticalSpacing: VGRSpacing.verticalMedium) {
            GridRow {
                Image("icon_calendar", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: iconWidth)
                    .accessibilityHidden(true)

                Text(element.date)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .maxLeading()
            }
            .accessibilityLabel(element.date)
            .isVisible(!element.date.isEmpty)

            GridRow {
                Image("readtime_text", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconWidth, height: iconWidth)
                    .accessibilityHidden(true)

                Text(element.readTime)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .maxLeading()
            }
            .accessibilityLabel("\(element.readTime) \("content.text.duration".localizedBundle)")
            .isVisible(!element.readTime.isEmpty)
        }
        .foregroundStyle(Color.Neutral.text)
        .padding(.horizontal, VGRSpacing.horizontal)
        .padding(.bottom, VGRSpacing.verticalMedium)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                VGRContentHeadingView(
                    element: VGRContentElement(
                        type: .heading,
                        readTime: "5 min",
                        date: "2024-01-15",
                    )
                )

                VGRDivider()

                VGRContentHeadingView(
                    element: VGRContentElement(
                        type: .heading,
                        date: "2024-01-15",
                    )
                )

                VGRDivider()

                VGRContentHeadingView(
                    element: VGRContentElement(
                        type: .heading,
                        readTime: "5 min",
                    )
                )
            }
        }
        .navigationTitle("VGRContentHeadingView")
        .navigationBarTitleDisplayMode(.inline)
    }
}
