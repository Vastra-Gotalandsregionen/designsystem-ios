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

    var fillColor: Color = Color.Accent.brownSurfaceFixed
    var fillColorSelection: Color = Color.Accent.purpleGraphicFixed
    var strokeColor: Color = Color.black
    var strokeWidth: CGFloat = 1
    var strokeColorSelection: Color = Color.black

    @State private var selectedOrientation: VGRBodyOrientation? = .front

    /// A non-optional binding for VGRBodySelectionView, defaulting to .front if nil
    private var orientationBinding: Binding<VGRBodyOrientation> {
        Binding(
            get: { selectedOrientation ?? .front },
            set: { selectedOrientation = $0 }
        )
    }

    public init(selectedParts: Binding<Set<String>>) {
        self._selectedParts = selectedParts
    }

    public var body: some View {
        ScrollView {
            VStack {
                HStack(alignment: .center) {
                    VGRBodySelectionView(orientation: orientationBinding,
                                         selectedParts: $selectedParts,
                                         fillColor: fillColor,
                                         fillColorSelection: fillColorSelection,
                                         strokeColor: strokeColor,
                                         strokeWidth: strokeWidth,
                                         strokeColorSelection: strokeColorSelection)
                    .onChange(of: selectedParts) { oldValue, newValue in
                        let changes = newValue.subtracting(oldValue)

                        /// If the change is a single body part
                        if changes.count == 1,
                           let first = changes.first,
                           let currentOrientation = selectedOrientation {

                            /// Check if the newly selected part is only visible on the opposite orientation
                            if let partData = VGRBodyPartData.parts(matching: [first]).first {
                                let availableOrientations = Set(partData.visualparts.keys)

                                /// If part is only visible on one orientation and it's not the current one, switch
                                if availableOrientations.count == 1,
                                   let onlyOrientation = availableOrientations.first,
                                   onlyOrientation != currentOrientation {
                                    selectedOrientation = onlyOrientation
                                }
                            }
                        }
                    }
                }
                .padding(.top, .Margins.xtraLarge * 2)
                .padding(.bottom, .Margins.xtraLarge)
            }
            .background(Color.Elevation.elevation1)
            .cornerRadius(.Radius.mainRadius)
            .padding(.horizontal, .Margins.medium)
        }
        .background(Color.Accent.purpleSurfaceMinimal)
        .overlay(alignment: .top) {
            VGRSegmentedControl(
                items: [VGRBodyOrientation.front, VGRBodyOrientation.back],
                selectedItem: $selectedOrientation,
                displayText: { orientation in
                    "bodypicker.\(orientation.rawValue)".localizedBundle
                },
                accessibilityId: { orientation in
                    "bodypicker.\(orientation.rawValue)".localizedBundle
                }
            )
            .padding(.horizontal, .Margins.xtraLarge)
            .padding(.top, .Margins.medium)
        }

    }
}

#Preview {
    @Previewable @State var selectedParts: Set<String> = []

    NavigationStack {
        VGRBodyPickerView(selectedParts: $selectedParts)
            .navigationTitle("bodypicker.title".localizedBundle)
            .navigationBarTitleDisplayMode(.inline)
    }
}
