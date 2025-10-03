import SwiftUI

public struct VGRPortraitLandscapeView<PortraitContent: View, LandscapeContent: View>: View {

    @ViewBuilder var portrait: () -> PortraitContent
    @ViewBuilder var landscape: () -> LandscapeContent

    public var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            Group {
                if isLandscape {
                    landscape()
                } else {
                    portrait()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview("Landscape", traits: .landscapeRight) {
    VGRPortraitLandscapeView {
        Text("Portrait")
    } landscape: {
        Text("Landscape")
    }
}

#Preview("Portrait", traits: .portrait) {
    VGRPortraitLandscapeView {
        Text("Portrait")
    } landscape: {
        Text("Landscape")
    }
}
