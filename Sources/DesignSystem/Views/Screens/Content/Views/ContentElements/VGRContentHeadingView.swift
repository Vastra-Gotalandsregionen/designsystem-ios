import SwiftUI

struct VGRContentHeadingView: View {
    let element: VGRContentElement
    @ScaledMetric var iconWidth: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: VGRContentSpacing.verticalMedium) {
            HStack(spacing: 4) {
                Image("icon_calendar", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: iconWidth)
                    .foregroundColor(Color.Neutral.text)
                    .accessibilityHidden(true)
                Text(element.date)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color.Neutral.text)
            }

            HStack (spacing: 6) {
                Image("readtime_text", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconWidth, height: iconWidth)
                    .accessibilityHidden(true)

                Text(element.readTime)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
            }
            .foregroundColor(Color.Neutral.text)
            .accessibilityLabel("\(element.readTime) \("content.text.duration".localizedBundle)")
        }
        .padding(.horizontal, VGRContentSpacing.horizontal)
        .padding(.bottom, VGRContentSpacing.verticalMedium)
    }
}

#Preview {
    VGRContentHeadingView(
        element: VGRContentElement(
            type: .heading,
            readTime: "5 min",
            date: "2024-01-15",
        )
    )
}
