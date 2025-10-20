# VGRVideoStatusService

A generic, reusable service for tracking watched video status across any app using the VGR Design System.

## Overview

The `VGRVideoStatusService` provides a simple way to:
- Track which videos users have watched (85% completion threshold)
- Persist watched status to UserDefaults
- Display checkmarks on watched videos in carousels and cards
- Work seamlessly with `VGRVideoPlayerView`, `VGRVideoCarousel`, and `VGRContentVideoView`
- **Automatically isolate video data per app** using bundle identifiers

## Quick Start

### Zero Configuration (Recommended)

The service works automatically with no setup required! It uses your app's bundle identifier to create isolated storage:

```swift
// That's it - no configuration needed!
// The service automatically uses:
// - Bundle ID: com.vgregion.myapp
// - UserDefaults key: com.vgregion.myapp.watchedVideos

// Just use the video components:
VGRVideoCarousel(title: "Videos", subtitle: "Series", items: videos) { video in
    showVideo(video)
}
```

All video components automatically:
- Mark videos as watched when reaching 85%
- Show checkmarks on watched videos
- Persist to UserDefaults with app-specific keys
- **Never conflict with other VGR apps** on the same device

### Custom Configuration (Optional)

Only needed if you want to customize the UserDefaults key:

```swift
// In your app's initialization (AppDelegate or @main struct)
VGRVideoStatusService.configure(userDefaultsKey: "myCustomKey.watchedVideos")
```

## Automatic App Isolation

Each app automatically gets its own isolated storage using bundle identifiers:

| App Bundle Identifier | Automatic UserDefaults Key |
|----------------------|----------------------------|
| `com.vgregion.hudapp` | `com.vgregion.hudapp.watchedVideos` |
| `com.vgregion.epilepsiapp` | `com.vgregion.epilepsiapp.watchedVideos` |
| `com.vgregion.migraineapp` | `com.vgregion.migraineapp.watchedVideos` |

**This means:**
- ✅ No conflicts between apps with the same video IDs
- ✅ Each app maintains its own watched video list
- ✅ No configuration required for isolation
- ✅ Works automatically for all VGR apps

## Usage Examples

### Example 1: Basic Usage (Zero Configuration)

```swift
import SwiftUI
import DesignSystem

@main
struct MyApp: App {
    // No initialization needed!

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct VideoListView: View {
    let videos: [VGRContentElement]

    var body: some View {
        ScrollView {
            ForEach(videos) { video in
                // Automatically shows checkmark if watched
                VGRContentVideoView(element: video)
            }
        }
    }
}
```

### Example 2: Using VideoCarousel

```swift
struct LearnMoreView: View {
    let videos: [Video]
    @State private var selectedVideo: Video?

    var body: some View {
        VGRVideoCarousel(
            title: "Video Series",
            subtitle: "Learn about health topics",
            items: videos,
            onItemTapped: { video in
                selectedVideo = video as? Video
            }
        )
        .sheet(item: $selectedVideo) { video in
            NavigationStack {
                VGRVideoPlayerView(
                    title: video.title,
                    videoUrl: video.url,
                    videoId: video.id
                )
            }
        }
    }
}
```

### Example 3: With Custom Configuration

```swift
@main
struct MyApp: App {
    init() {
        // Only if you need a custom key
        VGRVideoStatusService.configure(userDefaultsKey: "myCustomKey")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## API Reference

### VGRVideoStatusService

```swift
// Optional: Configure with custom key (if not called, uses bundle ID automatically)
VGRVideoStatusService.configure(userDefaultsKey: "myCustomKey")

// Mark a video as watched
VGRVideoStatusService.shared.markAsWatched(videoId: "video-123")

// Check if watched
let isWatched = VGRVideoStatusService.shared.isWatched(videoId: "video-123")

// Remove from watched
VGRVideoStatusService.shared.markAsUnwatched(videoId: "video-123")

// Clear all watched videos
VGRVideoStatusService.shared.clearAll()

// Observe changes in SwiftUI
@ObservedObject var videoService = VGRVideoStatusService.shared
```

### VGRVideoPlayerView

```swift
// With VGRContentElement
VGRVideoPlayerView(element: contentElement)

// With direct parameters
VGRVideoPlayerView(
    title: "My Video",
    videoUrl: "https://...",
    videoId: "video-123"
)
```

Automatically marks videos as watched at 85% completion using `VGRVideoStatusService.shared`.

### VGRContentVideoView

```swift
VGRContentVideoView(element: contentElement)
```

Automatically:
- Shows checkmark if video is watched
- Opens `VGRVideoPlayerView` in a sheet
- Uses `VGRVideoStatusService.shared` for watched status

### VGRVideoCarousel

```swift
VGRVideoCarousel(
    title: "Videos",
    subtitle: "Learn more",
    items: videos,
    onItemTapped: { video in /* ... */ }
)
```

Automatically shows checkmarks on watched videos using `VGRVideoStatusService.shared`.

## App Groups (Multi-App Sync)

To sync watched status across multiple apps using App Groups:

```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.mycompany.apps")!
let service = VGRVideoStatusService(
    userDefaultsKey: "watchedVideos",
    userDefaults: sharedDefaults
)
```

## Testing

```swift
// Create a test instance with isolated storage
let testService = VGRVideoStatusService(
    userDefaultsKey: "test.watchedVideos",
    userDefaults: UserDefaults(suiteName: "test")!
)

testService.markAsWatched(videoId: "test-video")
XCTAssertTrue(testService.isWatched(videoId: "test-video"))
```

## Migration Guide

### From Hardcoded UserDefaults Keys

Before:
```swift
UserDefaults.standard.set(watchedVideos, forKey: "viewedVideos")
let watched = UserDefaults.standard.stringArray(forKey: "viewedVideos") ?? []
```

After:
```swift
// Option 1: Use default (automatic bundle ID-based key)
// No configuration needed!

// Option 2: Keep your existing key for backwards compatibility
VGRVideoStatusService.configure(userDefaultsKey: "viewedVideos")
```

### From Custom Service

**Recommended:** Replace your custom `ContentStatusService` with `VGRVideoStatusService`:

Before:
```swift
class ContentStatusService: ObservableObject {
    static let shared = ContentStatusService()
    @Published var watchedVideos: [String] = []

    func addWatchedVideo(videoId: String) {
        watchedVideos.append(videoId)
        UserDefaults.standard.set(watchedVideos, forKey: "viewedVideos")
    }
}
```

After:
```swift
// Just use VGRVideoStatusService.shared
// If you need the same key for backwards compatibility:
VGRVideoStatusService.configure(userDefaultsKey: "viewedVideos")

// All your existing watched videos will be preserved!
```
