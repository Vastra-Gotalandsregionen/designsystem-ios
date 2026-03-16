import Foundation

/// A semantic versioning (SemVer) representation with major, minor, and patch components.
/// Supports parsing from strings (e.g. "1.4.5"), comparison, and equality.
/// Migrated from migraine-ios `Semver`.
public struct VGRSemver: Equatable, Comparable, CustomStringConvertible, Decodable, Hashable {

    /// Errors that can occur when parsing a semver string
    public enum Errors: Error {
        case invalidInput(String)
    }

    /// The major version number
    public let major: Int

    /// The minor version number
    public let minor: Int

    /// The patch version number
    public let patch: Int

    /// Initialize with explicit version components
    public init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Initialize by parsing a semver string (e.g. "1.4.5")
    /// - Throws: `Errors.invalidInput` if the string is not a valid semver
    public init(_ version: String) throws {
        let parts = version.split(separator: ".")
        guard parts.count == 3,
              let major = Int(parts[0]),
              let minor = Int(parts[1]),
              let patch = Int(parts[2]) else {
            throw Errors.invalidInput(version)
        }
        self.init(major, minor, patch)
    }

    public var description: String {
        "\(major).\(minor).\(patch)"
    }

    public static func <(lhs: VGRSemver, rhs: VGRSemver) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }

    public static func == (lhs: VGRSemver, rhs: VGRSemver) -> Bool {
        lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}
