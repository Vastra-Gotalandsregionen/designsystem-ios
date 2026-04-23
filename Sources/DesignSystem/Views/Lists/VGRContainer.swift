import SwiftUI

/// A scrollable screen-level container for stacking ``VGRSection`` views.
///
/// Owns the `ScrollView`, the design system background, and the vertical
/// rhythm (`.Margins.medium`) between sections. Sections control their own
/// horizontal inset, so `VGRContainer` intentionally does not apply any
/// horizontal padding.
///
/// ### Usage
/// ```swift
/// VGRContainer {
///     VGRSection(header: "Today") {
///         VGRList {
///             VGRListRow(title: "Morning")
///             VGRListRow(title: "Evening")
///         }
///     }
///     VGRSection(header: "Stats", inset: false) {
///         ChartView()
///     }
/// }
/// ```
public struct VGRContainer<Content: View>: View {

    private let content: Content

    /// Creates a container that stacks its children vertically in a `ScrollView`.
    /// - Parameter content: A view builder that produces the stacked children,
    ///   typically ``VGRSection`` views.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: .Margins.xtraLarge) {
                content
            }
        }
        .maxLeading()
        .background(Color.Elevation.background)
    }
}

#Preview {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "Today") {
                VGRList {
                    VGRListRow(title: "Morning", subtitle: "08:00")
                    VGRListRow(title: "Evening", subtitle: "20:00")
                }
            }

            VGRSection(header: "This week",
                       footer: "Times are shown in your current time zone.") {
                VGRList {
                    VGRListRow(title: "Monday")
                    VGRListRow(title: "Wednesday")
                    VGRListRow(title: "Friday")
                }
            }

            VGRSection {
                VGRList(showWarning: true) {
                    VGRListRow(title: "Headerless section")
                }
            }
        }
        .navigationTitle("VGRContainer")
        .navigationBarTitleDisplayMode(.inline)
    }
}
