import SwiftUI

public struct VGRDoneButton: View {
    @Environment(\.dismiss) private var dismiss
    let dismissAction: (() -> Void)?

    public init(dismissAction: (() -> Void)? = nil) {
        self.dismissAction = dismissAction
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .confirm) {
                if let dismissAction {
                    dismissAction()
                } else {
                    dismiss()
                }
            }
            .tint(Color.Primary.action)
        } else {
            /// Fallback for earlier versions
            Button {
                if let dismissAction {
                    dismissAction()
                } else {
                    dismiss()
                }
            } label: {
                Text("general.done".localizedBundle)
                    .foregroundStyle(Color.Primary.action)
            }
        }
    }
}

#Preview {
    @Previewable @State var showSheet: Bool = false

    VStack(spacing: 32) {
        Text("This is the done button in a ordinary context")
        VGRDoneButton {
            print("Dismissing")
            showSheet.toggle()
        }
    }
    .padding()
    .sheet(isPresented: $showSheet) {
        NavigationStack {
            Text("Sheet is open, look how nice the donebutton looks in the navigationbar.")
                .padding()
                .navigationTitle("Sheet alltså")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        VGRDoneButton {
                            showSheet.toggle()
                        }
                    }
                }
        }
    }
}
