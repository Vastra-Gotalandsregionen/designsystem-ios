import Foundation
import SwiftUI

public struct VGRSegmentedPicker: View {
    let sources: [String]
    @Binding var selectedIndex: Int?
    
    public init(items: [String], selectedIndex: Binding<Int?>) {
        self.sources = items
        self._selectedIndex = selectedIndex
    }

    
    public var body: some View {
        SegmentedControlView(sources, selectedIndex: $selectedIndex) { item, selected in
            Text(item)
                .frame(minWidth: 80, idealWidth: 108, maxWidth: .infinity)
                .font(.body)
                .lineLimit(1)
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 5, trailing: 8))
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
    @Previewable @State var selectedIndex: Int? = 2
    @Previewable @State var selectedIndexNoDefault: Int? = -1
    @Previewable @State var selectedIndexPeriodType: Int? = -1

    let items: [String] = ["One", "Two", "Three", "Four", "Five"]

    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                VStack {

                    LabeledContent {
                        Text("Index: \(selectedIndex ?? -1)")
                    } label: {
                        Text("With default value")
                    }

                    VGRSegmentedPicker(items: items,
                                       selectedIndex: $selectedIndex)
                }
                .padding(16)


                VStack {
                    LabeledContent {
                        Text("Index: \(selectedIndexNoDefault ?? -1)")
                    } label: {
                        Text("No default value")
                    }
                    VGRSegmentedPicker(items: items,
                                       selectedIndex: $selectedIndexNoDefault)
                }
                .padding(16)


                VStack {
                    LabeledContent {
                        Text("Index: \(selectedIndexPeriodType ?? -1)")
                    } label: {
                        Text("No default value")
                    }

                    VGRSegmentedPicker(items: Array(items.prefix(2)),
                                       selectedIndex: $selectedIndexPeriodType)
                }
                .padding(16)
            }
        }
        .navigationTitle("VGRSegmentedPicker")
    }
}
