import SwiftUI

public struct VGRDisclosureStyle: DisclosureGroupStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut) {
                    configuration.isExpanded.toggle()
                }
            }) {
                HStack {
                    configuration.label
                        .fontWeight(.medium)
                        .foregroundStyle(Color.Neutral.text)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                        .foregroundColor(Color.Primary.action)
                        .fontWeight(.semibold)
                        .rotationEffect(.degrees(configuration.isExpanded ? 0 : 180))
                        .animation(.easeInOut(duration: 0.3), value: configuration.isExpanded)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if configuration.isExpanded {
                configuration.content
                    .foregroundStyle(Color.Neutral.text)
                    .padding(.vertical, 12)
            }
        }
    }
}
