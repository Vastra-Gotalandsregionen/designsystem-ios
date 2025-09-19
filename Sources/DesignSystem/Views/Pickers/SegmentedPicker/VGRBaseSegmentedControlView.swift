import SwiftUI

/// VGRBaseSegmentedControlView is a base component that can be used to build
/// a variety of different pickers. It should not be used as-is, instead implement pickers using it.
/// Have a look at the Preview to see whats possible.
struct VGRBaseSegmentedControlView<Data, Content>: View where Data: Hashable, Content: View {

    let items: [Data]
    let nonScrollableItemCount: Int
    let insets: EdgeInsets

    @Binding var selectedItem: Data?

    private let itemBuilder: (Data, _ isSelected: Bool) -> Content

    public init(_ items: [Data],
                nonScrollableItemCount: Int = 4,
                insets: EdgeInsets = EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6),
                selectedItem: Binding<Data?>,
                @ViewBuilder itemBuilder: @escaping (Data, _ isSelected: Bool) -> Content) {
        self.items = items
        self.nonScrollableItemCount = nonScrollableItemCount
        self.insets = insets
        self.itemBuilder = itemBuilder
        self._selectedItem = selectedItem
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if items.count <= nonScrollableItemCount {

                ForEach(items, id: \.self) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        itemBuilder(item, selectedItem == item)
                    }
                    .padding(insets)
                    .id(item)
                    .accessibilityIdentifier("\(item)")
                }
                .frame(maxWidth: .infinity)

            } else {

                ScrollViewReader { reader in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 0) {
                            ForEach(items, id: \.self) { item in
                                Button {
                                    selectedItem = item
                                } label: {
                                    itemBuilder(item, selectedItem == item)
                                }
                                .padding(insets)
                                .id(item)
                                .accessibilityIdentifier("\(item)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .onChange(of: selectedItem) {
                        if let selectedItem {
                            reader.scrollTo(selectedItem)
                        }
                    }
                    .onAppear {
                        if let selectedItem {
                            reader.scrollTo(selectedItem, anchor: .center)
                        }
                    }
                }
            }
        }
        .onAppear {
            if let v = self.selectedItem  {
                /// If the selectedItem is not a valid selection, default to first item
                if !items.contains(v) {
                    selectedItem = items.first
                }
            } else {
                /// SelectedItem is not set, default to first item
                selectedItem = items.first
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @State var selectedItem: String? = "Two"
    let items: [String] = ["One", "Two", "Three", "Four", "Five"]

    /// Just an example to demonstrate the VGRBaseSegmentedControlView.
    /// Think I went a bit overboard with this one.
    NavigationStack {
        ScrollView {
            LazyVStack(pinnedViews: [.sectionHeaders, .sectionFooters]) {
                Section {
                    ForEach(0..<20) { i in
                        Text("Row \(i)")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                    }
                } header: {
                    VGRBaseSegmentedControlView(items,
                                                insets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                                                selectedItem: $selectedItem) { item, selected in
                        Text(item)
                            .font(.body).fontWeight(.bold)
                            .frame(idealWidth: 100)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(selected ? Color.blue : Color.gray)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(selected ? .blue : .clear),
                                alignment: .bottom
                            )
                            .background {
                                Rectangle()
                                    .foregroundStyle(selected ? AnyShapeStyle(LinearGradient(colors: [.clear, .blue.opacity(0.1)], startPoint: .top, endPoint: .bottom)) : AnyShapeStyle(Color.clear))
                            }
                    }
                    .background(
                       Rectangle().frame(height: 2).foregroundColor(.gray.opacity(0.3)), alignment: .bottom)
                    .background(Color.Elevation.background)
                } footer: {

                    VStack(spacing: 0) {
                        VGRBaseSegmentedControlView(items,
                                                    insets: EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0),
                                                    selectedItem: $selectedItem) { item, selected in
                            Label {
                                Text(item)
                                    .font(.footnote)
                            } icon: {
                                if selected {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.white)
                                }
                            }
                            .frame(idealWidth: 100)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .foregroundStyle(Color.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(selected ? Color.white : Color.white.opacity(0.2), lineWidth: 2)
                            }
                        }
                        .padding(.vertical, 32)
                        .background(Color.blue)

                        Text("\(selectedItem ?? "No selection")")
                            .font(.body).fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .foregroundColor(.white)
                            .background(Color.blue)
                    }
                }
            }
            .background(Color.Elevation.background)
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.Elevation.background)
        .navigationTitle("Example")
    }
}
