import SwiftUI

struct VGRVideoCarousel: View {
    @State private var position: String?

    let items: [String] = ["alfa", "beta", "gamma", "delta"]

    private let elementWidth: CGFloat = UIScreen.main.bounds.width * 0.51
    private let defaultMargin: CGFloat = 16

    private func setInitialPosition() {
        guard let first = items.first else { return }
        position = first
    }

    private func indexOf(_ item: String) -> Int? {
        return items.firstIndex(of: item)
    }

    private func previous() {
        /// Find current index of position in items
        if let current = position, let idx = items.firstIndex(of: current) {
            if idx > 0 {
                position = items[idx - 1]
            }
        } else {
            /// If position is nil, set to last item
            position = items.last
        }
    }

    private func next() {
        /// Find current index of position in items
        if let current = position, let idx = items.firstIndex(of: current) {
            if idx < items.count - 1 {
                position = items[idx + 1]
            }
        } else {
            /// If position is nil, set to first item
            position = items.first
        }
    }

    private var canGoBack: Bool {
        guard let idx = position else { return true }
        guard let index = indexOf(idx) else { return true }

        if index > 0 { return true }
        return false
    }

    private var canGoForward: Bool {
        guard let idx = position else { return true }
        guard let index = indexOf(idx) else { return true }
        
        if index < items.count - 1 { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack {
                    Text("Videoklipp")
                        .font(.title3Bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Korta filmer om något")
                        .font(.footnoteRegular)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 16)

                HStack {
                    Button {
                        previous()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.Elevation.elevation1)
                            Image(systemName: "chevron.left")
                                .foregroundStyle(
                                    canGoBack ? Color.Primary.action : Color.Neutral.textDisabled
                                )
                                .bold()
                        }
                    }
                    .frame(width: 44, height: 44)
                    .disabled(!canGoBack)

                    Button {
                        next()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.Elevation.elevation1)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(
                                    canGoForward ? Color.Primary.action : Color.Neutral.textDisabled
                                )
                                .bold()
                        }
                    }
                    .frame(width: 44, height: 44)
                    .disabled(!canGoForward)

                }
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(items, id: \.self) { item in
                        VStack {
                            Text(item)
                                .id(item)
                        }
                        .frame(width:elementWidth, height:200)
                        .background(.red)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $position)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: position)
            .defaultScrollAnchor(.leading)
            .contentMargins(.leading, 16)
            .contentMargins(.trailing, UIScreen.main.bounds.width - elementWidth - defaultMargin)
            .scrollIndicators(.hidden)
        }
        .onAppear {
            setInitialPosition()
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {

            VGRVideoCarousel()
                .padding(.top, 40)
        }
        .background(Color.Accent.brownSurfaceMinimal)
        .navigationTitle("VGRVideoCarousel")
    }
}
