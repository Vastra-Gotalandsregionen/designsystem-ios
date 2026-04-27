import SwiftUI

#Preview {

    @Previewable @State var alert: VGRAlert? = nil

    ScrollView {
        VGRShape(backgroundColor: Color.Elevation.background) {
            VStack(spacing: 16) {

                /// Common: unsavedChanges with default text
                VGRButton(label: "Unsaved Changes") {
                    alert = .unsavedChanges {
                        print("Discarded changes")
                    }
                }
                .maxLeading()

                /// Common: unsavedChanges with custom text
                VGRButton(label: "Unsaved Changes (custom text)") {
                    alert = .unsavedChanges(
                        title: "Du har osparade ändringar",
                        message: "Vill du verkligen lämna sidan?"
                    ) {
                        print("Discarded changes")
                    }
                }

                /// Common: confirmDelete
                VGRButton(label: "Confirm Delete") {
                    alert = .confirmDelete(name: "Ibuprofen") {
                        print("Deleted Ibuprofen")
                    }
                }

                /// Common: error
                VGRButton(label: "Error") {
                    let error = NSError(domain: "", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Kunde inte ansluta till servern."
                    ])
                    alert = .error(error)
                }

                /// Custom: inline alert
                VGRButton(label: "Custom Alert") {
                    alert = VGRAlert(
                        title: "Ändra schema?",
                        message: "Detta påverkar alla doser.",
                        buttons: [
                            .confirm("Ändra") { print("Changed schema") },
                            .destructive("Destructive 2") { print("Destructive 2") },
                            .default("Koka soppa") { print("Did something else") },
                            .cancel()
                        ]
                    )
                }

                /// Custom: inline alert
                VGRButton(label: "Confirm Alert") {
                    alert = VGRAlert(
                        title: "Bekräfta",
                        message: "Vill du verkligen göra detta?.",
                        buttons: [
                            .confirm("Ja, fortsätt") { print("Did something else") },
                            .cancel()
                        ]
                    )
                }

                /// Custom: inline alert
                VGRButton(label: "Close Alert") {
                    alert = VGRAlert(
                        title: "Stäng",
                        message: "Vill du verkligen göra detta?.",
                        buttons: [
                            .destructive("Ja, stäng", isPreferred: true) {
                                print("Did something else")
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .padding(.top, 32)
        }
    }
    .vgrAlert(item: $alert)
}
