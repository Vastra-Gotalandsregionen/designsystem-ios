import SwiftUI

struct VGRContentListView: View {
    let element: VGRContentElement

    /// Optional property that toggles the list from a bulleted list, to an numerically ordered list
    var isOrdered: Bool = false

    @ScaledMetric private var hSpacing: CGFloat = 4
    @ScaledMetric private var vSpacing: CGFloat = 16

    var body: some View {
        Grid(horizontalSpacing: hSpacing, verticalSpacing: vSpacing) {
            ForEach(Array(element.list.enumerated()), id: \.offset) { index, listItem in
                GridRow(alignment: isOrdered ? .top : .center) {
                    Text(isOrdered ? String("\(index + 1).") : "•")
                        .font(.body)

                    Text(listItem)
                        .font(Font.body.leading(.standard))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(Color.Neutral.text)
                .accessibilityElement()
                .accessibilityTextContentType(.narrative)
                .accessibilityLabel(a11yLabel(index, listItem, isOrdered: isOrdered))
            }
        }
        .accessibilityTextContentType(.narrative)
        .padding(.horizontal, VGRSpacing.horizontal)
        .padding(.bottom, VGRSpacing.verticalXLarge)
    }

    private func a11yLabel(_ index: Int, _ text: String, isOrdered: Bool) -> String {
        return isOrdered ? "\(index + 1). \(text)" : text
    }
}

#Preview {
    let previewList: [String] = [
        "First list item with some text",
        "Second list item that might be longer and even possibly stretch to the line below",
        "Third list item",
        "Fourth item to show multiple entries",
        "Fifth item for extended preview",
        "Sixth item to increase list length",
        "Seventh item with some additional wording",
        "Eighth item in the preview list",
        "Ninth item to verify scrolling",
        "Tenth item nearing the end",
        "Eleventh and final preview item"
    ]

    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                Text("In **.list** state")
                    .frame(maxWidth: .infinity, alignment: .center)

                VGRContentListView(
                    element: VGRContentElement(
                        type: .list,
                        list: previewList,
                    )
                )
            }

            VStack(spacing: 32) {
                Text("In **.ordered** state")
                    .frame(maxWidth: .infinity, alignment: .center)

                VGRContentListView(
                    element: VGRContentElement(
                        type: .ordered,
                        list: previewList,
                    ),
                    isOrdered: true
                )
            }
        }
        .navigationTitle("List")
        .navigationBarTitleDisplayMode(.inline)
    }
}
