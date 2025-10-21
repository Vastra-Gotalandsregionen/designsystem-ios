import Foundation

public struct VGRVideo: Identifiable, VGRVideoCarouselItem {
    
    public init(id: String, title: String, subtitle: String, duration: String, url: String, publishDate: Date? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.url = url
        self.publishDate = publishDate
    }
    
   public let id: String
   public let title: String
   public let subtitle: String
   public var duration: String
   public let url: String
   public var publishDate: Date?
}
