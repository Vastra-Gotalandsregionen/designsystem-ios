/// `TrackableScreen` is a protocol that represents a screen or view that can be tracked.
/// Each conforming type must provide a unique `identifier` string used for analytics or logging.
///
/// Example:
/// ```swift
/// enum MyApp: TrackableScreen {
///     case home
///     case settings
///     case profile(action: TrackerAction)   // Using built-in TrackerAction
///     case custom(action: CustomAction)     // Using a custom action enum
///
///     var identifier: String {
///         switch self {
///             case .home: return "home"
///             case .settings: return "settings"
///             case .profile(let action): return "profile_\(action.rawValue)"
///             case .custom(let action): return "custom_\(action.rawValue)"
///         }
///     }
/// }
///
/// enum CustomAction: String {
///     case like, share, comment
/// }
///
/// // Usage:
/// tracker.trackScreen(MyApp.profile(action: .select))
/// tracker.trackScreen(MyApp.custom(action: .like))
/// ```
public protocol TrackableScreen {
    var identifier: String { get }
}

/// `TrackableInteraction` is a protocol that represents a discrete interaction a user performs
/// *within* a screen — for example adding a symptom, toggling an option, or choosing a value.
/// Where `TrackableScreen` answers *"where is the user?"*, a `TrackableInteraction` answers
/// *"what did they do while there?"*.
///
/// Each conforming type describes the interaction across up to three fields, which map directly
/// onto Matomo's event model. The screen the interaction happens on supplies the event category,
/// so only the interaction-specific fields are defined here:
/// - `action`: what the user did, e.g. `"add_symptom"` (required) — Matomo `e_a`.
/// - `name`: the specific value or target of the interaction, e.g. `"nausea"` (optional) — Matomo `e_n`.
/// - `value`: an optional numeric metric Matomo can sum or average, e.g. a pain level (optional) — Matomo `e_v`.
///
/// `name` and `value` default to `nil`, so simple interactions only need to provide `action`.
///
/// Example:
/// ```swift
/// enum HeadacheInteraction: TrackableInteraction {
///     case addSymptom(String)    // name carries which symptom
///     case setPainLevel(Int)     // value carries the number
///
///     var action: String {
///         switch self {
///             case .addSymptom: return "add_interest"
///             case .setPainLevel: return "set_pain_level"
///         }
///     }
///
///     var name: String? {
///         switch self {
///             case .addSymptom(let symptom): return symptom
///             case .setPainLevel: return nil
///         }
///     }
///
///     var value: Float? {
///         switch self {
///             case .setPainLevel(let painLevel): return Float(painLevel)
///             default: return nil
///         }
///     }
/// }
///
/// // Usage: the screen supplies the category, the interaction supplies action/name/value.
/// tracker.trackEvent(HeadacheInteraction.addSymptom("nausea"), on: MigraineApp.headache(action: .create))
/// tracker.trackEvent(HeadacheInteraction.setPainLevel(4), on: MigraineApp.headache(action: .edit))
/// ```
public protocol TrackableInteraction {
    var action: String { get }   // e_a — what they did
    var name: String? { get }    // e_n — the specific value/target
    var value: Float? { get }    // e_v — optional numeric metric
}

public extension TrackableInteraction {
    var name: String? { nil }
    var value: Float? { nil }
}
