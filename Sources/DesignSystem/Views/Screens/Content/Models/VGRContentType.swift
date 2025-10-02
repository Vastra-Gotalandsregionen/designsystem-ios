import Foundation

public enum VGRContentType: String, Decodable {
    /// Regular article, structured with headers, subheaders, lists and body texts
    case article

    /// Tips articles, shorter form, mainly for in-app use. Structurally same as `learn` and  `article`
    case tips

    /// User agreement, structurally same as `article` and `learn`
    case useragreement

    /// Privacy policy, structurally same as `article` and `learn`
    case privacypolicy

    /// FAQ article. Contains one or more elements with both question and answer.
    case faq

    /// Video feed article. Contains one or more elements with video clips.
    case videofeed

    /// Decode manually to avoid optionals
    public init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        if let type = VGRContentType(rawValue: rawValue) {
            self = type
        } else {
            self = .article
        }
    }
}
