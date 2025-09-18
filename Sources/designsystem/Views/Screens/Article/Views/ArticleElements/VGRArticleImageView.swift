import SwiftUI

struct VGRArticleImageView: View {
    let element: VGRArticleElement
    @ScaledMetric private var imageHeight: CGFloat = 200

    private var imageURL: String {
        element.url.replacingOccurrences(of: "_small", with: "")
    }

    private var image: Image {
        Image(imageURL, bundle: imageURL.hasPrefix("placeholder") ? .module : .main)
    }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxHeight: imageHeight, alignment: .bottom)
            .clipped()
            .padding(.bottom, VGRArticleSpacing.verticalLarge)
            .accessibilityHidden(true)
    }
}

#Preview {
    VGRArticleImageView(
        element: VGRArticleElement(
            type: .image,
            url: "placeholder",
        )
    )
}
