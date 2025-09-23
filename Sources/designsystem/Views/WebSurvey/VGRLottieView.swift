import SwiftUI
import Lottie

/// Minimal SwiftUI-wrapper runt LottieAnimationView för att slippa externa wrappers.
public struct VGRLottieView: UIViewRepresentable {
    private let animationName: String
    private let loopMode: LottieLoopMode
    
    public init(animationName: String, loopMode: LottieLoopMode = .playOnce) {
        self.animationName = animationName
        self.loopMode = loopMode
    }
    
    public func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        if let animation = LottieAnimation.named(animationName, bundle: .module) {
            view.animation = animation
            view.play()
        }
        return view
    }
    
    public func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
