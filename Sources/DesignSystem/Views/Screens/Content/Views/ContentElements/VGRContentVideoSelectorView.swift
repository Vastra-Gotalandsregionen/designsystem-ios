import SwiftUI

/// A view that displays the videos of a video feed as a horizontal carousel.
///
/// Every `.video` element in the content becomes a card in the carousel, and the content's
/// `title` and `subtitle` become the carousel header.
///
/// Reachable two ways. Inside a ``VGRContentScreen`` it renders a `.internalVideoSelectorLink`
/// element, which points at the video feed through its `internalId` — that reference must already
/// be resolved into `internalArticle` by the time the element is rendered. It can also be placed
/// on its own screen by passing the video feed content directly.
///
/// Selection is handed to `onVideoSelected` when the consuming app supplies one, so the app can
/// present its own player and record analytics. Without a callback the view plays the video itself,
/// matching ``VGRContentVideoView``.
///
/// A "show all" button below the carousel leads to the full video feed. It appears only when the
/// app supplies `onShowAll`, since only the app knows where that leads.
public struct VGRContentVideoSelectorView: View {

    /// The video feed whose `.video` elements fill the carousel.
    public let content: VGRContent?

    /// Optional fixed color for all video card circles. If nil, colors cycle automatically.
    public let circleColor: Color?

    /// Called when the "show all" button is tapped. When nil, no button is shown.
    public var onShowAll: (() -> Void)?

    /// Called with the selected video. When nil, playback is handled by this view.
    public var onVideoSelected: ((VGRVideo) -> Void)?

    private var videoStatusService = VGRVideoStatusService.shared

    /// Creates a video selector for a `.internalVideoSelectorLink` element.
    /// - Parameters:
    ///   - element: The element whose `internalArticle` holds the videos. Renders nothing if that
    ///     reference has not been resolved.
    ///   - onShowAll: Called when "show all" is tapped. Pass nil to leave the button out.
    ///   - onVideoSelected: Called with the tapped video. Pass nil to let this view present
    ///     the player.
    public init(element: VGRContentElement,
                circleColor: Color? = nil,
                onShowAll: (() -> Void)? = nil,
                onVideoSelected: ((VGRVideo) -> Void)? = nil) {
        self.content = element.internalArticle
        self.circleColor = circleColor
        self.onShowAll = onShowAll
        self.onVideoSelected = onVideoSelected
    }

    /// Creates a video selector directly from video feed content, for use outside a
    /// ``VGRContentScreen``.
    /// - Parameters:
    ///   - content: The video feed, conventionally of type `.videofeed`.
    ///   - onShowAll: Called when "show all" is tapped. Pass nil to leave the button out.
    ///   - onVideoSelected: Called with the tapped video. Pass nil to let this view present
    ///     the player.
    public init(content: VGRContent,
                circleColor: Color? = nil,
                onShowAll: (() -> Void)? = nil,
                onVideoSelected: ((VGRVideo) -> Void)? = nil) {
        self.content = content
        self.circleColor = circleColor
        self.onShowAll = onShowAll
        self.onVideoSelected = onVideoSelected
    }

    @State private var playingVideo: VGRVideo?

    /// The `.video` elements of the content, in authoring order.
    private var videos: [VGRContentElement] {
        content?.elements.filter { $0.type == .video } ?? []
    }

    private var items: [VGRVideo] {
        videos.map(VGRVideo.init)
    }

    private func select(_ item: any VGRVideoCarouselItem) {
        guard let video = items.first(where: { $0.id == item.id }) else { return }

        if let onVideoSelected {
            onVideoSelected(video)
        } else {
            playingVideo = video
        }
    }

    public var body: some View {
        if let content, !videos.isEmpty {
            VStack(alignment: .trailing, spacing: .Margins.medium) {
                VGRVideoCarousel(
                    title: content.title,
                    subtitle: content.subtitle,
                    items: items,
                    circleColor: circleColor,
                    onItemTapped: select
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .fullScreenCover(item: $playingVideo) { video in
                    if let url = URL(string: video.url) {
                        VGRVideoPlayer(
                            url: url,
                            onWatchedThresholdReached: {
                                videoStatusService.markAsWatched(videoId: video.id)
                            },
                            onDismiss: {
                                playingVideo = nil
                            }
                        )
                        .ignoresSafeArea()
                    }
                }

                if let onShowAll {
                    VGRButtonV2(
                        "videocarousel.showall".localizedBundle,
                        variant: .secondary,
                        size: .small,
                        fullWidth: false,
                        action: onShowAll
                    )
                    .padding(.horizontal, .Margins.medium)
                }
            }
            .padding(.vertical, VGRSpacing.verticalXLarge)
        }
    }
}

#Preview("Video selector") {
    let videos = (1...4).map { index in
        VGRContentElement(
            type: .video,
            title: "Del \(index):",
            subtitle: "Vad är psoriasis?",
            readTime: "\(index + 2) minuter",
            videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            videoId: "sample-video-\(index)"
        )
    }

    let feed = VGRContent(
        title: "Videoklipp",
        subtitle: "Korta filmer om psoriasis",
        type: .videofeed,
        imageUrl: "",
        elements: videos
    )

    let element = VGRContentElement(
        type: .internalVideoSelectorLink,
        internalArticle: feed
    )

    NavigationStack {
        ScrollView {
            /// From content, as placed on a screen of its own, with a way to see the whole feed
            VGRContentVideoSelectorView(content: feed) {
                print("Show all tapped")
            }

            /// From an element, as rendered inside a `VGRContentScreen`, without one
            VGRContentVideoSelectorView(element: element)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRContentVideoSelectorView")
        .navigationBarTitleDisplayMode(.inline)
    }
}
