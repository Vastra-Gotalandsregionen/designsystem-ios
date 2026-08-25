import SwiftUI

/// En  divider som matchar VGR-designsystemets färg för avgränsningar.
///
/// Används för att visuellt separera rader i listor eller tabeller.
///
/// Exempel:
/// ```swift
/// VGRDivider()
/// ```
public struct VGRDivider: View {

    public init() {}

    public var body: some View {
        Divider()
            .background(Color.Neutral.divider)
            .accessibilityHidden(true)
    }
}

#Preview {
    NavigationStack {
        VGRContainer {

            VGRSection {

                /// VGRList skjuter in VGRDivider mellan varje element
                VGRList {

                    VGRNavRow(title: "Anfallshantering",
                              icon: { Image(systemName: "gearshape") }) { EmptyView() }

                    VGRNavRow(title: "Användarvillkor") { EmptyView() }

                    VGRNavRow(title: "Ge oss Feedback") { EmptyView() }

                    VGRNavRow(title: "Personuppgiftspolicy") { EmptyView() }

                    VGRNavRow(title: "Tillgänglighetsredogörelse") { Text("Karl Anka") }

                    VGRNavRow(title: "Tillgänglighetsredogörelse",
                              subtitle: "Hej",
                              accessory: { Text("Test") }) { EmptyView() }
                }
            }
        }
    }
}
