import SwiftUI

struct VGRSummeryRowView: View {
    let text: String
    let rangeLabel: String?
    let entryCount: Int?
    let indicatorColor: Color?
    let linkButton: Bool
    let imageIcon: String?

    init(
        text: String,
        rangeLabel: String? = nil,
        entryCount: Int? = nil,
        indicatorColor: Color?  = nil,
        linkButton: Bool = false,
        imageIcon: String?  = nil
    ) {
        self.text = text
        self.rangeLabel = rangeLabel
        self.entryCount = entryCount
        self.indicatorColor = indicatorColor
        self.linkButton = linkButton
        self.imageIcon = imageIcon
    }
    var body: some View {
        HStack {
            if (rangeLabel != nil) {
                Text("\(rangeLabel!)")
                    .frame(minWidth: 32, minHeight: 32)
                    .font(.caption2)
                    .background(indicatorColor!)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .accessibilityHidden(true)
            }
            Text(text)
                .accessibilityHidden(true)
            Spacer()
            if linkButton {
                Image(systemName: imageIcon!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.Primary.action)
                    .padding(.trailing, 16)
            } else {
                Text("\(entryCount!)")
                    .font(.title)
                    .bold()
                    .accessibilityHidden(true)
            }
        }
    }
}

#Preview("Navigation Link") {
    VGRSummeryRowView(
        text: "Assessment forever",
        rangeLabel: "1-3",
        indicatorColor: Color.Accent.greenSurface,
        linkButton: true,
        imageIcon: "chevron.right"
    )
}

#Preview("Text only") {
    VGRSummeryRowView(
        text: "Assessment forever",
        entryCount: 3
    )
}
