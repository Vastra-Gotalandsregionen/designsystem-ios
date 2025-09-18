import SwiftUI

struct VGRArticleCardButton: View {
    let sizeClass: VGRArticleCardSizeClass
    let article: VGRArticle
    let onPressed: () -> Void

    private var a11yLabel: String {
        let isNewString = article.isNew ? "article.content.new".localizedBundle : ""
        let articleTypeString = "article.type.text".localizedBundle
        let articleReadTimeString = "article.content.text.duration".localizedBundle
        return "\(isNewString) \(articleTypeString), \(article.title), \(article.subtitle) \(articleReadTimeString)"
    }

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onPressed()
        } label: {
            VGRArticleCardView(sizeClass: sizeClass, article: article)
        }
        .buttonStyle(VGRArticleCardButtonStyle())
        .accessibilityLabel(a11yLabel)
    }
}

struct VGRArticleCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .rotation3DEffect(
                .degrees(configuration.isPressed ? 2 : 0),
                axis: (x: 1.0, y: 2.0, z: 0.0)
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    let articles = VGRArticle.randomMultiple(count: 4)
    let sizes: [VGRArticleCardSizeClass] = [.large, .medium, .small, .small]

    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(articles.indices, id: \.self) { index in
                    VGRArticleCardButton(sizeClass: sizes[index], article: articles[index]) {
                        print("I pressed article \(articles[index].title)")
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRArticleCardButton")
        .navigationBarTitleDisplayMode(.inline)
    }
}
