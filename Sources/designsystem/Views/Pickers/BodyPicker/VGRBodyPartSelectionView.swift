import SwiftUI

/// A view that displays a parent body part and its child parts as selectable items.
///
/// Tapping the parent selects or deselects all children. Tapping individual children updates
/// their selection state and may affect the parent's selection state. The selection state is
/// managed locally and changes are propagated through the `onChange` callback.
struct VGRBodyPartSelectionView: View {

    let parent: VGRBodyPart
    let children: [VGRBodyPart]

    @State var localSelection: Set<VGRBodyPart>
    let onChange: (Set<VGRBodyPart>) -> Void

    init(parent: VGRBodyPart,
         children: [VGRBodyPart],
         selection: Set<VGRBodyPart>,
         onChange: @escaping (Set<VGRBodyPart>) -> Void) {
        
        self.parent = parent
        self.children = children
        self.onChange = onChange

        let tempSelection = selection.intersection([parent] + children)
        self.localSelection = State(initialValue: tempSelection).wrappedValue
    }

    /// selectBodyPart handles selection and deselection of individual bodyparts aswell as grouped bodyparts
    func selectBodyPart(_ part: VGRBodyPart, isParent: Bool = false) {
        if isParent {
            let shouldDeselect = localSelection.contains(parent)
            if shouldDeselect {
                localSelection.remove(parent)
                localSelection.subtract(children)
            } else {
                localSelection.insert(parent)
                localSelection.formUnion(children)
            }
        } else {
            localSelection.formSymmetricDifference([part])

            if children.allSatisfy(localSelection.contains) {
                localSelection.insert(parent)
            } else {
                localSelection.remove(parent)
            }
        }

        onChange(localSelection)
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 0) {
                Item(part: parent, isSelected: localSelection.contains(parent))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .onTapGesture {
                        selectBodyPart(parent, isParent: true)
                    }

                ForEach(Array(children), id: \.id) { child in
                    Divider()
                        .background(Color.Neutral.divider)

                    Item(part: child, isSelected: localSelection.contains(child))
                        .padding(.leading, 32)
                        .padding(.trailing, 16)
                        .padding(.vertical, 16)
                        .onTapGesture {
                            selectBodyPart(child)
                        }
                }
            }
            .background(Color.Elevation.elevation1)
            .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 32)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Elevation.background)
    }

    private struct Item: View {
        let part: VGRBodyPart
        let isSelected: Bool

        var a11yLabel: String {
            let name = "bodypicker.\(part.id)".localizedBundle
            return isSelected ? "\(name), \("general.selected".localizedBundle)" : name
        }

        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(Color.Primary.action)

                Text("bodypicker.\(part.id)".localizedBundle)
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if part.side != .notApplicable {
                    Text("bodypicker.\(part.side.rawValue)".localizedBundle)
                        .font(.caption2).fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .foregroundStyle(Color.Status.successText)
                        .background(Color.Status.successSurface)
                        .cornerRadius(46)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .accessibilityLabel(a11yLabel)
        }
    }
}

#Preview {
    let parent: VGRBodyPart = .front(.leftArm)
    let children: [VGRBodyPart] = [.front(.leftUpperArm), .front(.leftArmFold), .front(.leftUnderArm), .front(.leftPalm)]

    VGRBodyPartSelectionView(parent: parent, children: children, selection: [.front(.leftUpperArm)]) { selected in
        for part in selected { print("- ", part.id) }
    }
}
