import Foundation
import SwiftUI

/// ExampleEventData holds an array of ExampleEvents
struct ExampleEventData: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let isToday: Bool
    var events: [ExampleEvent]

    init(isToday: Bool = false, events: [ExampleEvent]) {
        self.id = UUID()
        self.isToday = isToday
        self.events = events
    }
}

/// ExampleEvent is one specific event
struct ExampleEvent: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    var type: ExampleEventType

    init(type: ExampleEventType) {
        self.id = UUID()
        self.type = type
    }
}

/// ExampleEventType is the category of event
enum ExampleEventType: String, Codable, CaseIterable {
    case work, personal, family

    var color: Color {
        switch self {
            case .work: return .blue
            case .personal: return .red
            case .family: return .yellow
        }
    }
}
