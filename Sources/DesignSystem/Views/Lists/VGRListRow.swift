import SwiftUI

struct VGRListRow<Icon: View, Accessory: View>: View {

    let title: String
    var subtitle: String? = nil

    private let icon: Icon?
    private let accessory: Accessory?

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder icon: () -> Icon = { EmptyView() },
        @ViewBuilder accessory: () -> Accessory = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
        self.accessory = accessory()
    }

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder accessory: () -> Accessory
    ) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = EmptyView()
        self.accessory = accessory()
    }

    private var verticalPadding: CGFloat {
        return subtitle != nil ? .Margins.small : .Margins.medium
    }

    var body: some View {
        HStack(spacing: .Margins.xtraSmall) {

            if let icon {
                icon
                    .accessibilityHidden(true)
            }

            VStack(spacing: .Margins.xtraSmall / 2) {
                Text(title)
                    .font(.bodyRegular)
                    .maxLeading()

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .maxLeading()
                }
            }
            .padding(.vertical, verticalPadding)
            .foregroundStyle(Color.Neutral.text)

            if let accessory {
                accessory
                    .foregroundStyle(Color.Neutral.textVariant)
            }

        }
        .padding(.horizontal, .Margins.medium)
        .maxLeading()
    }
}

#Preview {
    @Previewable @State var selectedDate: Date  = .now

    NavigationStack {
        ScrollView {
            VGRList {
                /// ListRow with title inline 
                VGRListRow(title:"Title")

                /// ListRow with title inline and accessory as trailing closure
                VGRListRow(title:"Title") {
                    Text("Date")
                }

                /// ListRow with title and subtitle as inline
                VGRListRow(title:"Title", subtitle: "Subtitle")

                /// ListRow with title, subtitle as inline and accessory as trailing closure
                VGRListRow(title:"Title", subtitle: "Subtitle") {
                    Text("Date")
                }

                /// ListRow with title, subtitle and icon
                VGRListRow(title:"Title",
                           subtitle: "Subtitle",
                           icon: { Image(systemName: "bolt") })

                /// ListRow with title, subtitle, icon and accessory, all as inline params
                VGRListRow(title:"Title",
                           subtitle: "Subtitle",
                           icon: { Image(systemName: "bolt")},
                           accessory: {
                    DatePicker(
                        "Välj datum",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                })

                /// ListRow with title, subtitle, icon and accessory, all as inline params
                VGRListRow(title:"Title",
                           subtitle: "Subtitle",
                           icon: { Image(systemName: "bolt") },
                           accessory: {
                    DatePicker(
                        "Välj datum",
                        selection: $selectedDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                })

                /// ListRow with title, subtitle, icon and accessory as a trailing closure
                VGRListRow(title:"An extended title that breaks the line in order to test the components boundaries",
                           subtitle: "Very long subtitle to test the components boundaries and functionality",
                           icon: { Image(systemName: "bolt") }) {
                    DatePicker(
                        "Välj datum",
                        selection: $selectedDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                }
            }
            .padding(.horizontal, .Margins.medium)
        }
        .background(Color.Elevation.background)
        .maxLeading()
    }
}
