import SwiftUI
import TipKit

struct VGRTipStyle: TipViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let image = configuration.image {
                image
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            if let title = configuration.title {
                title
                    .bold()
                    .font(.headline)
            }
            if let message = configuration.message {
                message
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(content: {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.Accent.purpleSurface)
                .strokeBorder(Color.Accent.purpleGraphic, style: .init(lineWidth: 2))
        })
        .background(Color.Accent.purpleSurface)
        .overlay(alignment: .topTrailing) {
            // Close Button
            Image(systemName: "multiply")
//                .font(.title2)
                .alignmentGuide(.top) { $0[.top] - 15 }
                .alignmentGuide(.trailing) { $0[.trailing] + 15 }
                .foregroundStyle(.secondary)
                .onTapGesture {
                    // Invalidate Reason
                    configuration.tip.invalidate(reason: .tipClosed)
                }
        }
//        .padding()
    }
}

struct PopoverTip: Tip {
    var title: Text {
        Text("Add an Effect")
            .foregroundStyle(.indigo)
    }
    var message: Text? {
        Text("Touch and hold \(Image(systemName: "wand.and.stars")) to add an effect to your favorite image.")
    }
}


#Preview {

    var tip = PopoverTip()
    var tip2 = PopoverTip()

    NavigationStack {
        ScrollView {
            Text("Hej och hå")
                .popoverTip(tip)
                .onAppear {

                    try? Tips.resetDatastore()
                    try? Tips.configure()
                }

            Spacer()
                .frame(height: 200)

            TipView(tip2, arrowEdge: .bottom)
                .tipViewStyle(VGRTipStyle())
                .padding()
        }
    }
}
