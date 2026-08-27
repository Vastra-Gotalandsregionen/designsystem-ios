import SwiftUI

/// A sheet that displays a parent body part and its child parts as selectable chips.
///
/// Tapping the parent chip selects or deselects all children except the region's
/// "other" part. The parent is considered selected when all other children are
/// selected, and the parent and "other" are mutually exclusive: selecting the
/// whole region deselects "other", and completing the region while "other" is
/// selected drops "other" since the whole region covers it. The selection state
/// is managed locally and changes are propagated immediately through the
/// `onChange` callback.
struct VGRBodyPartSelectionView: View {

    let parent: VGRBodyPartData
    let children: [VGRBodyPartData]

    @State var localSelection: Set<String>
    let onChange: (Set<String>) -> Void

    init(parent: VGRBodyPartData,
         children: [VGRBodyPartData],
         selection: Set<String>,
         onChange: @escaping (Set<String>) -> Void) {

        self.parent = parent
        self.children = children
        self.onChange = onChange

        var initialSelection = selection.intersection([parent.id] + children.map { $0.id })

        /// The whole region and "other" are mutually exclusive, so drop "other"
        /// from selections stored before this rule applied
        if initialSelection.contains(parent.id) {
            initialSelection.remove("\(parent.id).other")
        }

        self._localSelection = State(initialValue: initialSelection)
    }

    /// The id of the region's "other" part, which is excluded from the parent group toggle
    private var otherID: String { "\(parent.id).other" }

    /// Children that participate in the parent group toggle (everything except "other")
    private var groupableChildren: [VGRBodyPartData] {
        children.filter { $0.id != otherID }
    }

    /// Toggles the whole region: the parent and all groupable children.
    /// Selecting the whole region deselects "other" since it is redundant.
    private func toggleParent() {
        let groupIDs = groupableChildren.map { $0.id }

        if localSelection.contains(parent.id) {
            localSelection.remove(parent.id)
            localSelection.subtract(groupIDs)
        } else {
            localSelection.insert(parent.id)
            localSelection.formUnion(groupIDs)
            localSelection.remove(otherID)
        }

        onChange(localSelection)
    }

    /// Toggles a single child and derives the parent's selection state from the groupable children.
    /// When all groupable children are selected the whole region is selected, and "other" is
    /// deselected since the whole region covers it.
    private func toggleChild(_ id: String) {
        localSelection.formSymmetricDifference([id])

        if groupableChildren.map({ $0.id }).allSatisfy(localSelection.contains) {
            localSelection.insert(parent.id)
            localSelection.remove(otherID)
        } else {
            localSelection.remove(parent.id)
        }

        onChange(localSelection)
    }

    private func title(for part: VGRBodyPartData) -> String {
        "bodypicker.\(part.id)".localizedBundle
    }

    /// The side is voiced first ("Vänster, Öra") so VoiceOver users hear it before the part name
    private func a11yLabel(title: String, side: VGRBodySide) -> String {
        guard side != .notApplicable else { return title }
        return "bodypicker.side.\(side.rawValue)".localizedBundle + ", " + title
    }

    var body: some View {
        VGRContainer {
            VGRSection {
                /// Parent chip with a trailing side badge when the region is one-sided
                HStack {
                    VGRChipButton("bodypicker.\(parent.id).whole".localizedBundle) {
                        toggleParent()
                    }
                    .maxLeading()
                    .selected(localSelection.contains(parent.id))
                    .accessibilityLabel(a11yLabel(title: "bodypicker.\(parent.id).whole".localizedBundle,
                                                  side: parent.side))

                    if parent.side != .notApplicable {
                        SideBadge(side: parent.side)
                            .accessibilityHidden(true)
                    }
                }

                Text("bodypicker.details.count".localizedBundleFormat(arguments: children.count))
                    .font(.bodyRegular)
                    .padding(.horizontal, .Margins.medium)
                    .accessibilityAddTraits(.isHeader)

                VGRFlowLayout(
                    horizontalSpacing: .Margins.xtraSmall,
                    verticalSpacing: .Margins.medium
                ) {
                    ForEach(children, id: \.id) { child in
                        /// Only show a side badge when the child's side differs from the
                        /// parent's, e.g. ears on the head but not fingers on the left hand
                        let showsSide = child.side != .notApplicable && child.side != parent.side

                        HStack(spacing: .Margins.xtraSmall / 2) {
                            VGRChipButton(title(for: child)) {
                                toggleChild(child.id)
                            }
                            .selected(localSelection.contains(child.id))
                            .accessibilityLabel(a11yLabel(title: title(for: child),
                                                          side: showsSide ? child.side : .notApplicable))
                        }
                    }
                }
            }
        }
    }

    /// A compact capsule indicating which side of the body a part belongs to
    private struct SideBadge: View {
        let side: VGRBodySide

        var body: some View {
            Text("bodypicker.side.\(side.rawValue)".localizedBundle)
                .font(.caption2).fontWeight(.semibold)
                .padding(.horizontal, .Margins.medium)
                .padding(.vertical, .Margins.xtraSmall)
                .foregroundStyle(side == .left ? Color.Status.errorText : Color.Status.successText)
                .background(side == .left ? Color.Status.errorSurface : Color.Status.successSurface)
                .clipShape(Capsule())
        }
    }
}

#Preview("Huvud") {
    let parent = VGRBodyPartData.body.first(where: { $0.id == "head" })!
    let selected: Set<String> = ["head.scalp", "head.left.ear"]

    VGRBodyPartSelectionView(parent: parent,
                             children: parent.subparts,
                             selection: selected) { selected in
        for part in selected { print("- ", part) }
    }
}

#Preview("Vänster arm") {
    let parent = VGRBodyPartData.body.first(where: { $0.id == "left.arm" })!
    let selected: Set<String> = ["left.arm.other"]

    VGRBodyPartSelectionView(parent: parent,
                             children: parent.subparts,
                             selection: selected) { selected in
        for part in selected { print("- ", part) }
    }
}
