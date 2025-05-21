import SwiftUI

/// A view that allows users to select body parts on a front and back body diagram.
///
/// The user can toggle between front and back views using a segmented picker.
/// Selected body parts are visually highlighted based on selection state.
///
/// - Parameters:
///   - selectedParts: A binding to the set of selected body parts.
public struct VGRBodyPickerView: View {
    @Binding var selectedParts: Set<String>

    var fillColor: Color = Color.Accent.brownSurface
    var fillColorSelection: Color = Color.Accent.pinkGraphic
    var strokeColor: Color = Color.black
    var strokeWidth: CGFloat = 1
    var strokeColorSelection: Color = Color.black

    @State private var orientationString: String?

    var orientation: VGRBodyOrientation {
        return orientationString == "bodypicker.front".localizedBundle ? .front : .back
    }


    public init(selectedParts: Binding<Set<String>>) {
        self._selectedParts = selectedParts
    }

    public var body: some View {
        VStack {
            VGRSegmentedPicker(
                items: ["bodypicker.front".localizedBundle,
                        "bodypicker.back".localizedBundle],
                selectedItem: $orientationString
            )

            HStack(alignment: .center) {
                VGRBodySelectionView(orientation: orientation,
                                     selectedParts: $selectedParts,
                                     fillColor: fillColor,
                                     fillColorSelection: fillColorSelection,
                                     strokeColor: strokeColor,
                                     strokeWidth: strokeWidth,
                                     strokeColorSelection: strokeColorSelection)
            }
            .padding(.top, 32)
        }
        .padding(16)
        .cornerRadius(16)
    }
}

#Preview {
    @Previewable @State var selectedParts: Set<String> = []

    NavigationStack {
        ScrollView {
            VGRBodyPickerView(selectedParts: $selectedParts)
                .background(Color.Elevation.elevation1)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(16)
        }
        .background(Color.Accent.purpleSurfaceMinimal)
        .navigationTitle("bodypicker.title".localizedBundle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
