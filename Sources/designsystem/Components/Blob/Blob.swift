import SwiftUI
import Lottie

struct Blob: View {
    
    @Binding var index: Int?
    
    let keys: [Float] = [2, 8, 15, 23, 30]
    
    var body: some View {
        VStack {
            LottieView(animation: .named("blob_animation", bundle: .module))
                .playing(
                    .fromFrame(
                        0,
                        toFrame: AnimationFrameTime(safeFrame()),
                        loopMode: .playOnce))
                .frame(width: 164, height: 164)
        }
    }
    
    private func safeFrame() -> Float {
        
        guard let index = index else { return keys[0] }
        
        if index >= 0, index < keys.count {
            return keys[index]
        } else {
            return 0
        }
    }
}

#Preview {
    @Previewable @State var index: Int? = 4
    
    Blob(index: $index)
    
}
