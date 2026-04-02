import SwiftUI
import AVKit
import AVFoundation
import OSLog

/// A SwiftUI video player with full native VoiceOver accessibility.
///
/// Present using `.fullScreenCover` for best accessibility:
/// ```swift
/// .fullScreenCover(item: $selectedVideo) { video in
///     VGRVideoPlayer(
///         url: video.url,
///         onWatchedThresholdReached: { markAsWatched() },
///         onDismiss: {
///             DispatchQueue.main.async { selectedVideo = nil }
///         }
///     )
///     .ignoresSafeArea()
/// }
/// ```
public struct VGRVideoPlayer: UIViewControllerRepresentable {
    private let url: URL
    private let onWatchedThresholdReached: (() -> Void)?
    private let onDismiss: (() -> Void)?
    private let logger = Logger(subsystem: "se.vgregion.designsystem", category: "VGRVideoPlayer")

    /// Creates a new video player.
    /// - Parameters:
    ///   - url: The video URL to play.
    ///   - onWatchedThresholdReached: Called once when 85% of video is watched.
    ///   - onDismiss: Called when player is dismissed. Wrap state changes in `DispatchQueue.main.async`.
    public init(
        url: URL,
        onWatchedThresholdReached: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.url = url
        self.onWatchedThresholdReached = onWatchedThresholdReached
        self.onDismiss = onDismiss
    }

    // MARK: - UIViewControllerRepresentable

    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerVC = AVPlayerViewController()
        playerVC.delegate = context.coordinator
        playerVC.allowsPictureInPicturePlayback = true
        playerVC.showsPlaybackControls = true

        configureAudioSession()

        let player = AVPlayer(url: url)
        player.allowsExternalPlayback = false
        playerVC.player = player
        context.coordinator.player = player

        if let playerItem = player.currentItem {
            context.coordinator.setupObservers(for: playerItem)
            selectSwedishSubtitles(for: playerItem)
        }

        player.play()
        return playerVC
    }

    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onWatchedThresholdReached: onWatchedThresholdReached,
            onDismiss: onDismiss,
            logger: logger
        )
    }

    /// Cleans up player resources when view is removed.
    public static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.cleanup()
        uiViewController.player?.pause()
        uiViewController.player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        coordinator.callDismissOnce()
    }

    // MARK: - Private Methods

    /// Configures audio session for video playback with sound.
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            logger.error("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    /// Auto-selects Swedish subtitles if available.
    private func selectSwedishSubtitles(for playerItem: AVPlayerItem) {
        Task {
            do {
                guard let group = try await playerItem.asset.loadMediaSelectionGroup(for: .legible) else { return }
                let options = AVMediaSelectionGroup.mediaSelectionOptions(
                    from: group.options,
                    with: Locale(identifier: "sv_SE")
                )
                if let option = options.first {
                    await MainActor.run {
                        playerItem.select(option, in: group)
                    }
                }
            } catch {
                logger.error("Failed to load subtitles: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Coordinator

    /// Handles player lifecycle, progress tracking, and dismiss callbacks.
    @MainActor
    public class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        weak var player: AVPlayer?

        private let onWatchedThresholdReached: (() -> Void)?
        private let onDismiss: (() -> Void)?
        private let logger: Logger

        private var timeObserver: Any?
        private var completionObserver: NSObjectProtocol?
        private var statusObserver: NSKeyValueObservation?
        private var hasReachedThreshold = false
        private var didCallDismiss = false

        /// Percentage of video that must be watched to trigger threshold callback.
        private let watchedThreshold = 0.85

        init(
            onWatchedThresholdReached: (() -> Void)?,
            onDismiss: (() -> Void)?,
            logger: Logger
        ) {
            self.onWatchedThresholdReached = onWatchedThresholdReached
            self.onDismiss = onDismiss
            self.logger = logger
        }

        /// Sets up all observers for playback tracking.
        func setupObservers(for playerItem: AVPlayerItem) {
            observePlayerItemStatus(playerItem)
            addThresholdObserver(for: playerItem)
            addCompletionObserver(for: playerItem)
        }

        // MARK: - AVPlayerViewControllerDelegate

        /// Called when user dismisses the fullscreen player.
        public nonisolated func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willEndFullScreenPresentationWithAnimationCoordinator coordinator: any UIViewControllerTransitionCoordinator
        ) {
            coordinator.animate(alongsideTransition: nil) { _ in
                Task { @MainActor [weak self] in
                    self?.callDismissOnce()
                }
            }
        }

        // MARK: - Internal

        /// Ensures onDismiss is called exactly once.
        func callDismissOnce() {
            guard !didCallDismiss else { return }
            didCallDismiss = true
            onDismiss?()
        }

        /// Removes all observers. Must be called before deallocation.
        func cleanup() {
            if let observer = timeObserver, let player = player {
                player.removeTimeObserver(observer)
            }
            timeObserver = nil

            statusObserver?.invalidate()
            statusObserver = nil

            if let observer = completionObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            completionObserver = nil
        }

        // MARK: - Private

        /// Logs playback errors.
        private func observePlayerItemStatus(_ playerItem: AVPlayerItem) {
            statusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
                if item.status == .failed, let error = item.error {
                    self?.logger.error("Playback failed: \(error.localizedDescription)")
                }
            }
        }

        /// Checks playback position every 5 seconds to detect when 85% is reached.
        /// Uses periodic checking to handle both normal playback and seeking past threshold.
        private func addThresholdObserver(for playerItem: AVPlayerItem) {
            guard let player = player else { return }

            Task {
                // Wait for duration to be available
                guard let duration = try? await playerItem.asset.load(.duration),
                      duration.seconds > 0 else { return }

                let thresholdSeconds = duration.seconds * watchedThreshold

                await MainActor.run {
                    // Check every 5 seconds - handles both normal playback and seeks
                    let interval = CMTime(seconds: 5, preferredTimescale: 1)
                    timeObserver = player.addPeriodicTimeObserver(
                        forInterval: interval,
                        queue: .main
                    ) { [weak self] currentTime in
                        guard let self = self, !self.hasReachedThreshold else { return }

                        if currentTime.seconds >= thresholdSeconds {
                            self.hasReachedThreshold = true
                            self.onWatchedThresholdReached?()
                        }
                    }
                }
            }
        }

        /// Announces video completion for VoiceOver users.
        private func addCompletionObserver(for playerItem: AVPlayerItem) {
            completionObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: .main
            ) { _ in
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "content.video.playback.finished.a11y".localizedBundle
                )
            }
        }
    }
}
