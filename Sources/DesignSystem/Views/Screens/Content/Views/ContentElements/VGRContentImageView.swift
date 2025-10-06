import SwiftUI

struct VGRContentImageView: View {
    let element: VGRContentElement
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
            .padding(.bottom, VGRSpacing.verticalLarge)
            .accessibilityHidden(true)
    }
}

#Preview {
    VGRContentImageView(
        element: VGRContentElement(
            type: .image,
            url: "placeholder",
        )
    )
}
