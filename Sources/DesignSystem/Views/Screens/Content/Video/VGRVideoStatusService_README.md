# VGRVideoStatusService

A service for tracking video watch status with persistence to UserDefaults. The video components in the design system (`VGRVideoCarousel`, `VGRVideoListScreen`, `VGRVideoCard`, `VGRContentVideoView`) read from the shared instance to render the status indicator on each card.

## Quick Start

Reading status is automatic. The carousel and list screen look up `VGRVideoStatusService.shared` for every item they render:

```swift
VGRVideoCarousel(title: "Videos", subtitle: "Series", items: videos) { video in
    selectedVideo = video
}
```

Writing status is the app's responsibility. `VGRVideoPlayer` reports when the watched threshold is reached, and the app forwards that to the service:

```swift
.fullScreenCover(item: $selectedVideo) { video in
    VGRVideoPlayer(
        url: video.url,
        onWatchedThresholdReached: {
            VGRVideoStatusService.shared.markAsWatched(videoId: video.id)
        },
        onDismiss: {
            DispatchQueue.main.async { selectedVideo = nil }
        }
    )
    .ignoresSafeArea()
    .onAppear {
        VGRVideoStatusService.shared.markAsPartiallyWatched(videoId: video.id)
    }
}
```

The `VGRContentVideoView` and `VGRContentVideoSelectorView` content elements already do this wiring internally.

> The deprecated `VGRVideoPlayerView` marked status on its own. `VGRVideoPlayer` replaced it for VoiceOver accessibility and deliberately leaves status writes to the caller.

## Watch Status States

| State | Visual Indicator | Meaning |
|-------|------------------|---------|
| `.notWatched` | Brown stop icon | Default state |
| `.partiallyWatched` | Orange pause icon | Started but below 85% |
| `.completed` | Green checkmark | Reached 85% or more |

`markAsPartiallyWatched` never downgrades a video that is already `.completed`.

## API Reference

### VGRVideoWatchStatus

```swift
public enum VGRVideoWatchStatus: Equatable {
    case notWatched
    case partiallyWatched
    case completed

    public var accessibilityLabel: String  // localized, used by VGRVideoCard
}
```

### Methods

```swift
// Read
let status = VGRVideoStatusService.shared.watchStatus(for: "video-123")

// Write
VGRVideoStatusService.shared.markAsPartiallyWatched(videoId: "video-123")
VGRVideoStatusService.shared.markAsWatched(videoId: "video-123")
VGRVideoStatusService.shared.markAsUnwatched(videoId: "video-123")
VGRVideoStatusService.shared.clearAll()
```

`isWatched(videoId:)` still exists but is deprecated in favor of `watchStatus(for:)`.

### Observing Changes

The service is `@MainActor @Observable`, not `ObservableObject`. Read its properties directly inside a view body and SwiftUI tracks them. Do not wrap it in `@ObservedObject` or `@StateObject`.

```swift
struct ProgressView: View {
    private let service = VGRVideoStatusService.shared

    var body: some View {
        Text("\(service.completedVideoIds.count) completed")
        Text("\(service.partiallyWatchedVideoIds.count) in progress")
    }
}
```

## Advanced Usage

### Custom UserDefaults Keys

For backwards compatibility with keys an app already uses, reconfigure the shared instance once at launch:

```swift
VGRVideoStatusService.configure(
    completedVideosKey: "viewedVideos",
    partiallyWatchedVideosKey: "partiallyViewed"
)
```

### Separate Instance

The initializer is public, so an app can hold its own instance with its own keys instead of the shared one. The built-in components always use `shared`, so a separate instance only affects views the app renders itself.
