import SwiftUI

/// A view that displays a video card for VGRContentElement of type `.video`.
///
/// This view presents a tappable card that opens the full-screen video player as a sheet.
public struct VGRContentVideoView: View {
    public let element: VGRContentElement

    @ObservedObject private var videoStatusService = VGRVideoStatusService.shared

    public init(element: VGRContentElement) {
        self.element = element
    }

    @State private var showVideoPlayer = false

    private var isWatched: Bool {
        return videoStatusService.isWatched(videoId: element.videoId)
    }

    public var body: some View {
        Button {
            showVideoPlayer = true
        } label: {
            VGRVideoCard(
                title: element.title,
                subtitle: element.subtitle,
                duration: element.readTime,
                hasBeenViewed: isWatched
            )
            .padding(.horizontal, VGRSpacing.horizontal)
            .padding(.vertical, VGRSpacing.verticalSmall)
        }
        .buttonStyle(VGRVideoCardButtonStyle())
        .sheet(isPresented: $showVideoPlayer) {
            NavigationStack {
                VGRVideoPlayerView(
                    title: element.title,
                    videoUrl: element.videoUrl,
                    videoId: element.videoId
                )
            }
        }
    }
}

#Preview("Video Card") {
    NavigationStack {
        ScrollView {
            VGRContentVideoView(
                element: VGRContentElement(
                    type: .video,
                    title: "Del 1:",
                    subtitle: "Vad är psoriasis?",
                    readTime: "3 minuter",
                    videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                    videoId: "sample-video-1"
                )
            )

            VGRContentVideoView(
                element: VGRContentElement(
                    type: .video,
                    title: "Del 2:",
                    subtitle: "Samsjuklighet",
                    readTime: "5 minuter",
                    videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                    videoId: "sample-video-2"
                )
            )
        }
        .background(Color.Elevation.background)
        .navigationTitle("Video Content")
    }
}
