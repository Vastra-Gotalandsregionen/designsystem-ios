import Foundation
import SwiftUI
import OSLog

/// Service for managing WhatsNew version data and tracking which versions the user has seen.
/// Loads version data from an NSDataAsset JSON file and persists seen-state via UserDefaults.
/// Migrated from migraine-ios `WhatsNewService`.
///
/// Usage:
/// ```swift
/// let service = VGRWhatsNewService(
///     assetName: "version_content",
///     userDefaultsKey: "viewedNews"
/// )
/// let unseen = service.getAllUnseenVersions()
/// ```
@Observable
public class VGRWhatsNewService {
    private let logger = Logger(subsystem: "VGRWhatsNewService", category: "Service")

    /// The UserDefaults key used to persist the array of seen version IDs
    private let userDefaultsKey: String

    /// All versions loaded from the data asset
    public private(set) var versions: [VGRWhatsNewVersion] = []

    /// The list of version IDs that the user has already seen
    public private(set) var seenVersions: [String] = []

    /// - Parameters:
    ///   - assetName: The name of the NSDataAsset containing the version JSON (e.g. "version_content")
    ///   - userDefaultsKey: The UserDefaults key for storing seen version IDs
    public init(assetName: String, userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
        versions = readVersionAsset(assetName: assetName)
        seenVersions = readSeenVersions()
    }

    // MARK: - Seen version tracking

    /// Reads the list of seen version IDs from UserDefaults
    func readSeenVersions() -> [String] {
        return UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
    }

    /// Returns the current list of seen version IDs
    public func getSeenVersions() -> [String] {
        return seenVersions
    }

    /// Overwrites the seen versions list in UserDefaults
    public func setSeenVersions(_ seenVersions: [String]) {
        UserDefaults.standard.setValue(seenVersions, forKey: userDefaultsKey)
    }

    /// Marks a version as seen so it won't appear in unseen lists
    public func dismissVersion(_ versionId: String) {
        guard !seenVersions.contains(versionId), !versionId.isEmpty else { return }
        seenVersions.append(versionId)
        UserDefaults.standard.set(seenVersions, forKey: userDefaultsKey)

    }

    /// Marks a version as unseen so it will appear again. Useful for developer/tester menus.
    public func undismissVersion(_ versionId: String) {
        seenVersions.removeAll { $0 == versionId }
        UserDefaults.standard.set(seenVersions, forKey: userDefaultsKey)

    }

    /// Resets all seen versions, making every version appear as unseen. Useful for developer/tester menus.
    public func resetAllSeenVersions() {
        seenVersions.removeAll()
        UserDefaults.standard.set(seenVersions, forKey: userDefaultsKey)

    }

    // MARK: - Version queries

    /// Returns unseen versions, up to `maxCount`
    public func getAllUnseenVersions(_ maxCount: Int = 2) -> [VGRWhatsNewVersion] {
        let unseen = versions.filter { version in
            !seenVersions.contains(version.id)
        }
        return Array(unseen.prefix(maxCount))
    }

    /// Returns all available version IDs
    public func getAllVersions() -> [String] {
        return versions.map { $0.id }
    }

    // MARK: - Deserialization

    /// Generic asset loader that decodes a JSON array from an NSDataAsset
    func readAsset<T: Decodable>(assetName: String) -> [T] {
        guard let jsonData = NSDataAsset(name: assetName) else {
            logger.warning("Failed loading asset '\(assetName)'")
            return []
        }
        do {
            return try JSONDecoder().decode([T].self, from: jsonData.data)
        } catch {
            logger.error("Failed deserializing asset '\(assetName)': \(error.localizedDescription)")
            return []
        }
    }

    /// Loads and returns versions from the named data asset
    func readVersionAsset(assetName: String) -> [VGRWhatsNewVersion] {
        return readAsset(assetName: assetName)
    }
}
