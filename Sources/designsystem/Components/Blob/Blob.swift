import SwiftUI
import Lottie

struct Blob: View {
    @Binding var state: Int?

    var body: some View {
        LottieView(animation: .named("blob_animation", bundle: .module))
            .playing(
                .fromFrame(
                    0,
                    toFrame: AnimationFrameTime(safeFrame()),
                    loopMode: .playOnce
                )
            )
    }

    private func safeFrame() -> Float {
        let keys: [Float] = [2, 8, 15, 23, 30]
        guard let state else { return keys[0] }
        return (state >= 0 && state < keys.count) ? keys[state] : 0
    }
}

#Preview {
    @Previewable @State var index: Int? = 0

    VStack(spacing: 16) {
        Blob(state: $index)
            .frame(width: 164, height: 164)

        Picker("Animation index", selection: $index) {
            ForEach(0..<5) {
                Text("State \($0)").tag($0)
            }
        }
        .pickerStyle(.segmented)
    }
    .padding(16)
}
