import SwiftUI

struct VGRContentImageView: View {
    let element: VGRContentElement
    @ScaledMetric private var imageHeight: CGFloat

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

    private var a11yHidden: Bool { element.a11y.isEmpty }
    private var a11yTitle: String { element.a11y }

    public init(element: VGRContentElement) {
        self.element = element

        let height = element.imageHeight == 0 ? 200 : element.imageHeight
        self._imageHeight = ScaledMetric(wrappedValue: CGFloat(height))
    }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: imageHeight, alignment: .center)
            .clipShape(
                .rect(
                    topLeadingRadius: crop.contains(.topLeading) ? cropRadius : 0,
                    bottomLeadingRadius: crop.contains(.bottomLeading) ? cropRadius : 0,
                    bottomTrailingRadius: crop.contains(.bottomTrailing) ? cropRadius : 0,
                    topTrailingRadius: crop.contains(.topTrailing) ? cropRadius : 0,
                )
            )
            .padding(element.paddingEdgeInsets)
            .padding(.bottom, VGRSpacing.verticalLarge)
            .accessibilityLabel(a11yTitle)
            .accessibilityHidden(a11yHidden)
            .accessibilityAddTraits(.isImage)

    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            VGRContentImageView(
                element: VGRContentElement(
                    type: .image,
                    crop: [.bottomLeading],
                    cropRadius: 40,
                )
            )

            VGRContentImageView(
                element: VGRContentElement(
                    type: .image,
                    imageHeight: 900,
                    padding: [0, 16, 0, 16],
                )
            )
        }
    }
    .background(Color.red)
}
