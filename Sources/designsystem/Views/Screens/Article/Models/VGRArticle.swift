import Foundation

/// Article represents an content item
public struct VGRArticle: Identifiable, Hashable, Equatable, Decodable {
    public let index: Int
    public let id: String
    public let type: VGRArticleType
    public let contentType: String
    public let order: Int
    public let title: String
    public let cardTitle: String
    public let subtitle: String
    public let buttonText: String
    public let imageUrl: String
    public let elements: [VGRArticleElement]
    public let publishDate: Date
    public let isNew: Bool

    /// Equatable protocol
    public static func == (lhs: VGRArticle, rhs: VGRArticle) -> Bool { lhs.id == rhs.id }

    enum CodingKeys: String, CodingKey {
        case id, type, order, title, cardTitle, subtitle, buttonText, imageUrl, elements, contentType, publishDate
    }

    public init(_ title: String, subtitle: String, type: VGRArticleType, imageUrl: String) {
        self.id = UUID().uuidString
        self.type = type
        self.title = title
        self.contentType = ""
        self.cardTitle = ""
        self.subtitle = subtitle
        self.buttonText = ""
        self.imageUrl = imageUrl
        self.elements = []
        self.index = 0
        self.order = 0
        self.publishDate = Date()
        self.isNew = false
    }

    /// Extended initializer for creating articles with elements
    public init(id: String? = nil,
         title: String,
         subtitle: String,
         type: VGRArticleType,
         imageUrl: String,
         elements: [VGRArticleElement] = [],
         isNew: Bool = false) {
        self.id = id ?? UUID().uuidString
        self.type = type
        self.title = title
        self.contentType = ""
        self.cardTitle = title
        self.subtitle = subtitle
        self.buttonText = ""
        self.imageUrl = imageUrl
        self.elements = elements
        self.index = 0
        self.order = 0
        self.publishDate = Date()
        self.isNew = isNew
    }

    /// Decode manually to avoid optionals
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        type = try values.decode(VGRArticleType.self, forKey: .type)
        contentType = try values.decodeIfPresent(String.self, forKey: .contentType) ?? ""
        order = try values.decodeIfPresent(Int.self, forKey: .order) ?? 0
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        cardTitle = try values.decodeIfPresent(String.self, forKey: .cardTitle) ?? ""
        subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        buttonText = try values.decodeIfPresent(String.self, forKey: .buttonText) ?? ""
        imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        elements = try values.decodeIfPresent([VGRArticleElement].self, forKey: .elements) ?? []
        index = 0
        isNew = false

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let releaseDateString = try values.decodeIfPresent(String.self, forKey: .publishDate),
           let date = dateFormatter.date(from: releaseDateString) {
            publishDate = date
        } else {
            publishDate = Date()
        }
    }
}

// MARK: - Lorem Ipsum Generator

extension VGRArticle {
    /// Generates a randomized Lorem ipsum article for testing purposes
    public static func random(type: VGRArticleType = .article, elementCount: Int = 10, images: [String] = []) -> VGRArticle {
        let loremParagraphs = [
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
            "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
            "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.",
            "Totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
            "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit.",
            "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit."
        ]

        let loremTitles = [
            "Lorem Ipsum Dolor",
            "Consectetur Adipiscing",
            "Tempor Incididunt",
            "Labore et Dolore",
            "Magna Aliqua",
            "Exercitation Ullamco",
            "Voluptate Velit",
            "Fugiat Nulla"
        ]

        let loremListItems = [
            "Lorem ipsum dolor sit amet",
            "Consectetur adipiscing elit",
            "Sed do eiusmod tempor",
            "Ut labore et dolore magna",
            "Quis nostrud exercitation",
            "Aliquip ex ea commodo",
            "Duis aute irure dolor",
            "Culpa qui officia deserunt"
        ]

        var elements: [VGRArticleElement] = []

        /// Add main image
        elements.append(VGRArticleElement(
            type: .image,
            url: images.randomElement() ?? "placeholder"
        ))

        /// Add main title
        elements.append(VGRArticleElement(
            type: .h1,
            text: loremTitles.randomElement() ?? "Lorem Ipsum"
        ))

        /// Add subhead
        elements.append(VGRArticleElement(
            type: .subhead,
            text: loremParagraphs.randomElement() ?? "Lorem Ipsum"
        ))


        /// Generate random content elements
        let availableTypes: [VGRArticleElementType] = [.h2, .h3, .body, .subhead, .list]

        for i in 0..<elementCount {
            let randomType = availableTypes.randomElement() ?? .body

            switch randomType {
                case .h2:
                    elements.append(VGRArticleElement(
                        type: .h2,
                        text: loremTitles.randomElement() ?? "Section Title"
                    ))
                case .h3:
                    elements.append(VGRArticleElement(
                        type: .h3,
                        text: loremTitles.randomElement() ?? "Subsection Title"
                    ))
                case .body:
                    elements.append(VGRArticleElement(
                        type: .body,
                        text: loremParagraphs.randomElement() ?? "Lorem ipsum text"
                    ))
                case .subhead:
                    elements.append(VGRArticleElement(
                        type: .subhead,
                        text: loremParagraphs.randomElement()?.prefix(100).description ?? "Subheading text"
                    ))
                case .list:
                    let listCount = Int.random(in: 3...6)
                    let randomList = Array(loremListItems.shuffled().prefix(listCount))
                    elements.append(VGRArticleElement(
                        type: .list,
                        list: randomList
                    ))
                default:
                    break
            }

            /// Occasionally add an external link
            if i % 4 == 0 && Bool.random() {
                elements.append(VGRArticleElement(
                    type: .link,
                    text: "External resources",
                    url: "https://www.example.com/lorem-ipsum"
                ))
            }
        }

        let title = loremTitles.randomElement() ?? "Lorem Ipsum Article"

        return VGRArticle(
            title: title,
            subtitle: "\(Int.random(in: 3...15)) min läsning",
            type: type,
            imageUrl: images.randomElement() ?? "placeholder",
            elements: elements,
            isNew: Bool.random()
        )
    }

    /// Generates multiple Lorem ipsum articles
    public static func randomMultiple(count: Int = 5, type: VGRArticleType = .article) -> [VGRArticle] {
        (0..<count).map { _ in
            random(type: type, elementCount: Int.random(in: 5...15))
        }
    }
}
