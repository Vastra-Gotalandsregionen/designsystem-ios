import SwiftUI

public struct VGRDisclosureGroupStyle: DisclosureGroupStyle {

    /// Configurable insets for the label
    private var labelInsets: EdgeInsets

    /// Configurable insets for the content
    private var contentInsets: EdgeInsets

    public init(
        labelInsets: EdgeInsets = .init(top: 16, leading: 18, bottom: 18, trailing: 16),
        contentInsets: EdgeInsets = .init(top: 0, leading: 16, bottom: 12, trailing: 16)
    ) {
        self.labelInsets = labelInsets
        self.contentInsets = contentInsets
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    configuration.label
                        .font(.bodyMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.up")
                        .foregroundColor(Color.Primary.action)
                        .fontWeight(.semibold)
                        .rotationEffect(.degrees(configuration.isExpanded ? 0 : 180))
                        .animation(.easeInOut(duration: 0.3), value: configuration.isExpanded)
                }
                .foregroundStyle(Color.Neutral.text)
                .contentShape(Rectangle())
                .padding(labelInsets)
            }
            .buttonStyle(.plain)

            configuration.content
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .font(.subheadline)
                .foregroundStyle(Color.Neutral.text)
                .padding(contentInsets)
                .isVisible(configuration.isExpanded)
        }
    }
}

#Preview {
    let faq: [(question: String, answer: String)] = [
        (
            "What is today’s objective?",
            "Standard procedure: charm the masses, disrupt the status quo, and conquer at least one timezone."
        ),
        (
            "Is world domination sustainable?",
            "Absolutely—especially when powered by espresso, ambition, and a well-structured SwiftUI architecture."
        ),
        (
            "What tools are required?",
            "A keyboard, a cunning plan, and possibly a well-trained army of background tasks."
        ),
        (
            "What if something goes wrong?",
            "Simply declare it a feature and release a patch note with confidence."
        )
    ]

    NavigationStack {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(faq.enumerated()), id: \.offset) { index, item in
                    VGRDivider().isVisible(index != 0)

                    DisclosureGroup(
                        content: {
                            Text(item.answer)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color.Accent.redSurfaceMinimal)
                                .border(Color.Accent.redGraphic, width: 1)
                        },
                        label: {
                            Text(item.question)
                                .font(.bodyMedium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                    )
                    .background(Color.Elevation.elevation1)
                    .disclosureGroupStyle(VGRDisclosureGroupStyle(contentInsets: EdgeInsets(top: 0,
                                                                                            leading: 0,
                                                                                            bottom: 0,
                                                                                            trailing: 0)))
                }
            }
            .background(Color.Elevation.elevation1)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(16)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRDisclosureGroupStyle")
    }
}
