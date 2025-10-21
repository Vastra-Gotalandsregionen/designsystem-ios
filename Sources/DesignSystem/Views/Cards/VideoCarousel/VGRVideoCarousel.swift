import SwiftUI

/// A horizontal carousel component for displaying video cards with navigation controls.
///
/// The carousel displays video items with automatic color rotation, scroll position tracking,
/// and previous/next navigation buttons. It supports orientation changes and provides haptic
/// feedback on interaction.
public struct VGRVideoCarousel: View {
    /// The main title displayed in the carousel header.
    let title: String

    /// The subtitle displayed below the title in the carousel header.
    let subtitle: String

    /// The array of items conforming to `VGRVideoCarouselItem` to display in the carousel.
    let items: [any VGRVideoCarouselItem]

    /// Closure called when a carousel item is tapped, passing the tapped item.
    let onItemTapped: (any VGRVideoCarouselItem) -> Void

    @ObservedObject private var videoStatusService = VGRVideoStatusService.shared

    /// Creates a new video carousel with the specified properties.
    /// - Parameters:
    ///   - title: The main title displayed in the carousel header.
    ///   - subtitle: The subtitle displayed below the title in the carousel header.
    ///   - items: The array of items conforming to `VGRVideoCarouselItem` to display in the carousel.
    ///   - onItemTapped: Closure called when a carousel item is tapped, passing the tapped item.
    public init(
        title: String,
        subtitle: String,
        items: [any VGRVideoCarouselItem],
        onItemTapped: @escaping (any VGRVideoCarouselItem) -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
        self.onItemTapped = onItemTapped
    }

    /// The currently visible item ID tracked for scroll position.
    @State private var position: String?
    @AccessibilityFocusState private var a11yPosition: String?

    /// Array of accent colors cycled through for video card backgrounds.
    private let colors: [Color] = [
        Color.Accent.yellowSurface,
        Color.Accent.purpleSurface,
        Color.Accent.cyanSurface,
        Color.Accent.limeSurface,
        Color.Accent.orangeSurface,
        Color.Accent.pinkSurface,
    ]

    /// Dynamic trailing margin that adjusts based on screen width to show partial next card.
    @State private var trailingContentMargin: CGFloat = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.51) + 16

    /// Default margin value used in calculations.
    private let defaultMargin: CGFloat = 16

    private var a11yLabel: String {
        var result: [String] = ["videocarousel.hint".localizedBundle]
        result.append(title)
        result.append(subtitle)
        result.append("videocarousel.count".localizedBundleFormat(arguments: self.items.count))
        return result.joined(separator: ", ")
    }

    /// Updates the trailing content margin based on current screen width.
    ///
    /// Calculates the margin to ensure the next card is partially visible on the right side.
    private func updateTrailingContentMargin() {
        let elementWidth: CGFloat = UIScreen.main.bounds.width * 0.51
        trailingContentMargin = UIScreen.main.bounds.width - elementWidth + defaultMargin
    }

    /// Sets the initial scroll position to the first item in the carousel.
    private func setInitialPosition() {
        guard let first = items.first else { return }
        position = first.id
    }

    /// Returns the index of an item by its ID.
    /// - Parameter itemId: The ID of the item to find.
    /// - Returns: The index of the item, or `nil` if not found.
    private func indexOf(_ itemId: String) -> Int? {
        return items.firstIndex(where: { $0.id == itemId })
    }

    /// Navigates to the previous item in the carousel.
    private func previous() {
        if let current = position, let idx = indexOf(current) {
            if idx > 0 {
                position = items[idx - 1].id
            }
        } else {
            position = items.last?.id
        }
    }

    /// Navigates to the next item in the carousel.
    private func next() {
        if let current = position, let idx = indexOf(current) {
            if idx < items.count - 1 {
                position = items[idx + 1].id
            }
        } else {
            position = items.first?.id
        }
    }

    /// Indicates whether the previous button should be enabled.
    private var canGoBack: Bool {
        guard let idx = position else { return true }
        guard let index = indexOf(idx) else { return true }

        if index > 0 { return true }
        return false
    }

    /// Indicates whether the next button should be enabled.
    private var canGoForward: Bool {
        guard let idx = position else { return true }
        guard let index = indexOf(idx) else { return true }

        if index < items.count - 1 { return true }
        return false
    }

    /// The header section containing title, subtitle, and navigation buttons.
    private var headerView: some View {
        HStack {
            VStack {
                Text(title)
                    .font(.title3Bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subtitle)
                    .font(.footnoteRegular)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 16)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(a11yLabel)

            navigationButtons
        }
        .padding(.horizontal, 16)
    }

    /// Container for the previous and next navigation buttons.
    private var navigationButtons: some View {
        HStack {
            previousButton
            nextButton
        }
    }

    /// The previous navigation button with chevron icon.
    private var previousButton: some View {
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
        .accessibilityLabel("videocarousel.previous".localizedBundle)
        .accessibilityHidden(!canGoBack)
        .frame(width: 44, height: 44)
        .disabled(!canGoBack)
    }

    /// The next navigation button with chevron icon.
    private var nextButton: some View {
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
        .accessibilityLabel("videocarousel.next".localizedBundle)
        .accessibilityHidden(!canGoForward)
        .frame(width: 44, height: 44)
        .disabled(!canGoForward)
    }

    /// The horizontal scrolling carousel view containing video cards.
    private var carouselScrollView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    carouselItemButton(index: index, item: item)
                        .accessibilityFocused($a11yPosition, equals: item.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $position)
        .onChange(of: position) { _, newValue in
            a11yPosition = newValue
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: position)
        .defaultScrollAnchor(.leading)
        .contentMargins(.leading, 16)
        .contentMargins(.trailing, trailingContentMargin)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.always)
        .scrollTargetBehavior(.viewAligned)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .contain)
    }

    /// Gets the watch status for a video.
    /// - Parameter videoId: The unique identifier of the video.
    /// - Returns: The watch status (notWatched, partiallyWatched, or completed).
    private func watchStatus(for videoId: String) -> VGRVideoWatchStatus {
        return videoStatusService.watchStatus(for: videoId)
    }

    /// Creates a tappable video card button for a carousel item.
    /// - Parameters:
    ///   - index: The index of the item in the carousel, used for color rotation.
    ///   - item: The carousel item to display.
    /// - Returns: A button view containing the video card with scroll transition effects.
    private func carouselItemButton(index: Int, item: any VGRVideoCarouselItem) -> some View {
        Button {
            position = item.id
            Haptics.lightImpact()
            onItemTapped(item)
        } label: {
            VGRVideoCard(
                title: item.title,
                subtitle: item.subtitle,
                duration: item.duration,
                circleColor: colors[index % colors.count],
                watchStatus: watchStatus(for: item.id)
            )
            .id(item.id)
            .containerRelativeFrame(.horizontal,
                                    count: items.count,
                                    span: items.count,
                                    spacing: 16,
                                    alignment: .leading)
            .scrollTransition { view, transition in
                view
                    .scaleEffect(transition.isIdentity ? 1 : 0.96)
            }
            .accessibilityHint("videocard.hint".localizedBundle)
        }
        .buttonStyle(VGRVideoCardButtonStyle())
    }

    public var body: some View {
        VStack(spacing: 16) {
            headerView
            carouselScrollView
        }
        .accessibilityScrollAction({ edge in
            switch edge {
                case .leading:
                    next()
                case .trailing:
                    previous()
                default:
                    break;
            }
        })
        .accessibilityElement(children: .contain)
        .onOrientationChange { _ in
            updateTrailingContentMargin()
        }
        .onAppear {
            setInitialPosition()
            updateTrailingContentMargin()
        }
    }
}

#Preview {
    struct PreviewVideoItem: VGRVideoCarouselItem {
        let id: String
        let title: String
        let subtitle: String
        let duration: String
    }

    let previewItems: [any VGRVideoCarouselItem] = [
        PreviewVideoItem(id: "1", title: "Del 1:", subtitle: "alfa", duration: "3 minuter"),
        PreviewVideoItem(id: "2", title: "Del 2:", subtitle: "beta", duration: "2 minuter"),
        PreviewVideoItem(id: "3", title: "Del 3:", subtitle: "gamma", duration: "4 minuter"),
        PreviewVideoItem(id: "4", title: "Del 4:", subtitle: "delta", duration: "5 minuter"),
        PreviewVideoItem(id: "5", title: "Del 5:", subtitle: "epsilon kokosnötter", duration: "3 minuter"),
        PreviewVideoItem(id: "6", title: "Del 6:", subtitle: "zeta", duration: "2 minuter"),
        PreviewVideoItem(id: "7", title: "Del 7:", subtitle: "eta", duration: "3 minuter"),
    ]

    return NavigationStack {
        ScrollView {
            VGRVideoCarousel(title: "Videoklipp",
                             subtitle: "Korta filmer om något",
                             items: previewItems) { item in
                print("Tapped item \"\(item.title) \(item.subtitle)\"")
            }
            .padding(.top, 40)
        }
        .background(Color.Accent.brownSurfaceMinimal)
        .navigationTitle("VGRVideoCarousel")
    }
}
