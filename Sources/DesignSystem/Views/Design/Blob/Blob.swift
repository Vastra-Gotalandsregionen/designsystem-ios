import SwiftUI
import Lottie

/// Lottie-based blob, superseded by ``VGRBlob`` which draws the same states with
/// SwiftUI and animates between them.
@available(*, deprecated, renamed: "VGRBlob", message: "Use VGRBlob, which animates between states without Lottie.")
public struct Blob: View {
    @Binding var state: Int?
    
    public init(state: Binding<Int?>) {
        self._state = state
    }

    public var body: some View {
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
