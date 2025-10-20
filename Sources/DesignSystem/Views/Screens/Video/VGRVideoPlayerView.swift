import SwiftUI
import AVKit
import Combine
import OSLog

/// A full-screen video player view for playing videos.
///
/// This view handles video playback with features including:
/// - Automatic Swedish subtitle selection
/// - Progress tracking at 85% completion
/// - Error handling with user-friendly alerts
/// - Accessibility announcements for playback completion
public struct VGRVideoPlayerView: View {
    private let logger = Logger(subsystem: "com.vgregion.designsystem", category: "VGRVideoPlayerView")

    public let title: String
    public let videoUrl: String
    public let videoId: String

    @State private var player: AVPlayer?
    @State private var timeObserver: Any?
    @State private var hasReachedEightyFivePercent = false
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var showError = false
    @State private var errorMessage = ""

    @AccessibilityFocusState private var isDismissButtonFocused: Bool
    @Environment(\.dismiss) private var dismiss

    private var videoEndedPublisher = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)

    private var videoURL: URL? {
        return URL(string: videoUrl)
    }

    /// Creates a new video player view with the specified content element.
    /// - Parameter element: The VGRContentElement containing video information.
    public init(element: VGRContentElement) {
        self.title = element.title
        self.videoUrl = element.videoUrl
        self.videoId = element.videoId
    }

    /// Creates a new video player view with direct parameters.
    /// - Parameters:
    ///   - title: The title of the video
    ///   - videoUrl: The URL string of the video
    ///   - videoId: The unique identifier for the video
    public init(title: String, videoUrl: String, videoId: String) {
        self.title = title
        self.videoUrl = videoUrl
        self.videoId = videoId
    }

    public var body: some View {
        Group {
            if let url = videoURL {
                VideoPlayer(player: player)
                    .onAppear {
                        logger.info("Video player appeared - Title: \(self.title), URL: \(self.videoUrl), ID: \(self.videoId)")
                        setupVideoPlayer(with: url)
                    }
                    .onDisappear {
                        cleanupVideoPlayer()
                    }
                    .onReceive(videoEndedPublisher) { _ in
                        handleVideoEnded()
                    }
            } else {
                errorView(message: "videoplayer.error.invalidurl".localizedBundle)
                    .onAppear {
                        logger.error("Invalid video URL - Title: \(self.title), URL string: '\(self.videoUrl)', ID: \(self.videoId)")
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title.isEmpty ? "videoplayer.title.default".localizedBundle : title)
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.Elevation.background)
        .alert("videoplayer.error.title".localizedBundle, isPresented: $showError, actions: {
            Button("general.button.ok".localizedBundle, role: .cancel) {
                dismiss()
            }
        }, message: {
            Text(errorMessage)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                VGRCloseButton() {
                    dismiss()
                }
                .accessibilityFocused($isDismissButtonFocused)
            }
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Color.Status.errorText)

            Text(message)
                .font(.bodyRegular)
                .foregroundStyle(Color.Status.errorText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func handleVideoEnded() {
        UIAccessibility.post(
            notification: .announcement,
            argument: "videoplayer.playback.finished.a11y".localizedBundle
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isDismissButtonFocused = true
        }
    }

    private func setupVideoPlayer(with url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        monitorPlayerItemStatus(playerItem)

        Task {
            await selectSwedishSubtitles(for: asset, playerItem: playerItem)

            DispatchQueue.main.async {
                self.player = AVPlayer(playerItem: playerItem)
                self.player?.play()

                Task {
                    do {
                        try await self.addPlaybackObserver()
                    } catch {
                        logger.error("Error setting up time observer: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func monitorPlayerItemStatus(_ playerItem: AVPlayerItem) {
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { status in
                if status == .failed {
                    self.errorMessage = "videoplayer.error.loadfailed".localizedBundle
                    self.showError = true
                    logger.error("Video player item failed to load")
                }
            }
            .store(in: &cancellables)
    }

    private func selectSwedishSubtitles(for asset: AVAsset, playerItem: AVPlayerItem) async {
        do {
            guard let group = try await asset.loadMediaSelectionGroup(for: .legible) else {
                logger.info("No subtitles/closed captions available")
                return
            }

            let locale = Locale(identifier: "sv_SE")
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)

            if let swedishOption = options.first {
                playerItem.select(swedishOption, in: group)
                logger.info("Selected Swedish subtitles")
            } else {
                logger.info("Swedish subtitles not found")
            }
        } catch {
            logger.error("Failed to load media selection group: \(error.localizedDescription)")
        }
    }

    private func cleanupVideoPlayer() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
            hasReachedEightyFivePercent = false
        }
        player = nil
        cancellables.removeAll()
    }

    private func addPlaybackObserver() async throws {
        guard let playerItem = player?.currentItem else { return }
        let asset = playerItem.asset
        let duration = try await asset.load(.duration)
        let eightyFivePercentThrough = CMTimeMultiplyByFloat64(duration, multiplier: 0.85)

        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] currentTime in
            Task { @MainActor in
                guard !self.hasReachedEightyFivePercent else { return }

                if currentTime >= eightyFivePercentThrough {
                    self.hasReachedEightyFivePercent = true

                    logger.info("Video reached 85% completion: \(self.videoId)")

                    // Mark video as watched using the service
                    VGRVideoStatusService.shared.markAsWatched(videoId: self.videoId)

                    if let observer = self.timeObserver {
                        self.player?.removeTimeObserver(observer)
                        self.timeObserver = nil
                    }
                }
            }
        }
    }
}

#Preview("Valid Video") {
    NavigationStack {
        VGRVideoPlayerView(
            element: VGRContentElement(
                type: .video,
                title: "Sample Video",
                subtitle: "A demonstration video",
                readTime: "5 minuter",
                videoUrl: "https://player.vgregion.se/mobilapp1/smil:mc1/Y93sDHAABx5AnnK6V8uyEJ_iWRmspME7rM5UHSTvWcxFr/master.smil/playlist.m3u8",
                videoId: "sample-video-1"
            )
        )
    }
}

#Preview("Invalid URL") {
    NavigationStack {
        VGRVideoPlayerView(
            element: VGRContentElement(
                type: .video,
                title: "Invalid Video",
                subtitle: "This video has an invalid URL",
                videoUrl: "",
                videoId: ""
            )
        )
    }
}
