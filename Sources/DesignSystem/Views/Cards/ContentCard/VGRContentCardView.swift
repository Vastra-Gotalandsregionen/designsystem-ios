import SwiftUI

/// Consistent spacing values for article components
public enum VGRContentSpacing {
    static let horizontal: CGFloat = 16
    static let horizontalList: CGFloat = 24
    static let horizontalLink: CGFloat = 32

    static let verticalSmall: CGFloat = 8
    static let verticalMedium: CGFloat = 12
    static let verticalLarge: CGFloat = 24
    static let verticalXLarge: CGFloat = 32
}


public enum VGRContentCardSizeClass: CGFloat, CaseIterable {
    case small = 118
    case medium = 120
    case large = 234
}


public struct VGRContentCardView: View {
    let sizeClass: VGRContentCardSizeClass
    let content: VGRContent

    @ScaledMetric private var readTimeIconSize: CGFloat = 16

    public var body: some View {
        switch sizeClass {
            case .large: largeCard
            case .medium: mediumCard
            case .small: smallCard
        }
    }

    private var image: Image {
        if content.imageUrl.isEmpty {
            return Image("placeholder", bundle: .module)
        }

        return Image(content.imageUrl, bundle: .main)
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

            Text(content.subtitle)
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

            VStack(alignment: .leading, spacing: VGRContentSpacing.verticalMedium) {
                Text(content.title)
                    .foregroundColor(Color.Neutral.text)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)

                readTimeLabel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, VGRContentSpacing.verticalMedium)
            .padding(.leading, VGRContentSpacing.horizontal)
            .padding(.bottom, VGRContentSpacing.verticalMedium)
            .padding(.trailing, VGRContentSpacing.horizontal)

            if content.isNew {
                newContentIcon
                    .padding(.trailing, VGRContentSpacing.horizontal)
                    .padding(.top, VGRContentSpacing.horizontal)
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

                if content.isNew {
                    newContentIcon
                        .padding(.trailing, VGRContentSpacing.horizontal)
                        .padding(.top, VGRContentSpacing.horizontal)
                }
            }

            VStack(alignment: .leading, spacing: VGRContentSpacing.verticalMedium) {
                Text(content.title)
                    .foregroundColor(Color.Neutral.text)
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.leading)

                readTimeLabel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, VGRContentSpacing.verticalMedium)
            .padding(.leading, VGRContentSpacing.horizontal)
            .padding(.bottom, VGRContentSpacing.horizontal)
            .padding(.trailing, VGRContentSpacing.horizontal)
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

                if content.isNew {
                    newContentIcon
                        .padding(.trailing, VGRContentSpacing.horizontal)
                        .padding(.top, VGRContentSpacing.horizontal)
                }
            }

            VStack(alignment: .leading, spacing: VGRContentSpacing.verticalMedium) {
                Text(content.title)
                    .foregroundColor(Color.Neutral.text)
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.leading)

                readTimeLabel
            }
            .padding(.top, VGRContentSpacing.verticalMedium)
            .padding(.leading, VGRContentSpacing.horizontal)
            .padding(.bottom, VGRContentSpacing.horizontal)
            .padding(.trailing, VGRContentSpacing.horizontal)
        }
        .background(Color.Elevation.elevation1)
        .cornerRadius(16)
        .clipped()
    }
}

#Preview {
    let articles = VGRContent.randomMultiple(count: 4)
    let sizes: [VGRContentCardSizeClass] = [.large, .medium, .small, .small]

    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(articles.indices, id: \.self) { index in
                    VGRContentCardView(sizeClass: sizes[index], content: articles[index])
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRContentCardView")
        .navigationBarTitleDisplayMode(.inline)

    }
}
