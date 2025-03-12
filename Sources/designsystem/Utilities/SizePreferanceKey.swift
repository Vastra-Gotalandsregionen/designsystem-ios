import Foundation
import SwiftUI

//TODO preconcurrency, mainactor, what
public struct SizePreferenceKey: @preconcurrency PreferenceKey {
    @MainActor public static var defaultValue: CGSize = .zero

    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public struct SizeModifer: ViewModifier {

    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
    
    public func body(content: Content) -> some View {
        content
            .background(sizeView)
    }
    
}

extension View {
    public func onSizeChanged(_ handler: @escaping (CGSize) -> Void) -> some View {
        self
            .modifier(SizeModifer())
            .onPreferenceChange(SizePreferenceKey.self, perform: { value in
                handler(value)
            })
    }
}
