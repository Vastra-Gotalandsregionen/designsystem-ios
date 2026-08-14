import SwiftUI

/// En  divider som matchar VGR-designsystemets färg för avgränsningar.
///
/// Används för att visuellt separera rader i listor eller tabeller.
///
/// Exempel:
/// ```swift
/// VGRTableRowDivider()
/// ```
@available(*, deprecated, renamed: "VGRDivider")
public struct VGRTableRowDivider: View {
    
    public init() {}

    public var body: some View {
        Divider()
            .background(Color.Neutral.divider)
    }
}

//MARK: This component is deprecated - Preview is commented out to reduce number of unescessary Xcode-warnings in the project.

//#Preview {
//    return NavigationStack {
//        ScrollView {
//            VStack (alignment: .leading) {
//                
//                VGRNavRow(title: "Anfallshantering",
//                          icon: { Image(systemName: "gearshape") }) { EmptyView() }
//
//                VGRNavRow(title: "Användarvillkor") { EmptyView() }
//
//                VGRDivider()
//
//                VGRNavRow(title: "Ge oss Feedback") { EmptyView() }
//
//                VGRDivider()
//
//                VGRNavRow(title: "Personuppgiftspolicy") { EmptyView() }
//
//                VGRDivider()
//
//                VGRNavRow(title: "Tillgänglighetsredogörelse") { EmptyView() }
//
//                VGRDivider()
//
//                VGRNavRow(title: "Tillgänglighetsredogörelse",
//                          subtitle: "Hej",
//                          accessory: { Text("Test") }) { EmptyView() }
//            }
//        }
//    }
//}
