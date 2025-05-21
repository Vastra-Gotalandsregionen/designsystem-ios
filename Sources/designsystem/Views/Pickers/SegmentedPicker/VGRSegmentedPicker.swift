import Foundation
import SwiftUI

public struct VGRSegmentedPicker: View {
    let items: [String]
    let nonScrollableItemCount: Int
    @Binding var selectedItem: String?

    public init(items: [String],
                nonScrollableItemCount: Int = 4,
                selectedItem: Binding<String?>) {
        self.items = items
        self.nonScrollableItemCount = nonScrollableItemCount
        self._selectedItem = selectedItem
    }

    public var body: some View {
        VGRBaseSegmentedControlView(items,
                                    nonScrollableItemCount: nonScrollableItemCount,
                                    insets: EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6),
                                    selectedItem: $selectedItem) { item, selected in
            Text(item)
                .frame(idealWidth: 100, maxWidth: .infinity)
                .font(.footnote)
                .fontWeight(selected ? .bold : .regular)
                .lineLimit(1)
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(selected ? Color.Primary.action : Color.clear)
                )
                .foregroundColor(selected ? Color.Elevation.elevation1 : Color.Primary.action)
                .accessibilityIdentifier(item)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.Elevation.elevation1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Primary.action, lineWidth: 2)
        )
    }
}

#Preview {
    @Previewable @State var selectedItem: String?
    @Previewable @State var selectedItem2: String?

    let items: [String] = ["One", "Two", "Three", "Four", "Five"]

    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                VStack {
                    LabeledContent {
                        Text("Index: \(selectedItem ?? "n/a")")
                    } label: {
                        Text("Horizontally scrollable")
                    }
                    VGRSegmentedPicker(items: items, selectedItem: $selectedItem)
                }
                .padding(16)

                VStack {
                    LabeledContent {
                        Text("Index: \(selectedItem ?? "n/a")")
                    } label: {
                        Text("Fixed, 5 non-scrollable items")
                    }
                    VGRSegmentedPicker(
                        items: items,
                        nonScrollableItemCount: 5,
                        selectedItem: $selectedItem
                    )
                }
                .padding(16)

                VStack {
                    LabeledContent {
                        Text("Index: \(selectedItem2 ?? "n/a")")
                    } label: {
                        Text("Fixed (default 4 non-scrollable)")
                            .lineLimit(1)
                    }

                    VGRSegmentedPicker(items: Array(items.prefix(2)),
                                       selectedItem: $selectedItem2)
                }
                .padding(16)
            }
        }
        .navigationTitle("VGRSegmentedPicker")
    }
}
