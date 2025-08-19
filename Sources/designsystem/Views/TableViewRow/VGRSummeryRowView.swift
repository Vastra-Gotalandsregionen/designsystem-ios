import SwiftUI

///A reusable SwiftUI row view that displays up to three customizable content views and an optional trailing icon.
/// - Parameters:
///   - trailingIcon: An optional trailing image
///   - indicatorColor: Background color for the leading content
struct VGRSummaryRowView<Content: View>: View {

    var content1: (() -> Content)? = nil
    let content2: () -> Content
    let content3: () -> Content
    var trailingIcon: Image?
    var indicatorColor: Color?

    var body: some View {
        if let content1 {
            content1()
                .frame(minWidth: 32, minHeight: 32)
                .font(.caption2)
                .background(indicatorColor)
        } else {
            EmptyView()
        }
        content2()
        Spacer()
        content3()
            .font(.title)
            .bold()
        if let image = trailingIcon {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.Primary.action)
                .padding(.trailing, 16)
        }
    }
}

#Preview("Everything applies") {
    var indicationNumber: String = "7,4"
    HStack(spacing: 4) {
        VGRSummaryRowView(
            content1: {
                Text("\(indicationNumber)")
            },
            content2: {
                Text("Vilken raiting får vald modell?")
            },
            content3: {
                Text("3310")
            },
            trailingIcon: Image(systemName: "chevron.right"),
            indicatorColor: Color.Status.successSurface
        )
    }
}

#Preview("Minimal effort") {
    HStack(spacing: 4) {
        VGRSummaryRowView(
            content2: {
                Text("Hur går det på en skala?")
            },
            content3: {
                Text("3")
            },
        )
    }
}
