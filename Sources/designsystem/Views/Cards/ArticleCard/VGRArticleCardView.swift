import SwiftUI

/// Consistent spacing values for article components
enum VGRArticleSpacing {
    static let horizontal: CGFloat = 16
    static let horizontalList: CGFloat = 24
    static let horizontalLink: CGFloat = 32

    static let verticalSmall: CGFloat = 8
    static let verticalMedium: CGFloat = 12
    static let verticalLarge: CGFloat = 24
    static let verticalXLarge: CGFloat = 32
}


enum VGRArticleCardSizeClass: CGFloat, CaseIterable {
    case small = 118
    case medium = 120
    case large = 234
}


struct VGRArticleCardView: View {
    let sizeClass: VGRArticleCardSizeClass
    let article: VGRArticle

    @ScaledMetric private var readTimeIconSize: CGFloat = 16

    var body: some View {
        switch sizeClass {
            case .large: largeCard
            case .medium: mediumCard
            case .small: smallCard
        }
    }

    private var image: Image {
        Image(
            article.imageUrl,
            bundle: article.imageUrl.hasPrefix("placeholder") ? .module : .main
        )
    }

    private var newContentIcon: some View {
        Text("article.content.new".localizedBundle)
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

            Text(article.subtitle)
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

            VStack(alignment: .leading, spacing: VGRArticleSpacing.verticalMedium) {
                Text(article.title)
                    .foregroundColor(Color.Neutral.text)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)

                readTimeLabel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, VGRArticleSpacing.verticalMedium)
            .padding(.leading, VGRArticleSpacing.horizontal)
            .padding(.bottom, VGRArticleSpacing.verticalMedium)
            .padding(.trailing, VGRArticleSpacing.horizontal)

            if article.isNew {
                newContentIcon
                    .padding(.trailing, VGRArticleSpacing.horizontal)
                    .padding(.top, VGRArticleSpacing.horizontal)
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

                if article.isNew {
                    newContentIcon
                        .padding(.trailing, VGRArticleSpacing.horizontal)
                        .padding(.top, VGRArticleSpacing.horizontal)
                }
            }

            VStack(alignment: .leading, spacing: VGRArticleSpacing.verticalMedium) {
                Text(article.title)
                    .foregroundColor(Color.Neutral.text)
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.leading)

                readTimeLabel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, VGRArticleSpacing.verticalMedium)
            .padding(.leading, VGRArticleSpacing.horizontal)
            .padding(.bottom, VGRArticleSpacing.horizontal)
            .padding(.trailing, VGRArticleSpacing.horizontal)
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

                if article.isNew {
                    newContentIcon
                        .padding(.trailing, VGRArticleSpacing.horizontal)
                        .padding(.top, VGRArticleSpacing.horizontal)
                }
            }

            VStack(alignment: .leading, spacing: VGRArticleSpacing.verticalMedium) {
                Text(article.title)
                    .foregroundColor(Color.Neutral.text)
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.leading)

                readTimeLabel
            }
            .padding(.top, VGRArticleSpacing.verticalMedium)
            .padding(.leading, VGRArticleSpacing.horizontal)
            .padding(.bottom, VGRArticleSpacing.horizontal)
            .padding(.trailing, VGRArticleSpacing.horizontal)
        }
        .background(Color.Elevation.elevation1)
        .cornerRadius(16)
        .clipped()
    }
}

#Preview {
    let articles = VGRArticle.randomMultiple(count: 4)
    let sizes: [VGRArticleCardSizeClass] = [.large, .medium, .small, .small]

    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(articles.indices, id: \.self) { index in
                    VGRArticleCardView(sizeClass: sizes[index], article: articles[index])
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRArticleCardView")
        .navigationBarTitleDisplayMode(.inline)

    }
}
