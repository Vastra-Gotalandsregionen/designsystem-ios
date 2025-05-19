import SwiftUI

/// A view that displays a segmented human body (front or back) with selected regions.
///
/// The view renders a vector body layout using `VGRBodyPartShape`s and highlights
/// selected regions.
///
/// Use `selectedParts`, `bodyParts`, and `overlayParts` to configure the visible body layout.
public struct VGRBodyView: View {

    /// List of selected parts (to be highlighted)
    let selectedParts: Set<VGRBodyPart>

    /// The flat list of body parts used to render the base shape of the body.
    let bodyParts: [VGRBodyPart]

    /// Overlay-only parts such as face features that should be drawn but not selectable.
    var overlayParts: [VGRBodyPart] = []

    let fillColor: Color
    let fillColorSelection: Color
    let strokeColor: Color
    var strokeWidth: CGFloat = 1
    let strokeColorSelection: Color

    /// Returns a text summary of what body parts are selected
    var a11yLabel: String {
        if selectedParts.count == 0 {
            return "bodypicker.summary.none".localizedBundle
        }
        
        let parts = selectedParts.map { part in
            let prefix = part.side != .notApplicable ? "bodypicker.side.\(part.side)".localizedBundle : ""
            let partName = "bodypicker.\(part.id)".localizedBundle
            return [prefix.lowercased(), partName.lowercased()].joined(separator: " ")
        }
        return "bodypicker.summary".localizedBundleFormat(arguments: parts.joined(separator: ", "))
    }

    public init(selectedParts: Set<VGRBodyPart>,
                bodyParts: [VGRBodyPart],
                overlayParts: [VGRBodyPart],
                fillColor: Color,
                fillColorSelection: Color,
                strokeColor: Color,
                strokeWidth: CGFloat = 1,
                strokeColorSelection: Color) {
        self.selectedParts = selectedParts
        self.bodyParts = bodyParts
        self.overlayParts = overlayParts
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
                ForEach(bodyParts, id: \.self) { bodyPart in
                    VGRBodyPartShape(bodyPart: bodyPart)
                        .fill(fillColor)
                        .stroke(strokeColor, lineWidth: selectedParts.contains(bodyPart) ? 0 : strokeWidth)
                        .accessibilityHidden(true)
                }

                /// Draw the selected body parts, in correct order to avoid overlap
                ForEach(selectedParts.sorted(by: { $0.drawOrder < $1.drawOrder }), id: \.self) { part in
                    VGRBodyPartShape(bodyPart: part)
                        .fill(fillColorSelection)
                        .stroke(strokeColorSelection, lineWidth: strokeWidth)
                        .accessibilityHidden(true)
                }

                /// Draw non-selectable overlay parts (such as facial features)
                ForEach(overlayParts, id:\.self) { part in
                    VGRBodyPartShape(bodyPart: part)
                        .stroke(strokeColor, lineWidth: strokeWidth)
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
    let selectedFrontBodyParts: Set<VGRBodyPart> = [.front(.leftArmFold), .front(.scalp)]
    let selectedBackBodyParts: Set<VGRBodyPart> = [.back(.leftArmElbow), .back(.rightHollowOfKnee)]

    NavigationStack {
        ScrollView {
            HStack {
                VGRBodyView(selectedParts: selectedFrontBodyParts,
                         bodyParts: VGRBodyPart.neutralFront,
                         overlayParts: [.front(.faceFeatures)],
                         fillColor: Color(red: 231/255, green: 225/255, blue: 223/255),
                         fillColorSelection: Color(red: 238/255, green: 100/255, blue: 146/255),
                         strokeColor: Color.black,
                         strokeWidth: 0.5,
                         strokeColorSelection: Color.black)
                .frame(width: 100, height: 300)

                VGRBodyView(selectedParts: selectedBackBodyParts,
                         bodyParts: VGRBodyPart.neutralBack,
                         overlayParts: [],
                         fillColor: Color(red: 231/255, green: 225/255, blue: 223/255),
                         fillColorSelection: Color(red: 238/255, green: 100/255, blue: 146/255),
                         strokeColor: Color.black,
                         strokeColorSelection: Color.black)
                .frame(width: 100, height: 300)
            }
        }
        .frame(maxWidth: .infinity)
        .background(.cyan)
        .navigationTitle("VGRBodyView")
        .navigationBarTitleDisplayMode(.inline)
    }
}
