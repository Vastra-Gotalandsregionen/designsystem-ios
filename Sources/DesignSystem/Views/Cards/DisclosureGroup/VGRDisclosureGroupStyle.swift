import SwiftUI

public struct VGRDisclosureGroupStyle: DisclosureGroupStyle {
    public init() {}

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
                .padding(.vertical, 18)
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)

            configuration.content
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .font(.subheadline)
                .foregroundStyle(Color.Neutral.text)
                .padding(.bottom, 12)
                .padding(.horizontal, 16)
                .isVisible(configuration.isExpanded)
        }
    }
}

#Preview {
    let faq: [(String,String)] = [
        ("Hello, world domination order of the day with multiple lines","Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        ("Hello, world domination","Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        ("Hello, world domination","Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        ("Hello, world domination","Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        ("Hello, world domination","Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        ("Hello, world domination","Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
    ]

    NavigationStack {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(faq.enumerated()), id: \.offset) { index, item in
                    VGRDivider().isVisible(index != 0)
                    VGRDisclosureGroup(title: item.0) {
                        Text(item.1)
                    }
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
