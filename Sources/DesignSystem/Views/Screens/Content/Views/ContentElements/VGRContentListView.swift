import SwiftUI

struct VGRContentListView: View {
    let element: VGRContentElement

    /// Optional property that toggles the list from a bulleted list, to an numerically ordered list
    var isOrdered: Bool = false

    @ScaledMetric private var bulletColumn: CGFloat = 15

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(element.list.enumerated()), id: \.offset) { index, listItem in
                HStack(alignment: .top, spacing: 4) {
                    Text(isOrdered ? String("\(index + 1).") : "•")
                        .accessibilityHidden(isOrdered ? false : true)
                        .frame(width: bulletColumn,
                               alignment: isOrdered ? .trailing : .center)

                    Text(listItem)
                        .font(Font.body.leading(.standard))
                        .accessibilityAddTraits(.isStaticText)
                        .foregroundColor(Color.Neutral.text)
                        .accessibilityTextContentType(.narrative)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, VGRSpacing.horizontalList)
                .accessibilityAddTraits(.isStaticText)
            }
        }
        .padding(.bottom, VGRSpacing.verticalXLarge)
    }
}

#Preview {

    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                Text("In **.list** state")
                    .frame(maxWidth: .infinity, alignment: .center)

                VGRContentListView(
                    element: VGRContentElement(
                        type: .list,
                        list: [
                            "First list item with some text",
                            "Second list item that might be longer and even possibly stretch to the line below",
                            "Third list item",
                            "Fourth item to show multiple entries"
                        ],
                    )
                )
            }

            VStack(spacing: 32) {
                Text("In **.ordered** state")
                    .frame(maxWidth: .infinity, alignment: .center)

                VGRContentListView(
                    element: VGRContentElement(
                        type: .ordered,
                        list: [
                            "First list item with some text",
                            "Second list item that might be longer and even possibly stretch to the line below",
                            "Third list item",
                            "Fourth item to show multiple entries"
                        ],
                    ),
                    isOrdered: true
                )
            }
        }
        .navigationTitle("List")
        .navigationBarTitleDisplayMode(.inline)
    }
}
