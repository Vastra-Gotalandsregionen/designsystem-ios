import SwiftUI

/// A view that allows users to select body parts on a front and back body diagram.
///
/// The user can toggle between front and back views using a segmented picker.
/// Selected body parts are visually highlighted based on selection state.
///
/// - Parameters:
///   - frontSelectedParts: A binding to the set of selected body parts for the front view.
///   - backSelectedParts: A binding to the set of selected body parts for the back view.
///   - fillColor: The default fill color for body parts.
///   - fillColorSelection: The fill color used to highlight selected body parts.
///   - strokeColor: The stroke color for body parts.
///   - strokeColorSelection: The stroke color for selected body parts.
public struct VGRBodyPickerView: View {
    @Binding var frontSelectedParts: Set<VGRBodyPart>
    @Binding var backSelectedParts: Set<VGRBodyPart>

    var fillColor: Color = Color.Accent.brownSurface
    var fillColorSelection: Color = Color.Accent.pinkGraphic
    var strokeColor: Color = Color.black
    var strokeColorSelection: Color = Color.black

    @State private var bodySide: Int = 0

    public init(frontSelectedParts: Binding<Set<VGRBodyPart>>,
                backSelectedParts: Binding<Set<VGRBodyPart>>) {
        self._frontSelectedParts = frontSelectedParts
        self._backSelectedParts = backSelectedParts
    }

    public var body: some View {
        VStack {
            Picker("bodypicker.title".localizedBundle, selection: $bodySide) {
                Text("bodypicker.front".localizedBundle).tag(0)
                Text("bodypicker.back".localizedBundle).tag(1)
            }
            .pickerStyle(.segmented)

            HStack(alignment: .center) {
                if bodySide == 0 {
                    VGRBodySelectionView(selectedParts: $frontSelectedParts,
                                      bodyHierarchy: VGRBodyPart.frontHierarchy,
                                      bodyParts: VGRBodyPart.neutralFront,
                                      overlayParts: [.front(.faceFeatures)],
                                      fillColor: fillColor,
                                      fillColorSelection: fillColorSelection,
                                      strokeColor: strokeColor,
                                      strokeColorSelection: strokeColorSelection)
                } else {
                    VGRBodySelectionView(selectedParts: $backSelectedParts,
                                      bodyHierarchy: VGRBodyPart.backHierarchy,
                                      bodyParts: VGRBodyPart.neutralBack,
                                      fillColor: fillColor,
                                      fillColorSelection: fillColorSelection,
                                      strokeColor: strokeColor,
                                      strokeColorSelection: strokeColorSelection)
                }
            }
            .padding(.top, 32)

        }
        .padding(16)
        .cornerRadius(16)
    }
}

#Preview {
    @Previewable @State var frontSelectedParts: Set<VGRBodyPart> = []
    @Previewable @State var backSelectedParts: Set<VGRBodyPart> = []

    NavigationStack {
        ScrollView {
            VGRBodyPickerView(frontSelectedParts: $frontSelectedParts,
                           backSelectedParts: $backSelectedParts)
            .background(Color.Elevation.elevation1)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(16)
        }
        .background(Color.Accent.purpleSurfaceMinimal)
        .navigationTitle("bodypicker.title".localizedBundle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
