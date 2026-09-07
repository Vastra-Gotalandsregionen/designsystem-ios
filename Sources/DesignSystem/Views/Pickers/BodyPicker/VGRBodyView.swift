import SwiftUI

/// A view that displays a segmented human body (front or back) with selected regions.
///
/// The view renders a vector body layout using `VGRBodyPartShape`s and highlights
/// selected regions.
///
/// Use `orientation` and `selectedParts` to configure the visible body layout.
public struct VGRBodyView: View {

    var orientation: VGRBodyOrientation

    /// List of selected parts (to be highlighted)
    let selectedParts: Set<String>

    private var drawableSelectedParts: Set<VGRBodyPart> {
        func collect(from parts: [VGRBodyPartData]) -> [VGRBodyPart] {
            parts.flatMap { part in
                var result: [VGRBodyPart] = []

                /// If selected, grab the visual part for current orientation.
                /// A selected container is drawn as its own whole-region shape,
                /// so its subparts are skipped to avoid stacking child shapes on top.
                if selectedParts.contains(part.id),
                   let visual = part.visualparts[orientation] {
                    result.append(visual)
                } else {
                    /// Recursively collect from subparts
                    result.append(contentsOf: collect(from: part.subparts))
                }
                return result
            }
        }

        return Set(collect(from: VGRBodyPartData.body))
    }

    private var a11ySelectedParts: Set<VGRBodyPartData> {
        func collect(from parts: [VGRBodyPartData]) -> [VGRBodyPartData] {
            parts.flatMap { part in
                var result: [VGRBodyPartData] = []

                /// If selected and has a visual part for the orientation, include it.
                /// Parts with no visual representation at all (eg. "other" details)
                /// are always included so they are voiced on both orientations.
                /// A selected container covers its subparts, so they are skipped
                /// and only the whole region is voiced.
                if selectedParts.contains(part.id),
                   part.visualparts[orientation] != nil || part.visualparts.isEmpty {
                    result.append(part)
                } else {
                    /// Recursively collect from subparts
                    result.append(contentsOf: collect(from: part.subparts))
                }
                return result
            }
        }

        return Set(collect(from: VGRBodyPartData.body))
    }

    /// The flat list of body parts used to render the base shape of the body.
    private var defaultBodyParts: [VGRBodyPart] {
        return orientation == .front ? VGRBodyPart.neutralFront : VGRBodyPart.neutralBack
    }

    /// Overlay-only parts such as face features that should be drawn but not selectable.
    private var overlayParts: [VGRBodyPart] {
        return orientation == .front ? [.front(.faceFeatures)] : []
    }

    var fillColor: Color
    var fillColorSelection: Color
    var strokeColor: Color
    var strokeWidth: CGFloat
    var strokeColorSelection: Color

    /// Returns a text summary of what body parts are selected
    var a11yLabel: String {
        if a11ySelectedParts.count == 0 { return "bodypicker.summary.none".localizedBundle }
        let parts = a11ySelectedParts.map { "bodypicker.\($0.id)".localizedBundle }
        return "bodypicker.summary".localizedBundleFormat(arguments: ListFormatter.localizedString(byJoining: parts))
    }

    public init(orientation: VGRBodyOrientation = .front,
                selectedParts: Set<String>,
                fillColor: Color = Color.Accent.brownSurfaceFixed,
                fillColorSelection: Color = Color.Accent.purpleGraphicFixed,
                strokeColor: Color = Color.black,
                strokeWidth: CGFloat = 1,
                strokeColorSelection: Color = Color.black) {

        self.orientation = orientation
        self.selectedParts = VGRBodyPartData.normalized(selectedParts)
        self.fillColor = fillColor
        self.fillColorSelection = fillColorSelection
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.strokeColorSelection = strokeColorSelection
    }

    public var body: some View {
        VStack {
            ZStack {
                /// Draw the default body shape
                ForEach(defaultBodyParts, id: \.self) { bodyPart in
                    VGRBodyPartShape(bodyPart: bodyPart)
                        .fill(fillColor)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                        .accessibilityHidden(true)
                }

                /// Draw the selected body parts, in correct order to avoid overlap.
                /// Even-odd fill keeps cutouts (such as the ears in the face shape) unfilled.
                ForEach(drawableSelectedParts.sorted(by: { $0.drawOrder < $1.drawOrder }), id: \.self) { part in
                    VGRBodyPartShape(bodyPart: part)
                        .fill(fillColorSelection, style: FillStyle(eoFill: true))
                        .stroke(strokeColorSelection, lineWidth: strokeWidth)
                        .accessibilityHidden(true)
                }

                /// Re-stroke the default region boundaries on top of the selection
                /// fills, so adjacent regions covered by one container shape stay
                /// visually distinct (eg. the head shape includes the throat area)
                ForEach(defaultBodyParts, id: \.self) { bodyPart in
                    VGRBodyPartShape(bodyPart: bodyPart)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                        .accessibilityHidden(true)
                }

                /// Draw non-selectable overlay parts (such as facial features)
                ForEach(overlayParts, id:\.self) { part in
                    VGRBodyPartShape(bodyPart: part)
                        .fill(strokeColor)
                        .accessibilityHidden(true)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yLabel)
    }
}

#Preview {
    let selectedParts: Set<String> = ["left.upper.leg", "head.scalp", "head.face", "right.under.arm", "right.foot", "right.knee", "right.hollow.of.knee", "right.hand"]

    NavigationStack {
        ScrollView {
            HStack {
                VGRBodyView(orientation: .front, selectedParts: selectedParts, strokeWidth: 0.5)
                    .frame(width: 100, height: 300)

                VGRBodyView(orientation: .back, selectedParts: selectedParts)
                    .frame(width: 100, height: 300)
            }
        }
        .frame(maxWidth: .infinity)
        .background(.cyan)
        .navigationTitle("VGRBodyDataView")
        .navigationBarTitleDisplayMode(.inline)
    }
}
