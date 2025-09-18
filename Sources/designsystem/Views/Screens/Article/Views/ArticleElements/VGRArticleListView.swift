import SwiftUI

struct VGRArticleListView: View {
    let element: VGRArticleElement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(element.list, id: \.self) { listItem in
                HStack(alignment: .top) {
                    Text("•")
                        .accessibilityHidden(true)
                    Text(listItem)
                        .font(Font.body.leading(.standard))
                        .accessibilityAddTraits(.isStaticText)
                        .foregroundColor(Color.Neutral.text)
                        .accessibilityTextContentType(.narrative)
                }
                .padding(.horizontal, VGRArticleSpacing.horizontalList)
            }
        }
        .padding(.bottom, VGRArticleSpacing.verticalXLarge)
    }
}

#Preview {
    VGRArticleListView(
        element: VGRArticleElement(
            type: .list,
            list: [
                "First list item with some text",
                "Second list item that might be longer",
                "Third list item",
                "Fourth item to show multiple entries"
            ],
        )
    )
}
