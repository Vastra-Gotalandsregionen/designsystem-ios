import Foundation

/// `VGRContentElementType` describes the element type inside the `VGRContent.elements` array.
/// This enum is a string and should be automatically decoded alongside its containing `VGRContent`.
public enum VGRContentElementType: String, Codable {
    /// Body text element, used for paragraphs. Used with the `text` property.
    case body

    /// Subhead is preamble type paragraph formatting. Used with the `text` property.
    case subhead

    /// Footnote. Used with the `text` property.
    case footnote

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

    /// Link element has the `text` and `url`elements set and this should be used to link to external websites using an external browser
    case link

    /// WebviewLink has the `text` and `url`elements set and this should be used to link to external websites using the internal webview
    case webviewLink

    /// LinkGroup has the `links` element set and it should contain other `VGRContentElement` with two possible element types: `.link` and `.webviewLink`
    case linkGroup

    /// Video element has the `videoId`, `title`,  `subtitle` (optional), `readTime`, `publishDate` and `videoUrl` properties set
    /// and this should suffice to trigger a videoplayer aswell as display a video element as a card
    case video

    /// List element is used for bulleted lists, it should have the `list` property set
    case list

    /// Ordered element is a list where the items are presented in a numbered/ordered fashion
    case ordered

    /// FAQ element is used for question and answer sections. It expects the `question` and  `answer` properties to be set.
    /// It should render using a disclosure group either as a standalone element or integrated into `VGRContentScreen`
    case faq

    /// Feedback element displays a "Was this helpful?" prompt with Yes/No buttons.
    /// If user selects No, a sheet appears with selectable reasons.
    /// Expects the `feedbackOptions` property to contain an array of option keys that match `VGRFeedbackOption` cases.
    case feedback

    /// Generic action callout element displays a callout with configurable content.
    /// When the button is tapped, it triggers a callback with the actionId, allowing the consuming app to handle navigation.
    /// Expects `actionId`, `actionHeader`, `actionDescription`, `actionButtonLabel`, `actionButtonA11yLabel`, and `actionImage` properties.
    case actionCallout
}
