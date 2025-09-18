import SwiftUI

public struct VGRCloseButton: View {
    @Environment(\.dismiss) private var dismiss
    let dismissAction: (() -> Void)?

    public var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .close) {
                if let dismissAction {
                    dismissAction()
                } else {
                    dismiss()
                }
            }
        } else {
            /// Fallback for earlier versions
            Button {
                if let dismissAction {
                    dismissAction()
                } else {
                    dismiss()
                }
            } label: {
                Text("general.close".localizedBundle)
                    .foregroundStyle(Color.Primary.action)
            }
        }
    }
}

#Preview {
    @Previewable @State var showSheet: Bool = false

    VStack(spacing: 32) {
        Text("This is the close button in a ordinary context")
        VGRCloseButton {
            print("Dismissing")
            showSheet.toggle()
        }
    }
    .padding()
    .sheet(isPresented: $showSheet) {
        NavigationStack {
            Text("Sheet is open, look how nice the closebutton looks in the navigationbar.")
                .padding()
                .navigationTitle("Sheet")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        VGRCloseButton {
                            showSheet.toggle()
                        }
                    }
                }
        }
    }
}
