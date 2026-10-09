import SwiftUI

/// A card that presents an audio item: a colored circle with an SF Symbol,
/// the title and the duration in minutes.
/// The card fills all the space its parent offers which makes cards in a row or grid get equal height.
public struct VGRAudioCard: View {
    let title: String
    let iconBackgroundColor: Color
    let iconName: String
    let duration: Int

    /// - Parameters:
    ///   - title: The title of the audio. Truncated after two lines.
    ///   - iconBackgroundColor: Background color of the circle behind the icon.
    ///     Defaults to `Color.Accent.purpleSurface`.
    ///   - iconName: Name of the SF Symbol shown in the circle.
    ///   - duration: Length of the audio in whole minutes.
    public init(
        title: String,
        iconBackgroundColor: Color = Color.Accent.purpleSurface,
        iconName: String,
        duration: Int
    ) {
        self.title = title
        self.iconBackgroundColor = iconBackgroundColor
        self.iconName = iconName
        self.duration = duration
    }

    /// Returns a localized duration string using "minute" for a duration of 1 and "minutes" for all other values.
    private var durationText: String {
        (duration == 1
            ? "audiocard.duration.singular"
            : "audiocard.duration.plural").localizedBundleFormat(arguments: duration)
    }

    /// Accessibility label combining type, title & duration
    private var a11yLabel: String {
        return ["content.type.audio".localizedBundle, title, durationText].joined(separator: ", ")
    }

    /// Accessibility hint explaining what happens when tapped.
    private var a11yHint: String {
        return "audiocard.hint".localizedBundle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .Margins.small) {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 21, height: 21)
                        .foregroundStyle(Color.Neutral.text)
                }

            Text(title)
                .font(.title3Bold)
                .lineLimit(2)

            Spacer(minLength: 16)

            Label(durationText, systemImage: "clock")
                .font(.footnoteRegular)
                .foregroundStyle(Color.Neutral.textVariant)
        }
        .padding(.Margins.medium)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yLabel)
        .accessibilityHint(a11yHint)

    }
}

#Preview("1 kort i karusell") {
    VGRCarousel {
        VGRAudioCard(title: "Andningsövning", iconName: "waveform", duration: 1)
            .frame(width: 192)
    }
}

#Preview("Mörkt läge 2 karruseller") {
    VStack {
        VGRCarousel {
            VGRAudioCard(title: "Andningsövning", iconName: "waveform", duration: 1)
                .frame(width: 192)

            VGRAudioCard(
                title: "En mycket lång titel på en avslappningsövning som inte ryms",
                iconBackgroundColor: Color.Accent.greenSurface,
                iconName: "waveform",
                duration: 12
            )
            .frame(width: 192)
        }
        VGRCarousel {
            VGRAudioCard(title: "Hålla andan övningar", iconName: "waveform", duration: 1)
                .frame(width: 192)

            VGRAudioCard(
                title: "Tagga igång övningar med hyped up musik och ljud",
                iconBackgroundColor: Color.Accent.greenSurface,
                iconName: "waveform",
                duration: 12
            )
            .frame(width: 192)
            VGRAudioCard(
                title: "Ännu fler luft i kroppen övningar",
                iconBackgroundColor: Color.Accent.greenSurface,
                iconName: "waveform",
                duration: 12
            )
            .frame(width: 192)
        }
    }
    .preferredColorScheme(.dark)
}
