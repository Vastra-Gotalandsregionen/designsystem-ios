import SwiftUI

/// Toolbar button labelled "Ändra" (Edit) for entering edit mode.
/// SwiftUI has no `.edit` `ButtonRole`, so this renders a plain text button
/// in `Color.Primary.action` rather than a system-provided role glyph.
public struct VGREditButton: View {
    @Environment(\.isEnabled) private var isEnabled
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            Text("general.edit".localizedBundle)
                .foregroundStyle(isEnabled ? Color.Primary.action : Color.Neutral.disabled)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    @Previewable @State var showSheet: Bool = false

    VStack(spacing: 32) {
        Text("This is the edit button in a ordinary context")
        VGREditButton {
            print("Editing")
            showSheet.toggle()
        }

        Text("Disabled state")
        VGREditButton {
            print("Editing")
            showSheet.toggle()
        }
        .disabled(true)
    }
    .padding()
    .sheet(isPresented: $showSheet) {
        NavigationStack {
            Text("Sheet is open, look how nice the editbutton looks in the navigationbar.")
                .padding()
                .navigationTitle("Sheet")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        VGREditButton {
                            showSheet.toggle()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        VGREditButton {
                            showSheet.toggle()
                        }
                        .disabled(true)
                    }
                }
        }
    }
}
