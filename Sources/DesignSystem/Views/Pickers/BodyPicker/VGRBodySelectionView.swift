import SwiftUI

/// A view that displays a segmented human body (front or back) with selectable regions.
///
/// The view renders a vector body layout using `VGRBodyPartShape`s and highlights
/// selected regions. Tapping a container region opens a modal sheet for selecting
/// its child parts.
///
/// Use `orientation` and `selectedParts` to configure the visible body layout.
struct VGRBodySelectionView: View {

    var orientation: VGRBodyOrientation = .front

    @Binding var selectedParts: Set<String>

    /// drawableSelectedParts returns the VGRBodyParts that can be drawn using the
    /// bodyHieararchy and the selectedParts property
    private var drawableSelectedParts: Set<VGRBodyPart> {
        func collect(from parts: [VGRBodyPartData]) -> [VGRBodyPart] {
            parts.flatMap { part in
                var result: [VGRBodyPart] = []

                /// If selected, grab the visual part for current orientation
                if selectedParts.contains(part.id),
                   let visual = part.visualparts[orientation] {
                    result.append(visual)
                }

                /// Recursively collect from subparts
                result.append(contentsOf: collect(from: part.subparts))
                return result
            }
        }

        return Set(collect(from: bodyHierarchy))
    }

    /// The hierarchy defining which body parts are containers and their child parts.
    private let bodyHierarchy: [VGRBodyPartData] = VGRBodyPartData.body

    /// The flat list of body parts used to render the base shape of the body.
    private var defaultBodyParts: [VGRBodyPart] {
        return orientation == .front ? VGRBodyPart.neutralFront : VGRBodyPart.neutralBack
    }

    /// Overlay-only parts such as face features that should be drawn but not selectable.
    private var overlayParts: [VGRBodyPart] {
        return orientation == .front ? [.front(.faceFeatures)] : []
    }

    var fillColor: Color = Color.Accent.brownSurface
    var fillColorSelection: Color = Color.Accent.pinkGraphic
    var strokeColor: Color = Color.black
    var strokeWidth: CGFloat = 1
    var strokeColorSelection: Color = Color.black

    /// Whether to show the modal sheet for container part selection.
    @State private var showModal: Bool = false

    /// The container body part currently being edited in the modal.
    @State private var parentBodyPart: VGRBodyPartData? = nil

    /// Returns the container (parent) body part for a given part.
    ///
    /// If the part itself is a container, it returns the part.
    private func getContainer(for visualPart: VGRBodyPart, in parts: [VGRBodyPartData]) -> VGRBodyPartData? {
        for dataPart in parts {
            /// Check current part
            if dataPart.visualparts.values.contains(visualPart) {
                return dataPart
            }

            /// Recursively search subparts
            if let _ = getContainer(for: visualPart, in: dataPart.subparts) {
                /// If there was a match, return the parent
                return dataPart
            }
        }

        /// Not found
        return nil
    }

    private func selectBodyPart(_ part: VGRBodyPart) {
        if let cnt = getContainer(for: part, in: bodyHierarchy) {
            parentBodyPart = cnt
        }
    }

    private func a11yLabel(for part: VGRBodyPart) -> String {
        func findPart(matching part: VGRBodyPart, in parts: [VGRBodyPartData]) -> VGRBodyPartData? {
            for data in parts {
                /// Check if this data has the visual part
                if data.visualparts.values.contains(part) {
                    return data
                }
                /// Recursively search subparts
                if let match = findPart(matching: part, in: data.subparts) {
                    return match
                }
            }
            return nil
        }

        guard let match = findPart(matching: part, in: VGRBodyPartData.body) else {
            return "bodypicker.unknown".localizedBundle
        }

        let sideKey = match.side == .notApplicable ? "" : "bodypicker.side.\(match.side)".localizedBundle + " "
        let nameKey = "bodypicker.\(match.id)".localizedBundle
        return (sideKey + nameKey)
    }

    var body: some View {
        VStack {
            ZStack {
                /// Draw the default body shape
                ForEach(defaultBodyParts, id: \.self) { bodyPart in
                    VGRBodyPartShape(bodyPart: bodyPart)
                        .fill(fillColor)
                        .stroke(strokeColor, lineWidth: drawableSelectedParts.contains(bodyPart) ? 0 : strokeWidth)
                        .contentShape(VGRBodyPartShape(bodyPart: bodyPart))
                        .onTapGesture {
                            selectBodyPart(bodyPart)
                        }
                        .accessibilityLabel(a11yLabel(for: bodyPart))
                        .accessibilityAction(named: "bodypicker.select".localizedBundle, {
                            selectBodyPart(bodyPart)
                        })
                }

                /// Draw the selected body parts, in correct order to avoid overlap
                ForEach(drawableSelectedParts.sorted(by: { $0.drawOrder < $1.drawOrder }), id: \.self) { part in
                    VGRBodyPartShape(bodyPart: part)
                        .fill(fillColorSelection)
                        .stroke(strokeColorSelection, lineWidth: strokeWidth)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                /// Draw non-selectable overlay parts (such as facial features)
                ForEach(overlayParts, id:\.self) { part in
                    VGRBodyPartShape(bodyPart: part)
                        .fill(strokeColor)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: 296, height: 815)
        }
        .frame(maxWidth: .infinity)
        /// Modal sheet for selecting children of a container part
        .sheet(item: $parentBodyPart) {
            print("Dismissing selection sheet")
        } content: { part in
            VGRBodyPartSelectionView(orientation,
                                     parent: part,
                                     children: part.subparts,
                                     selection: selectedParts) { selection in

                /// Remove the parent and its children from the main selection
                selectedParts.subtract([part.id] + (part.subparts.map { $0.id }))

                /// Add the updated selection
                selectedParts.formUnion(selection)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    @Previewable @State var selectedBodyParts: Set<String> = ["left.upper.leg"]

    NavigationStack {
        ScrollView {
            VGRBodySelectionView(orientation: .front, selectedParts: $selectedBodyParts)
        }
        .frame(maxWidth: .infinity)
        .background(.cyan)
        .navigationTitle("bodypicker.title".localizedBundle)
    }
}
