import SwiftUI

public struct VGRSaveButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
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
            .tint(colorScheme == .dark ? .white : Color.Primary.action)
        } else {
            /// Fallback for earlier versions
            Button {
                if let dismissAction {
                    dismissAction()
                } else {
                    dismiss()
                }
            } label: {
                Text("general.save".localizedBundle)
                    .foregroundStyle(isEnabled ? Color.Primary.action : Color.Neutral.disabled)
            }
        }
    }
}

#Preview {
    @Previewable @State var showSheet: Bool = false

    VStack(spacing: 32) {
        HStack {
            Text("This is the done button in a ordinary context")
                .frame(maxWidth: .infinity, alignment: .leading)
            VGRSaveButton {
                print("Dismissing")
                showSheet.toggle()
            }
        }


        HStack {
            Text("This is the done button in a ordinary context (disabled)")
                .frame(maxWidth: .infinity, alignment: .leading)
            VGRSaveButton {
                print("Dismissing")
                showSheet.toggle()
            }
            .disabled(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .sheet(isPresented: $showSheet) {
        NavigationStack {
            Text("Sheet is open, look how nice the donebutton looks in the navigationbar.")
                .padding()
                .navigationTitle("Sheet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        VGRSaveButton {
                            showSheet.toggle()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        VGRSaveButton {
                            showSheet.toggle()
                        }
                        .disabled(true)
                    }
                }
        }
    }
}
