import Foundation

/// Represents an app version that contains a set of changes to present to the user.
/// Decoded from a JSON data asset (e.g. `version_content`).
/// Migrated from migraine-ios `Version`.
public struct VGRWhatsNewVersion: Identifiable, Hashable, Equatable, Decodable {

    /// The version identifier as a semver string (e.g. "1.2.0")
    public let id: String

    /// A short summary title for this version
    public let title: String

    /// A longer summary description for this version
    public let body: String

    /// An optional image asset name for a summarized description
    public var image: String?

    /// The parsed semver, used for version comparisons
    public let semver: VGRSemver

    /// The array of change pages to display for this version
    public let changes: [VGRWhatsNewChange]

    enum CodingKeys: String, CodingKey {
        case id, changes, title, body, image
    }

    /// Initialize with just a version ID string (creates an empty version)
    public init(_ versionId: String) {
        self.id = versionId
        do {
            self.semver = try VGRSemver(versionId)
        } catch {
            self.semver = VGRSemver(0, 0, 0)
        }

        self.changes = []
        self.title = ""
        self.body = ""
        self.image = nil
    }

    /// Decode from JSON, parsing the `id` field into a `VGRSemver`
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        changes = try values.decode([VGRWhatsNewChange].self, forKey: .changes)
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        semver = try VGRSemver(id)

        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        body = try values.decodeIfPresent(String.self, forKey: .body) ?? ""
        image = try values.decodeIfPresent(String.self, forKey: .image)
    }
}
