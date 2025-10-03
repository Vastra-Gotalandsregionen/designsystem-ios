import SwiftUI

/// A card component that displays video information with a play button icon.
///
/// The card shows a colored circle with a play icon, title, subtitle, duration,
/// and an optional checkmark indicator for viewed videos. Designed for use in
/// video carousels and lists.
struct VGRVideoCard: View {
    @AccessibilityFocusState private var isInFocus: Bool

    /// The main title displayed on the card.
    let title: String

    /// An optional subtitle displayed below the title.
    var subtitle: String = ""

    /// The duration of the video, typically formatted as a string (e.g., "3 minuter").
    let duration: String

    /// The color of the circular play button background.
    var circleColor: Color = Color.Accent.yellowSurface

    /// Indicates whether the video has been viewed, showing a checkmark when `true`.
    var hasBeenViewed: Bool = false

    /// Accessibility label combining title, subtitle, and duration.
    private var a11yLabel: String {
        let components = [title, subtitle].filter { !$0.isEmpty }
        return components.joined(separator: " ") + ", \(duration)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
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

                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.Accent.greenGraphic)
                    .frame(width: 16, height: 16)
                    .isVisible(hasBeenViewed)
            }
        }
        .padding(16)
        .frame(maxHeight: .infinity)
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yLabel)
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
struct VGRVideoCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
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
                    VGRVideoCard(title: "Del 1:",
                                 subtitle: "Vad är psoriasis?",
                                 duration: "3 minuter")
                    .frame(width: 192)

                    Button {

                    } label: {
                        VGRVideoCard(title: "Del 6:",
                                     subtitle: "När egenvård inte räcker",
                                     duration: "3 minuter",
                                     circleColor: Color.Accent.purpleSurface,
                                     hasBeenViewed: true)
                        .frame(width: 192)
                    }
                    .buttonStyle(VGRVideoCardButtonStyle())

                    VGRVideoCard(title: "Del 2:",
                                 subtitle: "Samsjuklighet",
                                 duration: "3 minuter",
                                 circleColor: Color.Accent.purpleSurface)
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
