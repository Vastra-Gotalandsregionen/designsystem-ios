import Foundation

/// A protocol that defines the required properties for items displayed in a `VGRVideoCarousel`.
///
/// Conforming types must provide an identifier, title, subtitle, and duration string
/// that will be displayed in the video carousel card.
protocol VGRVideoCarouselItem: Identifiable {
    /// A unique identifier for the carousel item.
    var id: String { get }

    /// The main title text displayed on the video card.
    var title: String { get }

    /// The subtitle or description text displayed below the title.
    var subtitle: String { get }

    /// The duration of the video, typically formatted as a string (e.g., "3 minuter").
    var duration: String { get }
}
