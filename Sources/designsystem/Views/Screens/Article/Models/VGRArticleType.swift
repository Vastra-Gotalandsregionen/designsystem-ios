import Foundation

public enum VGRArticleType: String, Decodable {
    case article
    case learn
    case tips
    case useragreement
    case privacypolicy

    /// Decode manually to avoid optionals
    public init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        if let type = VGRArticleType(rawValue: rawValue) {
            self = type
        } else {
            self = .article
        }
    }
}
