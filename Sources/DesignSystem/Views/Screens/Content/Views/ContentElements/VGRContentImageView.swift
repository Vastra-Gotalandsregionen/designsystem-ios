import SwiftUI

struct VGRContentImageView: View {
    let element: VGRContentElement
    @ScaledMetric private var imageHeight: CGFloat = 200

    private var imageURL: String {
        /// TODO(EA): Remove, legacy code?
        let newURL = element.url.replacingOccurrences(of: "_small", with: "")
        return newURL.isEmpty ? "placeholder" : newURL
    }

    private var image: Image {
        Image(imageURL, bundle: imageURL.hasPrefix("placeholder") ? .module : .main)
    }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxHeight: imageHeight, alignment: .center)
            .clipShape(
                .rect(
                    topLeadingRadius: CGFloat(element.crop.contains(.topLeading) ? element.cropRadius : 0),
                    bottomLeadingRadius: CGFloat(element.crop.contains(.bottomLeading) ? element.cropRadius : 0),
                    bottomTrailingRadius: CGFloat(element.crop.contains(.bottomTrailing) ? element.cropRadius : 0),
                    topTrailingRadius: CGFloat(element.crop.contains(.topTrailing) ? element.cropRadius : 0),
                )
            )
            .padding(.bottom, VGRSpacing.verticalLarge)
            .accessibilityHidden(true)
    }
}

#Preview {
    ScrollView {
        VGRContentImageView(
            element: VGRContentElement(
                type: .image,
                crop: [.bottomLeading],
                cropRadius: 40,
            )
        )
    }
    .background(Color.gray)
}
