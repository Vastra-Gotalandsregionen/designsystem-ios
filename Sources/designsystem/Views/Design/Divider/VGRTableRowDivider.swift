import SwiftUI

/// En  divider som matchar VGR-designsystemets färg för avgränsningar.
///
/// Används för att visuellt separera rader i listor eller tabeller.
///
/// Exempel:
/// ```swift
/// VGRTableRowDivider()
/// ```
public struct VGRTableRowDivider: View {
    
    public init() {}

    public var body: some View {
        Divider()
            .background(Color.Neutral.divider)
    }
}
#Preview {
    return NavigationStack {
        ScrollView {
            VStack (alignment: .leading) {
                
                VGRTableRowNavigationLink(destination: EmptyView(), title: "Anfallshantering", iconName: "settings_attack")
                
                VGRTableRowNavigationLink(destination: EmptyView(), title: "Användarvillkor")
                
                VGRTableRowDivider()
                
                VGRTableRowNavigationLink(destination: EmptyView(), title: "Ge oss Feedback")
                
                VGRTableRowDivider()

                VGRTableRowNavigationLink(destination: EmptyView(), title: "Personuppgiftspolicy")
                
                VGRTableRowDivider()

                VGRTableRowNavigationLink(destination: EmptyView(), title: "Tillgänglighetsredogörelse")
                
                VGRTableRowDivider()
                
                VGRTableRowNavigationLink(destination: EmptyView(), title: "Tillgänglighetsredogörelse", subtitle: "Hej", details: "Test")
            }
        }
    }
}
