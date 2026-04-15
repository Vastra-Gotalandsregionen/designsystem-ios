import SwiftUI

struct VGRList<Header: View, Content: View>: View {

    private let headerTitle: String?
    private let header: Header
    private let content: Content

    public init(@ViewBuilder header: () -> Header,
                @ViewBuilder content: () -> Content) {
        self.headerTitle = nil
        self.header = header()
        self.content = content()
    }

    public init(header: String,
                @ViewBuilder content: () -> Content) where Header == EmptyView {
        self.headerTitle = header
        self.header = EmptyView()
        self.content = content()
    }

    public init(@ViewBuilder content: () -> Content) where Header == EmptyView {
        self.headerTitle = nil
        self.header = EmptyView()
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .Margins.medium) {
            if let headerTitle {
                Text(headerTitle)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, .Margins.medium)
            } else {
                header
            }

            VStack(spacing: 0) {
                Group(subviews: content) { subviews in
                    ForEach(subviews.indices, id: \.self) { index in
                        subviews[index]
                        if index < subviews.count - 1 {
                            VGRDivider()
                        }
                    }
                }
            }
            .background(Color.Elevation.elevation1)
            .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
        }
        .foregroundStyle(Color.Neutral.text)
    }
}

#Preview {
    @Previewable @State var selectedDate: Date = .now

    NavigationStack {
        ScrollView {
            VStack(spacing: .Margins.medium) {
                VGRList {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                    
                    VGRListRow(title: "Title",
                               subtitle: "Subtitle",
                               icon: { Image(systemName: "bolt") })
                    
                    VGRListRow(title: "Title",
                               subtitle: "Subtitle",
                               icon: { Image(systemName: "bolt") },
                               accessory: {
                        DatePicker("Välj datum", selection: $selectedDate)
                            .labelsHidden()
                    })
                }

                VGRList(header: "Section title") {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
                
                VGRList(header: "Lorem ipsum dolor etcetera och annat som brukar stå här när man testar saker för flera rader") {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }
                
                VGRList(header: { Image(systemName: "star").font(.title) }) {
                    VGRListRow(title: "Title", subtitle: "Subtitle")
                }

            }
        }
        .padding(.horizontal, .Margins.medium)
        .background(Color.Elevation.background)
        .maxLeading()
    }
}
