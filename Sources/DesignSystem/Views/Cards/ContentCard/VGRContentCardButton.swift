import SwiftUI

struct VGRContentCardButton: View {
    let sizeClass: VGRContentCardSizeClass
    let content: VGRContent
    let onPressed: () -> Void

    private var a11yLabel: String {
        let isNewString = content.isNew ? "content.new".localizedBundle : ""
        let contentTypeString = "content.type.text".localizedBundle
        let contentReadTimeString = "content.text.duration".localizedBundle
        return "\(isNewString) \(contentTypeString), \(content.title), \(content.subtitle) \(contentReadTimeString)"
    }

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onPressed()
        } label: {
            VGRContentCardView(sizeClass: sizeClass, content: content)
        }
        .buttonStyle(VGRContentCardButtonStyle())
        .accessibilityLabel(a11yLabel)
    }
}



#Preview {
    let articles = VGRContent.randomMultiple(count: 4)
    let sizes: [VGRContentCardSizeClass] = [.large, .medium, .small, .small]

    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(articles.indices, id: \.self) { index in
                    VGRContentCardButton(sizeClass: sizes[index], content: articles[index]) {
                        print("I pressed article \(articles[index].title)")
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRContentCardButton")
        .navigationBarTitleDisplayMode(.inline)
    }
}
