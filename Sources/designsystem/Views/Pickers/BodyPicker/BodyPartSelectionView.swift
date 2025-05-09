import SwiftUI

struct BodyPartSelectionView: View {

    let parent: BodyPart
    let children: [BodyPart]

    @State var localSelection: Set<BodyPart>
    let onChange: (Set<BodyPart>) -> Void

    init(parent: BodyPart, children: [BodyPart], selection: Set<BodyPart>, onChange: @escaping (Set<BodyPart>) -> Void) {
        self.parent = parent
        self.children = children
        self.onChange = onChange

        let tempSelection = selection.intersection([parent] + children)
        self.localSelection = State(initialValue: tempSelection).wrappedValue
    }

    func selectBodyPart(_ part: BodyPart, isParent: Bool = false) {
        if isParent {
            if localSelection.contains(parent) {
                localSelection.remove(parent)
                localSelection.subtract(children)
            } else {
                localSelection.insert(parent)
                localSelection.formUnion(children)
            }
        } else {
            if localSelection.contains(part) {
                localSelection.remove(part)
            } else {
                localSelection.insert(part)
            }

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

                    Item(part: child, isSelected: localSelection.contains(child))
                        .padding(.horizontal, 32)
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
        let part: BodyPart
        let isSelected: Bool

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
                        .padding(.horizontal,8)
                        .padding(.vertical, 2)
                        .foregroundStyle(Color.Status.successText)
                        .background(Color.Status.successSurface)
                        .cornerRadius(46)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
}


#Preview {
    BodyPartSelectionView(parent: .front(.leftArm), children: [
        .front(.leftUpperArm),
        .front(.leftArmFold),
        .front(.leftUnderArm),
        .front(.leftPalm)
    ],
                          selection: [.front(.face), .back(.leftArm)]
    ) { selected in
        print(selected)
    }
}
