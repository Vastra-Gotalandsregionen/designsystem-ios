import SwiftUI

struct VGRNavRow<Icon: View, Accessory: View, Destination: View>: View {

    @ScaledMetric private var chevronSize: CGFloat = 25

    var title: String
    var subtitle: String? = nil
    let icon: Icon
    let accessory: Accessory
    let destination: Destination

    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder accessory: () -> Accessory,
                @ViewBuilder destination: () -> Destination) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
        self.accessory = accessory()
        self.destination = destination()
    }

    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder accessory: () -> Accessory,
                @ViewBuilder destination: () -> Destination) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = EmptyView()
        self.accessory = accessory()
        self.destination = destination()
    }

    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder destination: () -> Destination) where Accessory == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
        self.accessory = EmptyView()
        self.destination = destination()
    }

    public init(title: String,
                subtitle: String? = nil,
                @ViewBuilder destination: () -> Destination) where Icon == EmptyView, Accessory == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = EmptyView()
        self.accessory = EmptyView()
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            VGRListRow(title: title,
                       subtitle: subtitle,
                       icon: { icon },
                       accessory: {

                HStack(spacing:0) {
                    accessory

                    Image(systemName: "chevron.right")
                        .font(.footnoteSemibold)
                        .frame(width: chevronSize, height: chevronSize)
                        .foregroundStyle(Color.Primary.action)
                        .accessibilityHidden(true)
                }
            })
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VGRList {
                VGRNavRow(title:"Title") { Text("Destination") }

                VGRNavRow(title:"Title",
                          subtitle: "Subtitle",
                          icon: { Image(systemName: "bolt") }) {
                    Text("Destination")
                }

                VGRNavRow(title:"Title",
                          subtitle: "Subtitle",
                          accessory: {
                    Text("Detail")
                        .foregroundStyle(.purple)
                }) {
                    Text("Destination")
                }

                VGRNavRow(title:"Title",
                          subtitle: "Subtitle",
                          icon: { Image(systemName: "bolt") },
                          accessory: {
                    Text("Detail")
                        .foregroundStyle(.cyan)
                }) {
                    Text("Destination")
                }
            }
            .padding(.horizontal, .Margins.medium)
        }
        .background(Color.Elevation.background)
    }
}
