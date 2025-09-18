import Foundation

public struct VGRArticleElement: Decodable, Identifiable, Hashable {

    public let id = UUID()
    public let type: VGRArticleElementType
    public let title: String
    public let subtitle: String
    public let imageUrl: String
    public let internalId: String
    public let text: String
    public let url: String
    public let readTime: String
    public let date: String
    public let videoUrl: String
    public let videoId: String
    public let publishDate: Date
    public let list: [String]

    /// internalArticle is a reference to another article. It is used to link articles to eachother.
    public var internalArticle: VGRArticle?

    /// Added in order to exclude id from Codable protocol and conform to Identifiable
    enum CodingKeys: String, CodingKey {
        case type, text, url, title, subtitle, imageUrl, internalId, readTime, date, videoUrl, videoId, publishDate, list
    }

    /// Decode manually to avoid optionals
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try values.decode(VGRArticleElementType.self, forKey: .type)
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

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let dateString = try values.decodeIfPresent(String.self, forKey: .publishDate),
           let date = dateFormatter.date(from: dateString) {
            publishDate = date
        } else {
            publishDate = Date()
        }

        list = try values.decodeIfPresent([String].self, forKey: .list) ?? []
    }

    /// Initializer for creating mock elements
    public init(type: VGRArticleElementType,
         text: String = "",
         url: String = "",
         title: String = "",
         subtitle: String = "",
         imageUrl: String = "",
         readTime: String = "",
         date: String = "",
         list: [String] = [],
         internalArticle: VGRArticle? = nil) {
        self.type = type
        self.text = text
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.internalId = ""
        self.readTime = readTime
        self.date = date
        self.videoUrl = ""
        self.videoId = ""
        self.publishDate = Date()
        self.list = list
        self.internalArticle = internalArticle
    }
}
