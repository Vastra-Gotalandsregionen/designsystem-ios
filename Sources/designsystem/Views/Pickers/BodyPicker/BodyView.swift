import SwiftUI

/// A view that displays a segmented human body (front or back) with selectable regions.
///
/// The view renders a vector body layout using `BodyPartShape`s and highlights
/// selected regions. Tapping a container region opens a modal sheet for selecting
/// its child parts.
///
/// Use `bodyHierarchy`, `bodyModel`, and `overlayParts` to configure the visible body layout.
struct BodyView: View {

    @Binding var selectedParts: Set<BodyPart>

    /// The hierarchy defining which body parts are containers and their child parts.
    let bodyHierarchy: [BodyPart: [BodyPart]]

    /// The flat list of body parts used to render the base shape of the body.
    let bodyModel: [BodyPart]

    /// Overlay-only parts such as face features that should be drawn but not selectable.
    var overlayParts: [BodyPart] = []

    let fillColor: Color
    let fillColorSelection: Color
    let strokeColor: Color
    let strokeColorSelection: Color

    /// Whether to show the modal sheet for container part selection.
    @State private var showModal: Bool = false

    /// The container body part currently being edited in the modal.
    @State private var parentBodyPart: BodyPart? = nil

    /// Returns the container (parent) body part for a given part.
    ///
    /// If the part itself is a container, it returns the part.
    func getContainer(_ part: BodyPart) -> BodyPart? {
        bodyHierarchy.keys.contains(part) ? part : bodyHierarchy.first(where: { $0.value.contains(part) })?.key
    }

    var body: some View {
        VStack {
            ZStack {
                /// Draw the default body shape
                ForEach(bodyModel, id: \.self) { model in
                    BodyPartShape(bodyPart: model)
                        .fill(fillColor)
                        .stroke(strokeColor, lineWidth: selectedParts.contains(model) ? 0 : 1)
                        .contentShape(BodyPartShape(bodyPart: model))
                        .onTapGesture {
                            if let cnt = getContainer(model) {
                                parentBodyPart = cnt
                            }
                        }
                        .accessibilityLabel(model.id)
                }

                /// Draw the selected body parts, in correct order to avoid overlap
                ForEach(selectedParts.sorted(by: { $0.drawOrder < $1.drawOrder }), id: \.self) { part in
                    BodyPartShape(bodyPart: part)
                        .fill(fillColorSelection)
                        .stroke(strokeColorSelection, lineWidth: 1)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                /// Draw non-selectable overlay parts (such as facial features)
                ForEach(overlayParts, id:\.self) { part in
                    BodyPartShape(bodyPart: part)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: 296, height: 815)
        }
        .frame(maxWidth: .infinity)
        /// Modal sheet for selecting children of a container part
        .sheet(item: $parentBodyPart) {
            print("dismissing")
        } content: { part in
            BodyPartSelectionView(parent: part,
                                  children: bodyHierarchy[part] ?? [],
                                  selection: selectedParts) { selection in
                print("Selection changed: \(selection)")

                /// Remove the parent and its children from the main selection
                selectedParts.subtract([part] + (bodyHierarchy[part] ?? []))

                /// Add the updated selection
                selectedParts.formUnion(selection)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview("Front") {
    @Previewable @State var selectedBodyParts: Set<BodyPart> = [.front(.leftArmFold), .front(.scalp)]

    NavigationStack {
        ScrollView {
            BodyView(selectedParts: $selectedBodyParts,
                     bodyHierarchy: BodyPart.frontHierarchy,
                     bodyModel: BodyPart.neutralFront,
                     overlayParts: [.front(.faceFeatures)],
                     fillColor: Color(red: 231/255, green: 225/255, blue: 223/255),
                     fillColorSelection: Color(red: 238/255, green: 100/255, blue: 146/255),
                     strokeColor: Color.black,
                     strokeColorSelection: Color.black)
        }
        .frame(maxWidth: .infinity)
        .background(.cyan)
    }
}

#Preview("Back") {
    @Previewable @State var selectedBodyParts: Set<BodyPart> = [.back(.leftArmElbow)]

    NavigationStack {
        ScrollView {
            BodyView(selectedParts: $selectedBodyParts,
                     bodyHierarchy: BodyPart.backHierarchy,
                     bodyModel: BodyPart.neutralBack,
                     overlayParts: [],
                     fillColor: Color(red: 231/255, green: 225/255, blue: 223/255),
                     fillColorSelection: Color(red: 238/255, green: 100/255, blue: 146/255),
                     strokeColor: Color.black,
                     strokeColorSelection: Color.black)
        }
        .frame(maxWidth: .infinity)
        .background(.cyan)
    }
}
