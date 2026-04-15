import SwiftUI

struct VGRCheckRow<Accessory: View>: View {

    var title: String
    var subtitle: String? = nil
    var isSelected: Bool
    let accessory: Accessory

    public init(title: String,
                subtitle: String? = nil,
                isSelected: Bool,
                @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.accessory = accessory()
    }

    public init(title: String,
                subtitle: String? = nil,
                isSelected: Bool) where Accessory == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.accessory = EmptyView()
    }

    var body: some View {
        VGRListRow(title: title,
                   subtitle: subtitle,
                   icon: {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .accessibilityHidden(true)
                .foregroundStyle(Color.Primary.action)
        }, accessory: {
            accessory
        })
        .transaction { $0.animation = nil }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var firstButton: Bool = false
    @Previewable @State var secondButton: Bool = true
    @Previewable @State var thirdButton: Bool = false

    NavigationStack {
        ScrollView {
            VGRList {
                Button {
                    firstButton.toggle()
                } label: {
                    VGRCheckRow(title: "Title", isSelected: firstButton)
                }

                Button {
                    secondButton.toggle()
                } label: {
                    VGRCheckRow(title: "Title",
                                subtitle: "Subtitle",
                                isSelected: secondButton)
                }

                Button {
                    thirdButton.toggle()
                } label: {
                    VGRCheckRow(title: "Title",
                                subtitle: "Subtitle",
                                isSelected: thirdButton) {
                        HStack {
                            Text("Detail")

                            Image(systemName: "star.fill")
                        }
                        .foregroundStyle(.purple)
                    }
                }
            }
            .padding(.horizontal, .Margins.medium)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRCheckRow")
    }
}
