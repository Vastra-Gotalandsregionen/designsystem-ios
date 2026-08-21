import SwiftUI

/// A screen that displays the videos of a video feed as a vertical list.
///
/// Every `.video` element in the content becomes a full-width card, in authoring order. It is the
/// list counterpart to ``VGRVideoCarousel`` — the same ``VGRVideoCard``, laid out horizontally —
/// for a screen that shows a whole feed rather than a few videos alongside an article.
///
/// Selection is handed to `onVideoSelected`, so the consuming app presents its own player and
/// records analytics. Unlike ``VGRContentVideoSelectorView`` this view never plays a video itself.
///
/// Navigation belongs to the app as well: the list fills the space it is given and sets no
/// navigation title.
public struct VGRVideoListScreen: View {

    /// The video feed whose `.video` elements fill the list.
    public let content: VGRContent

    /// Optional fixed color for all video card circles. If nil, colors cycle automatically.
    public let circleColor: Color?

    /// The background color behind the list.
    public let backgroundColor: Color

    /// Called with the selected video.
    public var onVideoSelected: (VGRVideo) -> Void

    private var videoStatusService = VGRVideoStatusService.shared

    /// Creates a video list screen from video feed content.
    /// - Parameters:
    ///   - content: The video feed, conventionally of type `.videofeed`.
    ///   - circleColor: Optional fixed color for all video card circles. If nil, colors cycle
    ///     through accent colors.
    ///   - backgroundColor: The background color behind the list.
    ///   - onVideoSelected: Called with the tapped video.
    public init(content: VGRContent,
                circleColor: Color? = nil,
                backgroundColor: Color = .Accent.brownSurfaceMinimal,
                onVideoSelected: @escaping (VGRVideo) -> Void) {
        self.content = content
        self.circleColor = circleColor
        self.backgroundColor = backgroundColor
        self.onVideoSelected = onVideoSelected
    }

    /// The `.video` elements of the content, in authoring order.
    private var items: [VGRVideo] {
        content.elements
            .filter { $0.type == .video }
            .map(VGRVideo.init)
    }

    /// Creates a tappable card for one video.
    /// - Parameters:
    ///   - index: The position of the video in the list, used for color rotation.
    ///   - video: The video to display.
    /// - Returns: A button containing the video card.
    private func card(index: Int, video: VGRVideo) -> some View {
        Button {
            Haptics.lightImpact()
            onVideoSelected(video)
        } label: {
            VGRVideoCard(
                title: video.title,
                subtitle: video.subtitle,
                duration: video.duration,
                circleColor: circleColor ?? VGRVideoCard.circleColor(at: index),
                watchStatus: videoStatusService.watchStatus(for: video.id),
                publishDate: video.publishDate,
                layout: .horizontal
            )
        }
        .buttonStyle(VGRVideoCardButtonStyle())
    }

    public var body: some View {
        VGRContainer {
            VGRShape(backgroundColor: backgroundColor) {
                LazyVStack(spacing: .Margins.medium) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, video in
                        card(index: index, video: video)
                    }
                }
            }
        }
    }
}

#Preview("Video list screen") {
    let videos = (1...6).map { index in
        VGRContentElement(
            type: .video,
            title: "Del \(index):",
            subtitle: "Vad är psoriasis?",
            readTime: "\(index + 2) minuter",
            videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            videoId: "sample-video-\(index)",
            publishDate: Calendar.current.date(byAdding: .day, value: -index * 5, to: Date()) ?? Date()
        )
    }

    let feed = VGRContent(
        title: "Videoklipp",
        subtitle: "Korta filmer om psoriasis",
        type: .videofeed,
        imageUrl: "",
        elements: videos
    )

    NavigationStack {
        VGRVideoListScreen(content: feed) { video in
            print("Selected \"\(video.title) \(video.subtitle)\"")
        }
        .navigationTitle("content.type.video".localizedBundle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
