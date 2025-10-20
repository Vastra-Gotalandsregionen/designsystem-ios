import Foundation
import Combine

/// A service for tracking and persisting watched video status.
///
/// This service manages which videos have been watched by the user, persisting
/// the data to UserDefaults. Apps can use a shared instance or create their own
/// with a custom UserDefaults key.
///
/// Example usage:
/// ```swift
/// // Configure once at app launch
/// VGRVideoStatusService.configure(userDefaultsKey: "com.myapp.watchedVideos")
///
/// // Mark video as watched
/// VGRVideoStatusService.shared.markAsWatched(videoId: "video-123")
///
/// // Check if watched
/// let isWatched = VGRVideoStatusService.shared.isWatched(videoId: "video-123")
/// ```
@MainActor
public class VGRVideoStatusService: ObservableObject {

    /// The shared singleton instance.
    public static let shared = VGRVideoStatusService()

    /// Published array of watched video IDs that views can observe.
    @Published public private(set) var watchedVideoIds: [String] = []

    /// The UserDefaults key used to persist watched videos.
    private var userDefaultsKey: String

    /// The UserDefaults instance to use for persistence.
    private let userDefaults: UserDefaults

    /// Creates a new video status service with the specified configuration.
    /// - Parameters:
    ///   - userDefaultsKey: The key to use for storing watched videos in UserDefaults.
    ///                      If not specified, uses the app's bundle identifier + ".watchedVideos"
    ///   - userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    public init(
        userDefaultsKey: String? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        // Use app's bundle identifier if no key specified
        let defaultKey: String
        if let bundleId = Bundle.main.bundleIdentifier {
            defaultKey = "\(bundleId).watchedVideos"
        } else {
            defaultKey = "com.vgregion.designsystem.watchedVideos"
        }

        self.userDefaultsKey = userDefaultsKey ?? defaultKey
        self.userDefaults = userDefaults

        // Load initial data synchronously (safe since watchedVideoIds starts empty)
        self.watchedVideoIds = userDefaults.stringArray(forKey: self.userDefaultsKey) ?? []

        // Observe UserDefaults changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Configures the shared instance with a custom UserDefaults key.
    ///
    /// This is optional - if not called, the service automatically uses your app's
    /// bundle identifier + ".watchedVideos" (e.g., "com.mycompany.myapp.watchedVideos").
    ///
    /// Only call this if you need a specific custom key.
    /// - Parameter userDefaultsKey: The key to use for storing watched videos.
    public static func configure(userDefaultsKey: String) {
        shared.userDefaultsKey = userDefaultsKey
        shared.watchedVideoIds = shared.userDefaults.stringArray(forKey: userDefaultsKey) ?? []
    }

    /// Marks a video as watched.
    /// - Parameter videoId: The unique identifier of the video.
    public func markAsWatched(videoId: String) {
        guard !watchedVideoIds.contains(videoId), !videoId.isEmpty else { return }
        watchedVideoIds.append(videoId)
        saveWatchedVideos()
    }

    /// Checks if a video has been watched.
    /// - Parameter videoId: The unique identifier of the video.
    /// - Returns: `true` if the video has been watched, `false` otherwise.
    public func isWatched(videoId: String) -> Bool {
        watchedVideoIds.contains(videoId)
    }

    /// Removes a video from the watched list.
    /// - Parameter videoId: The unique identifier of the video.
    public func markAsUnwatched(videoId: String) {
        watchedVideoIds.removeAll { $0 == videoId }
        saveWatchedVideos()
    }

    /// Clears all watched videos.
    public func clearAll() {
        watchedVideoIds.removeAll()
        saveWatchedVideos()
    }

    // MARK: - Private Methods

    @objc private func userDefaultsDidChange() {
        watchedVideoIds = userDefaults.stringArray(forKey: userDefaultsKey) ?? []
    }

    private func saveWatchedVideos() {
        userDefaults.set(watchedVideoIds, forKey: userDefaultsKey)
    }
}
