/// The taps a user can perform in the body picker, reported as Matomo events when
/// `VGRBodyPickerView` is given a screen to track on.
///
/// One event is emitted per tap, describing what the user did rather than the resulting
/// selection state. Derived changes (a region auto-completing when its last part is
/// selected, "other" being dropped, legacy id translation, programmatic writes to the
/// binding) are never reported. Each kind of tap has its own action so they can be
/// segmented in Matomo without parsing ids; the body part id is carried as the event name.
///
/// ```
/// region_show                             name=head
/// bodypart_selected / bodypart_deselected name=head.scalp
/// region_selected   / region_deselected   name=head
/// ```
public enum VGRBodyPickerInteraction: TrackableInteraction, Equatable {
    /// A region on the body diagram was tapped, opening its sheet, e.g. `head`
    case openRegion(String)

    /// A single body part chip was tapped, e.g. `head.scalp`
    case selectPart(String)
    case deselectPart(String)

    /// The whole-region chip was tapped, e.g. `head`
    case selectRegion(String)
    case deselectRegion(String)

    public var action: String {
        switch self {
            case .openRegion: return "region_show"
            case .selectPart: return "bodypart_selected"
            case .deselectPart: return "bodypart_deselected"
            case .selectRegion: return "region_selected"
            case .deselectRegion: return "region_deselected"
        }
    }

    public var name: String? {
        switch self {
            case .openRegion(let id),
                 .selectPart(let id), .deselectPart(let id),
                 .selectRegion(let id), .deselectRegion(let id):
                return id
        }
    }
}
