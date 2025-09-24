import SwiftUI

public struct VGRCancelButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isEnabled) private var isEnabled
    let dismissAction: (() -> Void)?

    public init(dismissAction: (() -> Void)? = nil) {
        self.dismissAction = dismissAction
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .cancel) {
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
                Text("general.cancel".localizedBundle)
                    .foregroundStyle(isEnabled ? Color.Primary.action : Color.Neutral.disabled)
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.5)
        }
    }
}

#Preview {
    @Previewable @State var showSheet: Bool = false

    VStack(spacing: 32) {
        Text("This is the close button in a ordinary context")
        VGRCancelButton {
            print("Dismissing")
            showSheet.toggle()
        }

        Text("Disabled state")
        VGRCancelButton {
            print("Dismissing")
            showSheet.toggle()
        }
        .disabled(true)
    }
    .padding()
    .sheet(isPresented: $showSheet) {
        NavigationStack {
            Text("Sheet is open, look how nice the closebutton looks in the navigationbar.")
                .padding()
                .navigationTitle("Sheet")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        VGRCancelButton {
                            showSheet.toggle()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        VGRCancelButton {
                            showSheet.toggle()
                        }
                        .disabled(true)
                    }
                }
        }
    }
}
