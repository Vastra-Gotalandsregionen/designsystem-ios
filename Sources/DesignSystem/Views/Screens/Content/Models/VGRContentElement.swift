import Foundation

public struct VGRContentElement: Decodable, Identifiable, Hashable {

    public let id = UUID()

    /// Denotes the type of element this is, for example `.faq`, `.body` and `.h1`
    public let type: VGRContentElementType

    /// Title property, used in conjunction with elementType `.video`
    public let title: String
    public let subtitle: String

    public let imageUrl: String

    public let internalId: String
    public let text: String
    public let url: String
    public let readTime: String

    public let crop: [VGREdge]
    public let cropRadius: Int

    /// List property, used in conjuction with elementType `.list`
    public let list: [String]

    /// Tag property, used to filter out elements based on tags
    public let tags: [String]

    /// Links property, used in conjunction with elementType `.linkGroup`
    public let links: [VGRContentElement]

    public let videoUrl: String
    public let videoId: String
    public let date: String
    public let publishDate: Date

    /// Question property used in conjunction with elementType `.faq`
    public let question: String

    /// Answer property used in conjunction with elementType `.faq`
    public let answer: String

    /// internalArticle is a reference to another article. It is used to link articles to eachother.
    public var internalArticle: VGRContent?

    /// Added in order to exclude id from Codable protocol and conform to Identifiable
    enum CodingKeys: String, CodingKey {
        case type, text, url, title, subtitle, imageUrl, internalId, readTime, date, videoUrl, videoId, publishDate, list
        case tags, links
        case crop, cropRadius
        case question, answer
    }

    /// Decode manually to avoid optionals
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.type = try values.decode(VGRContentElementType.self, forKey: .type)
        self.text = try values.decodeIfPresent(String.self, forKey: .text) ?? ""
        self.url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""

        self.title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.internalId = try values.decodeIfPresent(String.self, forKey: .internalId) ?? ""
        self.readTime = try values.decodeIfPresent(String.self, forKey: .readTime) ?? ""
        self.date = try values.decodeIfPresent(String.self, forKey: .date) ?? ""

        self.videoUrl = try values.decodeIfPresent(String.self, forKey: .videoUrl) ?? ""
        self.videoId = try values.decodeIfPresent(String.self, forKey: .videoId) ?? ""

        self.question = try values.decodeIfPresent(String.self, forKey: .question) ?? ""
        self.answer = try values.decodeIfPresent(String.self, forKey: .answer) ?? ""

        self.list = try values.decodeIfPresent([String].self, forKey: .list) ?? []
        self.tags = try values.decodeIfPresent([String].self, forKey: .tags) ?? []

        self.crop = try values.decodeIfPresent([VGREdge].self, forKey: .crop) ?? []
        self.cropRadius = try values.decodeIfPresent(Int.self, forKey: .cropRadius) ?? 0

        self.links = try values.decodeIfPresent([VGRContentElement].self, forKey: .links) ?? []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let dateString = try values.decodeIfPresent(String.self, forKey: .publishDate),
           let date = dateFormatter.date(from: dateString) {
            publishDate = date
        } else {
            publishDate = Date()
        }
    }

    /// Initializer for creating mock elements
    public init(type: VGRContentElementType,
                text: String = "",
                url: String = "",
                title: String = "",
                subtitle: String = "",
                imageUrl: String = "",
                readTime: String = "",
                date: String = "",
                videoUrl: String = "",
                videoId: String = "",
                publishDate: Date = Date(),
                list: [String] = [],
                tags: [String] = [],
                crop: [VGREdge] = [],
                cropRadius: Int = 0,
                links: [VGRContentElement] = [],
                internalArticle: VGRContent? = nil,
                question: String = "",
                answer: String = "") {

        self.type = type
        self.text = text
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.internalId = ""
        self.readTime = readTime
        self.date = date
        self.videoUrl = videoUrl
        self.videoId = videoId
        self.publishDate = publishDate
        self.list = list
        self.tags = tags
        self.crop = crop
        self.cropRadius = cropRadius
        self.links = links
        self.internalArticle = internalArticle

        self.question = question
        self.answer = answer
    }
}
