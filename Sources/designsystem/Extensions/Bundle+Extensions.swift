import Foundation

extension Bundle {

    /// The application's name as defined in the Info.plist (`CFBundleName`).
    public var appName: String { getInfo("CFBundleName") }

    /// The application's display name as defined in the Info.plist (`CFBundleDisplayName`).
    public var displayName: String { getInfo("CFBundleDisplayName") }

    /// The primary language or development region of the application (`CFBundleDevelopmentRegion`).
    public var language: String { getInfo("CFBundleDevelopmentRegion") }

    /// The unique bundle identifier of the application (`CFBundleIdentifier`).
    public var identifier: String { getInfo("CFBundleIdentifier") }

    /// The copyright information as defined in the Info.plist (`NSHumanReadableCopyright`).
    /// This property replaces occurrences of `\\n` with actual newlines for better readability.
    public var copyright: String { getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n") }

    /// The build number of the application (`CFBundleVersion`).
    public var appBuild: String { getInfo("CFBundleVersion") }

    /// The full version number of the application (`CFBundleShortVersionString`).
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }

    /// Retrieves a value from the application's Info.plist.
    /// - Parameter key: The key corresponding to the desired value.
    /// - Returns: The value as a `String`, or an empty string if the key does not exist.
    fileprivate func getInfo(_ key: String) -> String { infoDictionary?[key] as? String ?? "" }
}
