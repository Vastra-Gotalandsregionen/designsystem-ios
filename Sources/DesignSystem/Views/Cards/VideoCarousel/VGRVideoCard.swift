import SwiftUI

/// A card component that displays video information with a play button icon.
///
/// The card shows a colored circle with a play icon, title, subtitle, duration,
/// and an optional checkmark indicator for viewed videos. Designed for use in
/// video carousels and lists.
public struct VGRVideoCard: View {
    @AccessibilityFocusState private var isInFocus: Bool
    
    /// The main title displayed on the card.
    let title: String
    
    /// An optional subtitle displayed below the title.
    var subtitle: String = ""
    
    /// The duration of the video, typically formatted as a string (e.g., "3 minuter").
    let duration: String
    
    /// The color of the circular play button background.
    var circleColor: Color = Color.Accent.yellowSurface
    
    /// The watch status of the video.
    var watchStatus: VGRVideoWatchStatus = .notWatched

    /// The publish date of the video. Used to determine if a "NEW" badge should be shown.
    var publishDate: Date? = nil

    /// Returns true if the video is new (published within the last 14 days).
    private var isNew: Bool {
        publishDate?.isWithinLast14Days ?? false
    }

    /// Creates a new video card with the specified properties.
    /// - Parameters:
    ///   - title: The main title displayed on the card.
    ///   - subtitle: An optional subtitle displayed below the title. Defaults to an empty string.
    ///   - duration: The duration of the video, typically formatted as a string (e.g., "3 minuter").
    ///   - circleColor: The color of the circular play button background. Defaults to yellow.
    ///   - watchStatus: The watch status of the video. Defaults to `.notWatched`.
    ///   - publishDate: The publish date of the video. Used to show a "NEW" badge if within 14 days.
    public init(
        title: String,
        subtitle: String = "",
        duration: String,
        circleColor: Color = Color.Accent.yellowSurface,
        watchStatus: VGRVideoWatchStatus = .notWatched,
        publishDate: Date? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.circleColor = circleColor
        self.watchStatus = watchStatus
        self.publishDate = publishDate
    }
    
    /// Accessibility label combining new status, type, title, subtitle, duration, and watch status.
    /// Format: (Nytt) Videoklipp, Title, Subtitle, Duration, WatchStatus
    private var a11yLabel: String {
        var components: [String] = []

        if isNew {
            components.append("content.new.a11y".localizedBundle)
        }

        components.append("content.type.video".localizedBundle)

        if !title.isEmpty {
            components.append(title)
        }
        if !subtitle.isEmpty {
            components.append(subtitle)
        }

        components.append("\("videocard.duration.a11y".localizedBundle) \(duration)")

        components.append(watchStatus.accessibilityLabel)

        return components.joined(separator: ", ")
    }

    /// Accessibility hint explaining what happens when tapped.
    private var a11yHint: String {
        return "videocard.hint".localizedBundle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack(alignment: .center) {
                        Circle()
                            .fill(circleColor)
                            .frame(width: 50, height: 50)

                        Image(systemName: "play")
                            .resizable()
                            .frame(width: 21, height: 21)
                            .foregroundStyle(Color.Neutral.text)
                            .offset(x: 2, y: 0)
                    }
                    .accessibilityHidden(true)

                    Spacer()

                    if isNew {
                        ZStack {
                            Rectangle()
                                .fill(Color.Primary.blueSurface)
                                .frame(width: 40, height: 32)
                                .cornerRadius(5)
                            
                            Text("content.new".localizedBundle)
                                .foregroundStyle(Color.Neutral.text)
                                .fontWeight(.semibold)
                                .dynamicTypeSize(.small ... .large)
                        }
                        .accessibilityHidden(true)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.title3Bold)
                        .isVisible(!title.isEmpty)
                    
                    Text(subtitle)
                        .font(.title3Bold)
                        .lineLimit(2)
                        .isVisible(!subtitle.isEmpty)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            HStack {
                HStack(spacing: 4) {
                    Image("readtime_video", bundle: .module)
                        .frame(width: 16, height: 16)
                    
                    Text(duration)
                        .font(.footnoteRegular)
                }
                .foregroundStyle(Color.Neutral.textVariant)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Group {
                    switch watchStatus {
                    case .notWatched:
                        Image(systemName: "stop.circle.fill")
                            .foregroundStyle(Color.Accent.brownGraphic)
                            .frame(width: 16, height: 16)
                    case .partiallyWatched:
                        Image(systemName: "pause.circle.fill")
                            .foregroundStyle(Color.Accent.orangeGraphic)
                            .frame(width: 16, height: 16)
                    case .completed:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.Accent.greenGraphic)
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxHeight: .infinity)
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yLabel)
        .accessibilityHint(a11yHint)
        .overlay {
            if isInFocus {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(circleColor, style: StrokeStyle(lineWidth: 2))
            }
        }
        
    }
}

/// A button style that adds a subtle scale animation when pressed.
///
/// Applies a scale-down effect to 96% when the button is pressed,
/// with a smooth ease-in-out animation.
public struct VGRVideoCardButtonStyle: ButtonStyle {
    /// Creates a new video card button style.
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Not watched
                    VGRVideoCard(title: "Del 1:",
                                 subtitle: "Vad är psoriasis?",
                                 duration: "3 minuter",
                                 watchStatus: .notWatched)
                    .frame(width: 192)
                    
                    // Partially watched
                    Button {
                        
                    } label: {
                        VGRVideoCard(title: "Del 2:",
                                     subtitle: "Samsjuklighet",
                                     duration: "3 minuter",
                                     circleColor: Color.Accent.purpleSurface,
                                     watchStatus: .partiallyWatched,
                                     publishDate: Date()
                        )
                        .frame(width: 192)
                    }
                    .buttonStyle(VGRVideoCardButtonStyle())
                    
                    // Completed 
                    VGRVideoCard(title: "Del 3:",
                                 subtitle: "När egenvård inte räcker",
                                 duration: "3 minuter",
                                 circleColor: Color.Accent.cyanSurface,
                                 watchStatus: .completed)
                    .frame(width: 192)
                }
                .fixedSize(horizontal: false, vertical: true)
                
            }
            .contentMargins(.leading, 16)
            .contentMargins(.trailing, 16*12)
        }
        .navigationTitle("VGRVideoCard")
        .frame(maxWidth: .infinity)
        .background(Color.Elevation.background)
    }
}
