/// The chip taps a user can perform in the body picker's region sheet, reported as
/// Matomo events when `VGRBodyPickerView` is given a screen to track on.
///
/// One event is emitted per tap, describing what the user did rather than the resulting
/// selection state. Derived changes (a region auto-completing when its last part is
/// selected, "other" being dropped, legacy id translation, programmatic writes to the
/// binding) are never reported. Region and part taps use distinct actions so they can be
/// segmented in Matomo without parsing ids; the body part id is carried as the event name.
///
/// ```
/// select_bodypart   / deselect_bodypart   name=head.scalp
/// select_region     / deselect_region     name=head
/// ```
public enum VGRBodyPickerInteraction: TrackableInteraction, Equatable {
    /// A single body part chip was tapped, e.g. `head.scalp`
    case selectPart(String)
    case deselectPart(String)

    /// The whole-region chip was tapped, e.g. `head`
    case selectRegion(String)
    case deselectRegion(String)

    public var action: String {
        switch self {
            case .selectPart: return "select_bodypart"
            case .deselectPart: return "deselect_bodypart"
            case .selectRegion: return "select_region"
            case .deselectRegion: return "deselect_region"
        }
    }

    public var name: String? {
        switch self {
            case .selectPart(let id), .deselectPart(let id),
                 .selectRegion(let id), .deselectRegion(let id):
                return id
        }
    }
}
