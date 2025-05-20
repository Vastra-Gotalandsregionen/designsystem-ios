import SwiftUI

/// A view that displays a parent body part and its child parts as selectable items.
///
/// Tapping the parent selects or deselects all children. Tapping individual children updates
/// their selection state and may affect the parent's selection state. The selection state is
/// managed locally and changes are propagated through the `onChange` callback.
struct VGRBodyPartDataSelectionView: View {

    let orientation: VGRBodyOrientation
    let parent: VGRBodyPartData
    let children: [VGRBodyPartData]

    /// filteredChildren returns the VGRBodyPartData elements that are in the current orientation
    var filteredChildren: [VGRBodyPartData] {
        children.filter { $0.visualparts[orientation] != nil }
    }

    @State var localSelection: Set<String>
    let onChange: (Set<String>) -> Void

    init(_ orientation: VGRBodyOrientation,
         parent: VGRBodyPartData,
         children: [VGRBodyPartData],
         selection: Set<String>,
         onChange: @escaping (Set<String>) -> Void) {

        self.orientation = orientation
        self.parent = parent
        self.children = children
        self.onChange = onChange

        let filtered = children.filter { $0.visualparts[orientation] != nil }
        let tempSelection = selection.intersection([parent.id] + filtered.map { $0.id })
        self.localSelection = State(initialValue: tempSelection).wrappedValue
    }

    /// selectBodyPart handles selection and deselection of individual bodyparts aswell as grouped bodyparts
    func selectBodyPart(_ part: String, isParent: Bool = false) {
        if isParent {
            let shouldDeselect = localSelection.contains(parent.id)
            if shouldDeselect {
                localSelection.remove(parent.id)
                localSelection.subtract(filteredChildren.map { $0.id })
            } else {
                localSelection.insert(parent.id)
                localSelection.formUnion(filteredChildren.map { $0.id })
            }
        } else {
            localSelection.formSymmetricDifference([part])

            if filteredChildren.map({ $0.id }).allSatisfy(localSelection.contains) {
                localSelection.insert(parent.id)
            } else {
                localSelection.remove(parent.id)
            }
        }

        onChange(localSelection)
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 0) {
                Item(part: parent, isSelected: localSelection.contains(parent.id))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .onTapGesture {
                        selectBodyPart(parent.id, isParent: true)
                    }

                ForEach(Array(filteredChildren), id: \.id) { child in
                    Divider()
                        .background(Color.Neutral.divider)

                    Item(part: child, isSelected: localSelection.contains(child.id))
                        .padding(.leading, 32)
                        .padding(.trailing, 16)
                        .padding(.vertical, 16)
                        .onTapGesture {
                            selectBodyPart(child.id)
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
        let part: VGRBodyPartData
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
    let parent: VGRBodyPartData = VGRBodyPartData.body.randomElement()!
    let selected: Set<String> = [parent.subparts.randomElement()!.id]

    VGRBodyPartDataSelectionView(.front,
                                 parent: parent,
                                 children: parent.subparts,
                                 selection: selected) { selected in
        for part in selected { print("- ", part) }
    }
}
