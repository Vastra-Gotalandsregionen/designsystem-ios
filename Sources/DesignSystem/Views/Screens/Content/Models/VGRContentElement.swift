import Foundation
import SwiftUI

public struct VGRContentElement: Decodable, Identifiable, Hashable {

    public let id = UUID()

    /// Denotes the type of element this is, for example `.faq`, `.body` and `.h1`
    public let type: VGRContentElementType

    /// Title property, used in conjunction with elementType `.video`
    public let title: String
    public let subtitle: String

    
    @available(*, deprecated, message: "Use url instead. This will be removed in a future version.")
    public let imageUrl: String

    public let internalId: String

    /// text is used in many elements to denote the content of an element (ex. body, h1, h2, footnote etc)
    public let text: String

    public let readTime: String

    /// Crop properties for images
    public let crop: [VGREdge]
    public let cropRadius: Int

    /// Image height is to set the height of an image explicitly
    public let imageHeight: Int

    /// Padding is currently on used for images. It provides a means to set edgeinsets for an image element
    public let padding: [Int]


    /// Used to set the name of images. (expects image asset name, ex. "diagram_psykisk_halsa")
    /// Also used for link element (expects protocol specifier, eg. "https://")
    public let url: String

    /// Optional, used in conjunction with url.
    /// This property is used to give long URLs (in the `url` property) a display friendly alternative.
    public let urlTitle: String

    /// Accessibility property, used to provide voice over support for images.
    /// Images voice over support is disabled if this is empty.
    public let a11y: String

    /// List property, used in conjuction with elementType `.list` or `.ordered`
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

    /// Feedback options property, used in conjunction with elementType `.feedback`
    /// Contains an array of option keys that match `VGRFeedbackOption` cases
    public let feedbackOptions: [String]

    // MARK: - Action Callout Properties (used with `.actionCallout` element type)

    /// Identifier for the action, used by the consuming app to determine what action to perform
    public let actionId: String

    /// Header text for the action callout
    public let actionHeader: String

    /// Description text for the action callout
    public let actionDescription: String

    /// Button label for the action callout
    public let actionButtonLabel: String

    /// Accessibility label for the action button
    public let actionButtonA11yLabel: String

    /// Image name for the action callout (loaded from app bundle)
    public let actionImage: String

    /// Background color property, used to optionally wrap elements in a colored background.
    /// Supports values like "redSurfaceMinimal", "orangeSurfaceMinimal", "blueSurfaceMinimal".
    /// Empty string or not set means no background.
    public let backgroundColor: String

    /// internalArticle is a reference to another article. It is used to link articles to eachother.
    public var internalArticle: VGRContent?

    /// Added in order to exclude id from Codable protocol and conform to Identifiable
    enum CodingKeys: String, CodingKey {
        case type
        case text, title, subtitle
        case imageUrl, imageHeight, padding
        case internalId, readTime, date, videoUrl, videoId, publishDate, list
        case url, urlTitle
        case tags, links
        case a11y, crop, cropRadius
        case question, answer
        case feedbackOptions
        case backgroundColor
        case actionId, actionHeader, actionDescription, actionButtonLabel, actionButtonA11yLabel, actionImage
    }

    /// Decode manually to avoid optionals
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.type = try values.decode(VGRContentElementType.self, forKey: .type)
        self.text = try values.decodeIfPresent(String.self, forKey: .text) ?? ""
        self.url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
        self.urlTitle = try values.decodeIfPresent(String.self, forKey: .urlTitle) ?? ""

        self.title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.imageHeight = try values.decodeIfPresent(Int.self, forKey: .imageHeight) ?? 0
        self.internalId = try values.decodeIfPresent(String.self, forKey: .internalId) ?? ""
        self.readTime = try values.decodeIfPresent(String.self, forKey: .readTime) ?? ""
        self.date = try values.decodeIfPresent(String.self, forKey: .date) ?? ""

        self.videoUrl = try values.decodeIfPresent(String.self, forKey: .videoUrl) ?? ""
        self.videoId = try values.decodeIfPresent(String.self, forKey: .videoId) ?? ""

        self.question = try values.decodeIfPresent(String.self, forKey: .question) ?? ""
        self.answer = try values.decodeIfPresent(String.self, forKey: .answer) ?? ""
        self.feedbackOptions = try values.decodeIfPresent([String].self, forKey: .feedbackOptions) ?? []
        self.backgroundColor = try values.decodeIfPresent(String.self, forKey: .backgroundColor) ?? ""

        // Action callout properties
        self.actionId = try values.decodeIfPresent(String.self, forKey: .actionId) ?? ""
        self.actionHeader = try values.decodeIfPresent(String.self, forKey: .actionHeader) ?? ""
        self.actionDescription = try values.decodeIfPresent(String.self, forKey: .actionDescription) ?? ""
        self.actionButtonLabel = try values.decodeIfPresent(String.self, forKey: .actionButtonLabel) ?? ""
        self.actionButtonA11yLabel = try values.decodeIfPresent(String.self, forKey: .actionButtonA11yLabel) ?? ""
        self.actionImage = try values.decodeIfPresent(String.self, forKey: .actionImage) ?? ""

        self.list = try values.decodeIfPresent([String].self, forKey: .list) ?? []
        self.tags = try values.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.padding = try values.decodeIfPresent([Int].self, forKey: .tags) ?? []

        self.a11y = try values.decodeIfPresent(String.self, forKey: .a11y) ?? ""
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
                urlTitle: String = "",
                title: String = "",
                subtitle: String = "",
                imageUrl: String = "",
                imageHeight: Int = 0,
                readTime: String = "",
                date: String = "",
                videoUrl: String = "",
                videoId: String = "",
                publishDate: Date = Date(),
                list: [String] = [],
                tags: [String] = [],
                padding: [Int] = [],
                a11y: String = "",
                crop: [VGREdge] = [],
                cropRadius: Int = 0,
                links: [VGRContentElement] = [],
                internalArticle: VGRContent? = nil,
                question: String = "",
                answer: String = "",
                feedbackOptions: [String] = [],
                backgroundColor: String = "",
                actionId: String = "",
                actionHeader: String = "",
                actionDescription: String = "",
                actionButtonLabel: String = "",
                actionButtonA11yLabel: String = "",
                actionImage: String = "") {

        self.type = type
        self.text = text
        self.url = url
        self.urlTitle = urlTitle
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.imageHeight = imageHeight
        self.internalId = ""
        self.readTime = readTime
        self.date = date
        self.videoUrl = videoUrl
        self.videoId = videoId
        self.publishDate = publishDate
        self.list = list
        self.tags = tags
        self.padding = padding
        self.a11y = a11y
        self.crop = crop
        self.cropRadius = cropRadius
        self.links = links
        self.internalArticle = internalArticle

        self.question = question
        self.answer = answer
        self.feedbackOptions = feedbackOptions
        self.backgroundColor = backgroundColor
        self.actionId = actionId
        self.actionHeader = actionHeader
        self.actionDescription = actionDescription
        self.actionButtonLabel = actionButtonLabel
        self.actionButtonA11yLabel = actionButtonA11yLabel
        self.actionImage = actionImage
    }
}


extension VGRContentElement {

    var paddingEdgeInsets: EdgeInsets {
        /// No insets
        if self.padding.count == 0 {
            return EdgeInsets()
        }

        /// Assert we have 4 values
        if self.padding.count != 4 {
            return EdgeInsets()
        }

        /// Parse
        let top = CGFloat(self.padding[0])
        let leading = CGFloat(self.padding[1])
        let bottom = CGFloat(self.padding[2])
        let trailing = CGFloat(self.padding[3])
        return EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }

}
