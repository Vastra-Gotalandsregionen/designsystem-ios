import SwiftUI

/// A view that displays a segmented human body (front or back) with selectable regions.
///
/// The view renders a vector body layout using `VGRBodyPartShape`s and highlights
/// selected regions. Tapping a container region opens a modal sheet for selecting
/// its child parts.
///
/// Use `bodyHierarchy`, `bodyParts`, and `overlayParts` to configure the visible body layout.
struct VGRBodyPartDataSelectionView: View {

    @Binding var selectedParts: Set<VGRBodyPart>

    /// The hierarchy defining which body parts are containers and their child parts.
    let bodyHierarchy: [VGRBodyPartData]

    /// The flat list of body parts used to render the base shape of the body.
    let bodyParts: [VGRBodyPart]

    /// Overlay-only parts such as face features that should be drawn but not selectable.
    var overlayParts: [VGRBodyPart] = []

    let fillColor: Color
    let fillColorSelection: Color
    let strokeColor: Color
    let strokeColorSelection: Color

    /// Whether to show the modal sheet for container part selection.
    @State private var showModal: Bool = false

    /// The container body part currently being edited in the modal.
    @State private var parentBodyPart: VGRBodyPart? = nil

    /// Returns the container (parent) body part for a given part.
    ///
    /// If the part itself is a container, it returns the part.
    func getContainer(_ part: VGRBodyPart) -> VGRBodyPart? {
//        bodyHierarchy.keys.contains(part) ? part : bodyHierarchy.first(where: { $0.value.contains(part) })?.key
        return nil
    }

    func selectBodyPart(_ part: VGRBodyPart) {
        if let cnt = getContainer(part) {
            parentBodyPart = cnt
        }
    }

    var body: some View {
        VStack {
            ZStack {
                /// Draw the default body shape
                ForEach(bodyParts, id: \.self) { bodyPart in
                    VGRBodyPartShape(bodyPart: bodyPart)
                        .fill(fillColor)
                        .stroke(strokeColor, lineWidth: selectedParts.contains(bodyPart) ? 0 : 1)
                        .contentShape(VGRBodyPartShape(bodyPart: bodyPart))
                        .onTapGesture {
                            selectBodyPart(bodyPart)
                        }
                        .accessibilityLabel("bodypicker.\(bodyPart.id)".localizedBundle)
                        .accessibilityAction(named: "bodypicker.select".localizedBundle, {
                            selectBodyPart(bodyPart)
                        })
                }

                /// Draw the selected body parts, in correct order to avoid overlap
                ForEach(selectedParts.sorted(by: { $0.drawOrder < $1.drawOrder }), id: \.self) { part in
                    VGRBodyPartShape(bodyPart: part)
                        .fill(fillColorSelection)
                        .stroke(strokeColorSelection, lineWidth: 1)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                /// Draw non-selectable overlay parts (such as facial features)
                ForEach(overlayParts, id:\.self) { part in
                    VGRBodyPartShape(bodyPart: part)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: 296, height: 815)
        }
        .frame(maxWidth: .infinity)
        /// Modal sheet for selecting children of a container part
//        .sheet(item: $parentBodyPart) {
//            print("dismissing")
//        } content: { part in
//            VGRBodyPartSelectionView(parent: part,
//                                     children: bodyHierarchy[part] ?? [],
//                                     selection: selectedParts) { selection in
//                print("Selection changed: \(selection)")
//
//                /// Remove the parent and its children from the main selection
//                selectedParts.subtract([part] + (bodyHierarchy[part] ?? []))
//
//                /// Add the updated selection
//                selectedParts.formUnion(selection)
//            }
//            .presentationDetents([.medium, .large])
//            .presentationDragIndicator(.visible)
//        }
    }
}

#Preview("Front") {
    @Previewable @State var selectedBodyParts: Set<VGRBodyPart> = [.front(.leftArmFold), .front(.scalp)]

    NavigationStack {
        ScrollView {
            VGRBodySelectionView(selectedParts: $selectedBodyParts,
                     bodyHierarchy: VGRBodyPart.frontHierarchy,
                     bodyParts: VGRBodyPart.neutralFront,
                     overlayParts: [.front(.faceFeatures)],
                     fillColor: Color(red: 231/255, green: 225/255, blue: 223/255),
                     fillColorSelection: Color(red: 238/255, green: 100/255, blue: 146/255),
                     strokeColor: Color.black,
                     strokeColorSelection: Color.black)
        }
        .frame(maxWidth: .infinity)
        .background(.cyan)
        .navigationTitle("bodypicker.title".localizedBundle)
    }
}
