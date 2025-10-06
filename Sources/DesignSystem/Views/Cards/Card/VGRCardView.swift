import SwiftUI

/// Consistent spacing values for article components
public enum VGRSpacing {
    static let horizontal: CGFloat = 16
    static let horizontalList: CGFloat = 24
    static let horizontalLink: CGFloat = 32

    static let verticalSmall: CGFloat = 8
    static let verticalMedium: CGFloat = 12
    static let verticalLarge: CGFloat = 24
    static let verticalXLarge: CGFloat = 32
}

public enum VGRCardSizeClass: CGFloat, CaseIterable {
    case small = 118
    case medium = 120
    case large = 234
}

public struct VGRCardView: View {
    let sizeClass: VGRCardSizeClass
    let title: String
    let subtitle: String
    let imageUrl: String
    let isNew: Bool

    /// Creates a new content card view.
    /// - Parameters:
    ///   - sizeClass: The size class for the card (small, medium, or large).
    ///   - title: The main title displayed on the card.
    ///   - subtitle: The subtitle or read time displayed below the title.
    ///   - imageUrl: The URL or name of the image to display.
    ///   - isNew: Indicates whether to show the "new" badge. Defaults to `false`.
    public init(
        sizeClass: VGRCardSizeClass,
        title: String,
        subtitle: String,
        imageUrl: String,
        isNew: Bool = false
    ) {
        self.sizeClass = sizeClass
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.isNew = isNew
    }

    @ScaledMetric private var readTimeIconSize: CGFloat = 16

    public var body: some View {
        switch sizeClass {
            case .large: largeCard
            case .medium: mediumCard
            case .small: smallCard
        }
    }

    private var image: Image {
        if imageUrl.isEmpty || imageUrl == "placeholder" {
            return Image("placeholder", bundle: .module)
        }

        return Image(imageUrl, bundle: .main)
    }

    private var newContentIcon: some View {
        Text("content.new".localizedBundle)
            .foregroundStyle(Color.Neutral.text)
            .fontWeight(.semibold)
            .dynamicTypeSize(.small ... .large)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.Primary.blueSurface)
            .cornerRadius(5)
    }

    private var readTimeLabel: some View {
        HStack (spacing: 6) {
            Image("readtime_text", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: readTimeIconSize, height: readTimeIconSize)
                .accessibilityHidden(true)

            Text(subtitle)
                .font(.footnote)
                .multilineTextAlignment(.leading)
        }
        .foregroundColor(Color.Neutral.text)
    }

    private var smallCard: some View {
        HStack(alignment: .top, spacing: 0) {
            image
                .resizable()
                .scaledToFill()
                .frame(maxWidth: sizeClass.rawValue,
                       idealHeight: 20,
                       alignment: .center)
                .clipped()

            VStack(alignment: .leading, spacing: VGRSpacing.verticalMedium) {
                Text(title)
                    .foregroundColor(Color.Neutral.text)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)

                readTimeLabel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, VGRSpacing.verticalMedium)
            .padding(.leading, VGRSpacing.horizontal)
            .padding(.bottom, VGRSpacing.verticalMedium)
            .padding(.trailing, VGRSpacing.horizontal)

            if isNew {
                newContentIcon
                    .padding(.trailing, VGRSpacing.horizontal)
                    .padding(.top, VGRSpacing.horizontal)
            }
        }
        .background(Color.Elevation.elevation1)
        .clipped()
        .cornerRadius(16)
    }

    private var mediumCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: sizeClass.rawValue, alignment: .center)
                    .contentShape(Rectangle())
                    .clipped()

                if isNew {
                    newContentIcon
                        .padding(.trailing, VGRSpacing.horizontal)
                        .padding(.top, VGRSpacing.horizontal)
                }
            }

            VStack(alignment: .leading, spacing: VGRSpacing.verticalMedium) {
                Text(title)
                    .foregroundColor(Color.Neutral.text)
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.leading)

                readTimeLabel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, VGRSpacing.verticalMedium)
            .padding(.leading, VGRSpacing.horizontal)
            .padding(.bottom, VGRSpacing.horizontal)
            .padding(.trailing, VGRSpacing.horizontal)
        }
        .background(Color.Elevation.elevation1)
        .cornerRadius(16)
    }

    private var largeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: sizeClass.rawValue, alignment: .center)
                    .contentShape(Rectangle())
                    .clipped()

                if isNew {
                    newContentIcon
                        .padding(.trailing, VGRSpacing.horizontal)
                        .padding(.top, VGRSpacing.horizontal)
                }
            }

            VStack(alignment: .leading, spacing: VGRSpacing.verticalMedium) {
                Text(title)
                    .foregroundColor(Color.Neutral.text)
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.leading)

                readTimeLabel
            }
            .padding(.top, VGRSpacing.verticalMedium)
            .padding(.leading, VGRSpacing.horizontal)
            .padding(.bottom, VGRSpacing.horizontal)
            .padding(.trailing, VGRSpacing.horizontal)
        }
        .background(Color.Elevation.elevation1)
        .cornerRadius(16)
        .clipped()
    }
}

#Preview {
    let sizes: [VGRCardSizeClass] = [.large, .medium, .small, .small]

    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                VGRCardView(
                    sizeClass: .large,
                    title: "Understanding Psoriasis",
                    subtitle: "5 min läsning",
                    imageUrl: "placeholder",
                    isNew: true
                )

                VGRCardView(
                    sizeClass: .medium,
                    title: "Treatment Options",
                    subtitle: "3 min läsning",
                    imageUrl: "placeholder",
                    isNew: false
                )

                VGRCardView(
                    sizeClass: .small,
                    title: "Living with Psoriasis",
                    subtitle: "7 min läsning",
                    imageUrl: "placeholder",
                    isNew: false
                )

                VGRCardView(
                    sizeClass: .small,
                    title: "When to See a Doctor",
                    subtitle: "4 min läsning",
                    imageUrl: "placeholder",
                    isNew: true
                )
            }
            .padding(.horizontal, 16)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRCardView")
        .navigationBarTitleDisplayMode(.inline)

    }
}
