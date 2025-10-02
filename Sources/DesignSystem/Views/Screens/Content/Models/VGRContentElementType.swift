import Foundation

/// `VGRContentElementType` describes the element type inside the `VGRContent.elements` array.
/// This enum is a string and should be automatically decoded alongside its containing `VGRContent`.
public enum VGRContentElementType: String, Codable {
    /// Body text element, used for paragraphs. Used with the `text` property.
    case body

    /// Subhead is preamble type paragraph formatting. Used with the `text` property.
    case subhead

    /// H1 header element. Used with the `text` property.
    case h1

    /// H2 header element. Used with the `text` property.
    case h2

    /// H3 header element. Used with the `text` property.
    case h3

    /// Heading element. Used with the `text` property.
    case heading

    /// Image element, Used with the `url` property.
    case image

    /// Internal link to other `VGRContent` using its `id`.
    /// This type is used with the `title`, `subtitle`, `imageUrl` and `internalId` properties.
    /// This should render a link to another `VGRContent` using the `VGRContentCard`.
    case internalLink

    /// Internal link to other `VGRContent` using its `id`.
    /// IMPORTANT! The target article needs to be of type `.videofeed`.
    /// This should render a video carousel inside the `VGRContentScreen` displaying the videos in the target `VGRContent` using a video carousel component.
    case internalVideoSelectorLink

    /// Link element has the `text` and `url`elements set and this should be used to link to external websites
    case link

    /// Video element has the `videoId`, `title`, `readTime`, `publishDate` and `videoUrl` properties set
    /// and this should suffice to trigger a videoplayer aswell as display a video element as a card
    case video

    /// List element is used for bulleted lists, it should have the `list` property set
    case list

    /// FAQ element is used for question and answer sections. It expects the `question` and  `answer` properties to be set.
    /// It should render using a disclosure group either as a standalone element or integrated into `VGRContentScreen`
    case faq
}
