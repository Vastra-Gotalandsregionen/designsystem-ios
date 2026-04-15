import SwiftUI

struct VGRSelectRow<Icon: View>: View {

    var title: String
    var subtitle: String? = nil
    var isSelected: Bool
    let icon: Icon

    public init(title: String,
                subtitle: String? = nil,
                isSelected: Bool,
                @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.icon = icon()
    }

    public init(title: String,
                subtitle: String? = nil,
                isSelected: Bool) where Icon == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.icon = EmptyView()
    }

    var body: some View {
        VGRListRow(title: title,
                   subtitle: subtitle,
                   icon: {
            icon
        }, accessory: {
            if isSelected {
                Image(systemName: "checkmark")
                    .accessibilityHidden(true)
                    .foregroundStyle(Color.Primary.action)
            }
        })
        .contentShape(Rectangle())
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedId: Int = 0

    NavigationStack {
        ScrollView {
            VGRList {
                Button {
                    selectedId = 0
                } label: {
                    VGRSelectRow(title: "Title",
                                 isSelected: selectedId == 0)
                }

                Button {
                    selectedId = 1
                } label: {
                    VGRSelectRow(title: "Title",
                                 subtitle: "Subtitle",
                                 isSelected: selectedId == 1)
                }

                Button {
                    selectedId = 2
                } label: {
                    VGRSelectRow(title: "Title",
                                 subtitle: "Subtitle",
                                 isSelected: selectedId == 2,
                                 icon: { Image(systemName: "bolt") })
                }
            }
            .padding(.horizontal, .Margins.medium)
        }
        .background(Color.Elevation.background)
    }
}
