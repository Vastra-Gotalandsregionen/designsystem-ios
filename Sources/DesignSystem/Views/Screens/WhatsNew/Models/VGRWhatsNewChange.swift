import Foundation
import SwiftUI

/// Represents a single change page within a version, displayed as one tab in the WhatsNew carousel.
/// Each change has an ordered list of elements and a template controlling layout sizing.
/// Migrated from migraine-ios `Change`.
public struct VGRWhatsNewChange: Identifiable, Hashable, Equatable, Decodable {

    public var id: UUID = UUID()

    /// Display order in the carousel
    public var order: Int

    /// Layout template: "full" (69% background height) or "half" (46% background height)
    public var template: String

    /// The content elements to render on this page
    public var elements: [VGRWhatsNewChangeElement]

    public static func == (lhs: VGRWhatsNewChange, rhs: VGRWhatsNewChange) -> Bool { lhs.id == rhs.id }

    public enum CodingKeys: String, CodingKey {
        case id, order, template, elements
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        order = try values.decodeIfPresent(Int.self, forKey: .order) ?? 0
        template = try values.decodeIfPresent(String.self, forKey: .template) ?? ""
        elements = try values.decodeIfPresent([VGRWhatsNewChangeElement].self, forKey: .elements) ?? []
    }

    public init(order: Int, template: String, elements: [VGRWhatsNewChangeElement]) {
        self.order = order
        self.template = template
        self.elements = elements
    }
}

/// The supported element types for WhatsNew change content.
/// Migrated from migraine-ios `ChangeElementType`.
public enum VGRWhatsNewChangeElementType: String, Codable {
    /// Body text paragraph
    case body
    /// Secondary headline
    case subhead
    /// Primary headline
    case h1
    /// An image referenced by asset name
    case image
    /// A container panel with padding, background, and nested elements
    case panel
}

/// A single content element within a WhatsNew change page.
/// Supports text, images, and nested panel containers with configurable padding and dimensions.
/// Migrated from migraine-ios `ChangeElement`.
public struct VGRWhatsNewChangeElement: Decodable, Identifiable, Hashable {

    public let id = UUID()

    /// Display order within the parent
    public let order: Int

    /// The type of element to render
    public let type: VGRWhatsNewChangeElementType

    /// Text content (used by body, subhead, h1 types)
    public let text: String

    /// Image asset name (used by image type)
    public let url: String

    /// Padding as [top, leading, bottom, trailing] (used by panel type)
    public let padding: [Int]

    /// Nested child elements (used by panel type)
    public let elements: [VGRWhatsNewChangeElement]

    /// Optional explicit width for image elements
    public var width: Int?

    /// Optional explicit height for image elements
    public var height: Int?

    /// Whether both width and height are specified
    public var hasDimensions: Bool {
        guard let _ = width else { return false }
        guard let _ = height else { return false }
        return true
    }

    /// The width as CGFloat, or 0 if not set
    public var widthValue: CGFloat {
        guard let w = width else { return 0 }
        return CGFloat(w)
    }

    /// The height as CGFloat, or 0 if not set
    public var heightValue: CGFloat {
        guard let h = height else { return 0 }
        return CGFloat(h)
    }

    /// The padding array converted to EdgeInsets
    public var paddingValue: EdgeInsets {
        let top = CGFloat(padding[0])
        let leading = CGFloat(padding[1])
        let bottom = CGFloat(padding[2])
        let trailing = CGFloat(padding[3])

        return EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }

    enum CodingKeys: String, CodingKey {
        case order, type, text, url, padding, elements, width, height
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        order = try values.decode(Int.self, forKey: .order)
        type = try values.decode(VGRWhatsNewChangeElementType.self, forKey: .type)
        text = try values.decodeIfPresent(String.self, forKey: .text) ?? ""
        url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
        padding = try values.decodeIfPresent([Int].self, forKey: .padding) ?? []
        elements = try values.decodeIfPresent([VGRWhatsNewChangeElement].self, forKey: .elements) ?? []
        width = try? values.decode(Int.self, forKey: .width)
        height = try? values.decode(Int.self, forKey: .height)
    }
}
