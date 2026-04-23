import SwiftUI

public struct VGRSimpleCallout<Icon: View>: View {

    private let title: String
    private let text: String
    private let icon: Icon
    private let iconAlignment: Alignment
    private let backgroundColor: Color

    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                iconAlignment: Alignment = .top,
                @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.text = text
        self.backgroundColor = backgroundColor
        self.icon = icon()
        self.iconAlignment = iconAlignment
    }

    public var body: some View {
        VGRCalloutV3(title: title,
                     text: text,
                     backgroundColor: backgroundColor,
                     icon: {
            icon
                .frame(maxHeight: .infinity, alignment: iconAlignment)
        })
    }
}

extension VGRSimpleCallout where Icon == VGRSystemIcon {
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                iconAlignment: Alignment = .top,
                systemImage: String) {
        self.init(title: title,
                  text: text,
                  backgroundColor: backgroundColor,
                  iconAlignment: iconAlignment,
                  icon: { VGRSystemIcon(systemImage: systemImage) })
    }
}

public struct VGRSystemIcon: View {
    @ScaledMetric private var iconSize: CGFloat = 25

    let systemImage: String

    public var body: some View {
        Image(systemName: systemImage)
            .resizable()
            .frame(width: iconSize, height: iconSize)
            .foregroundStyle(Color.Neutral.text)
    }
}

#Preview {
    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRSimpleCallout(title: "Title only",
                                 systemImage: "info.circle")

                VGRSimpleCallout(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                 systemImage: "exclamationmark.triangle")

                VGRSimpleCallout(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                 backgroundColor: Color.Status.successSurface,
                                 systemImage: "gearshape")

                VGRSimpleCallout(title: "Heading",
                                 text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                 systemImage: "gearshape")

                VGRSimpleCallout(title: "Heading",
                                 text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                 backgroundColor: Color.Status.errorSurface,
                                 systemImage: "gearshape")

                VGRSimpleCallout(title: "Custom icon",
                                 text: "Uses a trailing closure icon, and centered icon alignment.",
                                 backgroundColor: Color.Status.errorSurface,
                                 iconAlignment: .center) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.yellow)
                }

                VGRSimpleCallout(title: "Heading",
                                 text: "Det verkar inte som att du har noterat data för hela perioden. Tänk på det när du tittar igenom rapporten. Det verkar inte som att du har noterat data för hela perioden. Tänk på det när du tittar igenom rapporten.",
                                 backgroundColor: Color.Status.errorSurface,
                                 iconAlignment: .center) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color.yellow)
                }
            }
        }
        .navigationTitle("VGRSimpleCallout")
        .navigationBarTitleDisplayMode(.inline)
    }
}
