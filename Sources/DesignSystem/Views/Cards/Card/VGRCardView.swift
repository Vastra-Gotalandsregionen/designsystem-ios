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

public enum VGRRadius {
    static let mainRadius: CGFloat = 26
    static let vgrCorner: CGFloat = 40
}

public enum VGRCardSizeClass: CGFloat, CaseIterable {
    case small = 118
    case medium = 120
    case large = 234

    var maxImageHeight: CGFloat {
        switch self {
            case .small:
                return 104
            case .medium:
                return 120
            case .large:
                return 234
        }
    }

    var idealCardHeight: CGFloat {
        switch self {
            case .small:
                return 104
            case .medium:
                return 225
            case .large:
                return 344
        }
    }
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
    ///   - subtitle: The subtitle or read time displayed below the title, defaults to empty.
    ///   - imageUrl: The URL or name of the image to display. When empty (the default), no image is shown.
    ///   - isNew: Indicates whether to show the "new" badge. Defaults to `false`.
    public init(
        sizeClass: VGRCardSizeClass,
        title: String,
        subtitle: String = "",
        imageUrl: String = "",
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

    /// The image to display, or `nil` when no `imageUrl` was provided.
    private var image: Image? {
        if imageUrl.isEmpty {
            return nil
        }

        if imageUrl == "placeholder" {
            return Image(imageUrl, bundle: .module)
        }

        return Image(imageUrl, bundle: .main)
    }

    private var newContentIcon: some View {
        Text("content.new".localizedBundle)
            .font(.footnoteSemibold)
            .foregroundStyle(Color.Neutral.text)
            .dynamicTypeSize(.small ... .large)
            .padding(.horizontal, .Margins.xtraSmall)
            .padding(.vertical, .Margins.xtraSmall / 2)
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
        HStack(alignment: .center, spacing: 0) {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 118)
                    .frame(idealHeight: sizeClass.idealCardHeight,
                           alignment: .center)
                    .clipped()
            }

            VStack(alignment: .center, spacing: .Margins.small) {
                Text(title)
                    .foregroundColor(Color.Neutral.text)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .frame(maxHeight: .infinity, alignment: !subtitle.isEmpty ? .top : .center)

                readTimeLabel
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .isVisible(!subtitle.isEmpty)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, .Margins.small)
            .padding(.leading, .Margins.medium)
            .padding(.bottom, .Margins.small)
            .padding(.trailing, .Margins.medium)

            if isNew {
                VStack {
                    newContentIcon
                        .padding(.trailing, .Margins.medium)
                        .padding(.top, .Margins.small)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(idealHeight: sizeClass.idealCardHeight)
        .background(Color.Elevation.elevation1)
        .cornerRadius(16)

    }

    private var mediumCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: sizeClass.maxImageHeight, alignment: .center)
                        .contentShape(Rectangle())
                        .clipped()
                        .clipShape(
                            .rect(
                                bottomLeadingRadius: .Radius.vgrCorner,
                            )
                        )
                }

                if isNew {
                    newContentIcon
                        .padding(.trailing, .Margins.medium)
                        .padding(.top, .Margins.medium)
                }
            }

            VStack(alignment: .leading, spacing: .Margins.small) {
                Text(title)
                    .foregroundColor(Color.Neutral.text)
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.leading)

                readTimeLabel
                    .isVisible(!subtitle.isEmpty)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, .Margins.small)
            .padding(.leading, .Margins.medium)
            .padding(.bottom, .Margins.medium)
            .padding(.trailing, .Margins.medium)
        }
        .background(Color.Elevation.elevation1)
        .cornerRadius(16)
    }

    private var largeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: sizeClass.maxImageHeight, alignment: .center)
                        .contentShape(Rectangle())
                        .clipped()
                        .clipShape(
                            .rect(
                                bottomLeadingRadius: .Radius.vgrCorner,
                            )
                        )
                }

                if isNew {
                    newContentIcon
                        .padding(.trailing, .Margins.medium)
                        .padding(.top, .Margins.medium)
                }
            }

            VStack(alignment: .leading, spacing: .Margins.small) {
                Text(title)
                    .foregroundColor(Color.Neutral.text)
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.leading)

                readTimeLabel
                    .isVisible(!subtitle.isEmpty)
            }
            .padding(.top, .Margins.small)
            .padding(.leading, .Margins.medium)
            .padding(.bottom, .Margins.medium)
            .padding(.trailing, .Margins.medium)
        }
        .background(Color.Elevation.elevation1)
        .cornerRadius(16)
        .clipped()
    }
}

#Preview("Small card") {
    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRCardView(
                    sizeClass: .small,
                    title: "Vilka aktiviteter kan jag registrera i appen?",
                    subtitle: "5 min läsning",
                    imageUrl: "placeholder",
                    isNew: true
                )

                VGRCardView(
                    sizeClass: .small,
                    title: "Understanding Psoriasis",
                    imageUrl: "placeholder",
                    isNew: true
                )

                VGRCardView(
                    sizeClass: .small,
                    title: "Understanding Psoriasis",
                    imageUrl: "placeholder",
                )

                VGRCardView(
                    sizeClass: .small,
                    title: "Understanding Psoriasis",
                )
            }
        }
        .navigationTitle("VGRCardView")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Medium card") {
    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRCardView(
                    sizeClass: .medium,
                    title: "Understanding Psoriasis",
                    subtitle: "5 min läsning",
                    imageUrl: "placeholder",
                    isNew: true
                )

                VGRCardView(
                    sizeClass: .medium,
                    title: "Understanding Psoriasis",
                    imageUrl: "placeholder",
                    isNew: true
                )

                VGRCardView(
                    sizeClass: .medium,
                    title: "Understanding Psoriasis",
                    imageUrl: "placeholder",
                )

                VGRCardView(
                    sizeClass: .medium,
                    title: "Understanding Psoriasis",
                )
            }
        }
        .navigationTitle("VGRCardView")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Large card") {
    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRCardView(
                    sizeClass: .large,
                    title: "Understanding Psoriasis",
                    subtitle: "5 min läsning",
                    imageUrl: "placeholder",
                    isNew: true
                )

                VGRCardView(
                    sizeClass: .large,
                    title: "Understanding Psoriasis",
                    imageUrl: "placeholder",
                    isNew: true
                )

                VGRCardView(
                    sizeClass: .large,
                    title: "Understanding Psoriasis",
                    imageUrl: "placeholder",
                )

                VGRCardView(
                    sizeClass: .large,
                    title: "Understanding Psoriasis",
                )
            }
        }
        .navigationTitle("VGRCardView")
        .navigationBarTitleDisplayMode(.inline)
    }
}
