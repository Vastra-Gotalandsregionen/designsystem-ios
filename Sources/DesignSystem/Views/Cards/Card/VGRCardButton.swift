import SwiftUI

public struct VGRCardButton: View {
    let sizeClass: VGRCardSizeClass
    let title: String
    let subtitle: String
    let imageUrl: String
    let isNew: Bool
    let onPressed: () -> Void

    /// Creates a new content card button.
    /// - Parameters:
    ///   - sizeClass: The size class for the card (small, medium, or large).
    ///   - title: The main title displayed on the card.
    ///   - subtitle: The subtitle or read time displayed below the title, defaults to empty.
    ///   - imageUrl: The URL or name of the image to display.
    ///   - isNew: Indicates whether to show the "new" badge. Defaults to `false`.
    ///   - onPressed: Closure called when the button is pressed.
    public init(
        sizeClass: VGRCardSizeClass,
        title: String,
        subtitle: String = "",
        imageUrl: String,
        isNew: Bool = false,
        onPressed: @escaping () -> Void
    ) {
        self.sizeClass = sizeClass
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.isNew = isNew
        self.onPressed = onPressed
    }

    private var a11yLabel: String {
        var output: [String] = []
        if isNew { output.append("content.new".localizedBundle) }
        output.append("content.type.text".localizedBundle)
        output.append(self.title)
        if !self.subtitle.isEmpty { output.append(self.subtitle) }
        return output.joined(separator: ", ")
    }

    public var body: some View {
        Button {
            Haptics.lightImpact()
            onPressed()
        } label: {
            VGRCardView(
                sizeClass: sizeClass,
                title: title,
                subtitle: subtitle,
                imageUrl: imageUrl,
                isNew: isNew
            )
        }
        .buttonStyle(VGRCardButtonStyle())
        .accessibilityLabel(a11yLabel)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                VGRCardButton(
                    sizeClass: .large,
                    title: "Understanding Psoriasis",
                    subtitle: "5 min läsning",
                    imageUrl: "placeholder",
                    isNew: true
                ) {
                    print("I pressed article Understanding Psoriasis")
                }

                VGRCardButton(
                    sizeClass: .medium,
                    title: "Treatment Options",
                    subtitle: "3 min läsning",
                    imageUrl: "placeholder",
                    isNew: false
                ) {
                    print("I pressed article Treatment Options")
                }

                VGRCardButton(
                    sizeClass: .small,
                    title: "Living with Psoriasis",
                    subtitle: "7 min läsning",
                    imageUrl: "placeholder",
                    isNew: false
                ) {
                    print("I pressed article Living with Psoriasis")
                }

                VGRCardButton(
                    sizeClass: .small,
                    title: "When to See a Doctor",
                    subtitle: "4 min läsning",
                    imageUrl: "placeholder",
                    isNew: true
                ) {
                    print("I pressed article When to See a Doctor")
                }

                VGRCardButton(
                    sizeClass: .small,
                    title: "When to See a Doctor",
                    imageUrl: "placeholder",
                    isNew: true
                ) {
                    print("I pressed article When to See a Doctor")
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRContentCardButton")
        .navigationBarTitleDisplayMode(.inline)
    }
}
