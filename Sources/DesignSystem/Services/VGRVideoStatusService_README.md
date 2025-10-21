# VGRVideoStatusService

A service for tracking video watch status with automatic persistence to UserDefaults.

## Quick Start

**Zero configuration required!** The service automatically tracks video status using your app's bundle identifier for isolation.

```swift
// Just use the video components - everything happens automatically:
VGRVideoCarousel(title: "Videos", subtitle: "Series", items: videos) { video in
    showVideo(video)
}
```

## Watch Status States

| State | Visual Indicator | When Applied |
|-------|------------------|--------------|
| **Not Watched** | Brown stop icon | Default state |
| **Partially Watched** | Orange pause icon | When playback starts |
| **Completed** | Green checkmark | At 85% completion |

### Automatic Behavior
1. User taps video → Opens in `VGRVideoPlayerView`
2. Playback starts → Marked as `.partiallyWatched`
3. Reaches 85% → Moved to `.completed`
4. Visual feedback → Icons update automatically

**Note:** Completed videos cannot be downgraded to partially watched.

## API Reference

### VGRVideoWatchStatus

```swift
public enum VGRVideoWatchStatus: Equatable {
    case notWatched        // Video hasn't been started
    case partiallyWatched  // Started but < 85%
    case completed         // Watched to 85%+
}
```

### Common Methods

```swift
// Get watch status
let status = VGRVideoStatusService.shared.watchStatus(for: "video-123")

// Mark as partially watched (auto-called on playback start)
VGRVideoStatusService.shared.markAsPartiallyWatched(videoId: "video-123")

// Mark as completed (auto-called at 85%)
VGRVideoStatusService.shared.markAsWatched(videoId: "video-123")

// Reset status
VGRVideoStatusService.shared.markAsUnwatched(videoId: "video-123")

// Clear all
VGRVideoStatusService.shared.clearAll()
```

### Observing Changes

```swift
@ObservedObject var videoService = VGRVideoStatusService.shared

// Access arrays
let completed = videoService.completedVideoIds
let partial = videoService.partiallyWatchedVideoIds
```

## Advanced Usage

### Custom UserDefaults Keys

For backwards compatibility with existing apps or custom storage needs:

```swift
VGRVideoStatusService.configure(
    completedVideosKey: "viewedVideos",           // Your existing key
    partiallyWatchedVideosKey: "partiallyViewed"  // New key for partial state
)
```
