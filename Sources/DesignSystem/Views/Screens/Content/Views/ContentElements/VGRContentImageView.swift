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

    private var crop: [VGREdge] { element.crop }
    private var cropRadius: CGFloat { CGFloat(element.cropRadius) }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxHeight: imageHeight, alignment: .center)
            .clipShape(
                .rect(
                    topLeadingRadius: crop.contains(.topLeading) ? cropRadius : 0,
                    bottomLeadingRadius: crop.contains(.bottomLeading) ? cropRadius : 0,
                    bottomTrailingRadius: crop.contains(.bottomTrailing) ? cropRadius : 0,
                    topTrailingRadius: crop.contains(.topTrailing) ? cropRadius : 0,
                )
            )
            .padding(.bottom, VGRSpacing.verticalLarge)
            .accessibilityHidden(true)
            .accessibilityAddTraits(.isImage)
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
    .background(Color.Elevation.background)
}
