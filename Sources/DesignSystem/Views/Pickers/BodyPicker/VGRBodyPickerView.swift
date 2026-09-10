import SwiftUI

/// A view that allows users to select body parts on a front and back body diagram.
///
/// The user can toggle between front and back views using a segmented picker.
/// Selected body parts are visually highlighted based on selection state.
///
/// When `trackOn` is given, every region tap on the diagram, every chip tap in the
/// region sheet and every front/back toggle in the segmented control is reported as a
/// `VGRBodyPickerInteraction` event with that screen as the Matomo category. Orientation
/// changes made by the picker itself (jumping to the side a newly selected part is on)
/// are not reported.
///
/// - Parameters:
///   - selectedParts: A binding to the set of selected body parts.
///   - trackOn: The screen taps are tracked on. Nil (the default) disables tracking.
public struct VGRBodyPickerView: View {
    @Binding var selectedParts: Set<String>

    let trackOn: TrackableScreen?

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

    /// The binding handed to the segmented control. Its setter reports the tap before
    /// writing state, so only user toggles are tracked; the automatic switch in
    /// `onChange(of: selectedParts)` writes `selectedOrientation` directly and stays silent.
    private var controlBinding: Binding<VGRBodyOrientation?> {
        Binding(
            get: { selectedOrientation },
            set: { newValue in
                if let newValue, newValue != selectedOrientation {
                    track(.switchOrientation(newValue))
                }
                selectedOrientation = newValue
            }
        )
    }

    public init(selectedParts: Binding<Set<String>>,
                trackOn: TrackableScreen? = nil) {
        self._selectedParts = selectedParts
        self.trackOn = trackOn
    }

    public var body: some View {
        ScrollView {
            VStack {
                HStack(alignment: .center) {
                    VGRBodySelectionView(orientation: orientationBinding,
                                         selectedParts: $selectedParts,
                                         trackOn: trackOn,
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
                selectedItem: controlBinding,
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

    /// Reports an orientation toggle on the tracked screen, if any
    @MainActor
    private func track(_ interaction: VGRBodyPickerInteraction) {
        guard let trackOn else { return }
        Tracker.shared.trackEvent(interaction, on: trackOn)
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

/// Chip taps and front/back toggles are printed to the console as events in the simulator
private enum PreviewScreen: TrackableScreen {
    case bodyPicker
    var identifier: String { "preview_bodypicker" }
}

#Preview("Tracked") {
    @Previewable @State var selectedParts: Set<String> = []

    NavigationStack {
        VGRBodyPickerView(selectedParts: $selectedParts, trackOn: PreviewScreen.bodyPicker)
            .navigationTitle("bodypicker.title".localizedBundle)
            .navigationBarTitleDisplayMode(.inline)
    }
}
