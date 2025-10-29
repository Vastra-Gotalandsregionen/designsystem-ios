import Foundation

/// Represents the watch status of a video.
public enum VGRVideoWatchStatus: Equatable {
    /// The video has not been started or watched.
    case notWatched

    /// The video was started but not completed (less than 85% watched).
    case partiallyWatched

    /// The video was watched to completion (85% or more).
    case completed

    /// Accessibility label describing the watch status.
    public var accessibilityLabel: String {
        switch self {
        case .notWatched:
            return "videocard.status.notwatched".localizedBundle
        case .partiallyWatched:
            return "videocard.status.partiallywatched".localizedBundle
        case .completed:
            return "videocard.status.completed".localizedBundle
        }
    }
}

/// A service for tracking and persisting watched video status.
///
/// This service manages which videos have been watched by the user, persisting
/// the data to UserDefaults. Apps can use a shared instance or create their own
/// with a custom UserDefaults key.
///
/// The service tracks three states:
/// - **Not watched**: Video hasn't been started
/// - **Partially watched**: Video was started but didn't reach 85%
/// - **Completed**: Video reached 85% completion
///
/// Example usage:
/// ```swift
/// // Mark video as started (partially watched)
/// VGRVideoStatusService.shared.markAsPartiallyWatched(videoId: "video-123")
///
/// // Mark video as completed (85%+)
/// VGRVideoStatusService.shared.markAsWatched(videoId: "video-123")
///
/// // Check status
/// let status = VGRVideoStatusService.shared.watchStatus(for: "video-123")
/// ```
@MainActor
@Observable
public class VGRVideoStatusService {

    /// The shared singleton instance.
    public static let shared = VGRVideoStatusService()

    /// Published array of completed video IDs that views can observe.
    public private(set) var completedVideoIds: [String] = []

    /// Published array of partially watched video IDs that views can observe.
    public private(set) var partiallyWatchedVideoIds: [String] = []

    /// The UserDefaults key used to persist completed videos.
    private var completedVideosStorageKey: String

    /// The UserDefaults key used to persist partially watched videos.
    private var partiallyWatchedVideosStorageKey: String

    /// The UserDefaults instance to use for persistence.
    private let userDefaults: UserDefaults

    /// Creates a new video status service with the specified configuration.
    /// - Parameters:
    ///   - completedVideosKey: The key to use for storing completed videos in UserDefaults.
    ///                         If not specified, uses the app's bundle identifier + ".watchedVideos"
    ///   - partiallyWatchedVideosKey: The key to use for storing partially watched videos in UserDefaults.
    ///                                If not specified, uses the app's bundle identifier + ".partiallyWatchedVideos"
    ///   - userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    public init(
        completedVideosKey: String? = nil,
        partiallyWatchedVideosKey: String? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        // Use app's bundle identifier if no keys specified
        let defaultCompletedKey: String
        let defaultPartialKey: String

        if let bundleId = Bundle.main.bundleIdentifier {
            defaultCompletedKey = "\(bundleId).watchedVideos"
            defaultPartialKey = "\(bundleId).partiallyWatchedVideos"
        } else {
            defaultCompletedKey = "com.vgregion.designsystem.watchedVideos"
            defaultPartialKey = "com.vgregion.designsystem.partiallyWatchedVideos"
        }

        self.completedVideosStorageKey = completedVideosKey ?? defaultCompletedKey
        self.partiallyWatchedVideosStorageKey = partiallyWatchedVideosKey ?? defaultPartialKey
        self.userDefaults = userDefaults

        // Load initial data synchronously
        self.completedVideoIds = userDefaults.stringArray(forKey: self.completedVideosStorageKey) ?? []
        self.partiallyWatchedVideoIds = userDefaults.stringArray(forKey: self.partiallyWatchedVideosStorageKey) ?? []
    }

    /// Configures the shared instance with custom UserDefaults keys.
    ///
    /// This is optional - if not called, the service automatically uses your app's
    /// bundle identifier (e.g., "com.mycompany.myapp.watchedVideos" and "com.mycompany.myapp.partiallyWatchedVideos").
    ///
    /// Only call this if you need specific custom keys, such as for backwards compatibility with existing storage.
    /// - Parameters:
    ///   - completedVideosKey: The key to use for storing completed videos.
    ///   - partiallyWatchedVideosKey: The key to use for storing partially watched videos.
    public static func configure(
        completedVideosKey: String,
        partiallyWatchedVideosKey: String
    ) {
        shared.completedVideosStorageKey = completedVideosKey
        shared.partiallyWatchedVideosStorageKey = partiallyWatchedVideosKey
        shared.completedVideoIds = shared.userDefaults.stringArray(forKey: completedVideosKey) ?? []
        shared.partiallyWatchedVideoIds = shared.userDefaults.stringArray(forKey: partiallyWatchedVideosKey) ?? []
    }

    /// Returns the watch status for a given video.
    /// - Parameter videoId: The unique identifier of the video.
    /// - Returns: The watch status (notWatched, partiallyWatched, or completed).
    public func watchStatus(for videoId: String) -> VGRVideoWatchStatus {
        if completedVideoIds.contains(videoId) {
            return .completed
        } else if partiallyWatchedVideoIds.contains(videoId) {
            return .partiallyWatched
        } else {
            return .notWatched
        }
    }

    /// Marks a video as partially watched (started but not completed).
    ///
    /// This is automatically called when a user starts watching a video.
    /// If the video is already marked as completed, this does nothing.
    /// - Parameter videoId: The unique identifier of the video.
    public func markAsPartiallyWatched(videoId: String) {
        guard !videoId.isEmpty else { return }

        // Don't downgrade completed videos to partially watched
        if completedVideoIds.contains(videoId) {
            return
        }

        // Add to partially watched if not already there
        if !partiallyWatchedVideoIds.contains(videoId) {
            partiallyWatchedVideoIds.append(videoId)
            savePartiallyWatchedVideos()
        }
    }

    /// Marks a video as watched (completed at 85% or more).
    ///
    /// This is automatically called when a video reaches 85% completion.
    /// If the video was previously marked as partially watched, it's moved to completed.
    /// - Parameter videoId: The unique identifier of the video.
    public func markAsWatched(videoId: String) {
        guard !videoId.isEmpty else { return }

        // Remove from partially watched if it's there
        partiallyWatchedVideoIds.removeAll { $0 == videoId }

        // Add to completed if not already there
        if !completedVideoIds.contains(videoId) {
            completedVideoIds.append(videoId)
        }

        saveCompletedVideos()
        savePartiallyWatchedVideos()
    }

    /// Checks if a video has been watched (completed).
    /// - Parameter videoId: The unique identifier of the video.
    /// - Returns: `true` if the video has been watched, `false` otherwise.
    @available(*, deprecated, message: "Use watchStatus(for:) instead for more granular state")
    public func isWatched(videoId: String) -> Bool {
        completedVideoIds.contains(videoId)
    }

    /// Removes a video from both completed and partially watched lists.
    /// - Parameter videoId: The unique identifier of the video.
    public func markAsUnwatched(videoId: String) {
        completedVideoIds.removeAll { $0 == videoId }
        partiallyWatchedVideoIds.removeAll { $0 == videoId }
        saveCompletedVideos()
        savePartiallyWatchedVideos()
    }

    /// Clears all completed and partially watched videos.
    public func clearAll() {
        completedVideoIds.removeAll()
        partiallyWatchedVideoIds.removeAll()
        saveCompletedVideos()
        savePartiallyWatchedVideos()
    }

    // MARK: - Private Methods

    private func saveCompletedVideos() {
        userDefaults.set(completedVideoIds, forKey: completedVideosStorageKey)
    }

    private func savePartiallyWatchedVideos() {
        userDefaults.set(partiallyWatchedVideoIds, forKey: partiallyWatchedVideosStorageKey)
    }
}
