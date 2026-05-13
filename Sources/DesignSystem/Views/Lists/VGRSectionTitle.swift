import SwiftUI

/// A heading view intended for the `header` slot of a ``VGRSection``.
///
/// Renders a title with an optional supporting description, plus an optional
/// trailing accessory slot for actions such as buttons. The size of the
/// heading and the spacing between title and description are controlled by
/// ``Variant``.
///
/// ```swift
/// VGRSection {
///     VGRList { ... }
/// } header: {
///     VGRSectionTitle("Settings", description: "Manage your preferences")
/// }
/// ```
///
/// To add a trailing action, use the accessory view builder:
///
/// ```swift
/// VGRSectionTitle("Settings", description: "Manage your preferences") {
///     VGRButtonV2("Edit", variant: .tonal, fullWidth: false) { … }
///         .maxTrailing()
/// }
/// ```
public struct VGRSectionTitle<Accessory: View>: View {

    /// Visual size variants for ``VGRSectionTitle``.
    ///
    /// Each case bundles a title font, a description font, and the spacing
    /// between the two text rows.
    public enum Variant {
        /// Compact heading for tightly packed sections.
        case small
        /// Standard size used for most sections.
        case `default`
        /// Extra breathing room between title and description.
        case spacey

        var titleFont: Font {
            switch self {
                case .small: .headlineSemibold
                case .default: .title3Semibold
                case .spacey: .title3Semibold
            }
        }

        var descriptionFont: Font {
            switch self {
                case .small: .subheadline
                case .default: .subheadline
                case .spacey: .subheadline
            }
        }

        var spacing: CGFloat {
            switch self {
                case .small: 0
                case .default: 0
                case .spacey: .Margins.small
            }
        }
    }

    let title: String
    let description: String
    let variant: Variant
    let accessory: Accessory

    /// Creates a section title with a trailing accessory view.
    ///
    /// Use the no-accessory convenience initializer when you don't need a
    /// trailing view — it omits the builder entirely.
    ///
    /// - Parameters:
    ///   - title: The section heading text.
    ///   - description: Supporting text rendered below the title. Hidden when empty.
    ///   - variant: The size variant. Defaults to ``Variant/default``.
    ///   - accessory: A trailing view rendered alongside the heading. Typically
    ///     a small button or icon.
    public init(_ title: String,
                description: String = "",
                variant: Variant = .default,
                @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.description = description
        self.variant = variant
        self.accessory = accessory()
    }


    public var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: variant.spacing) {
                Text(title)
                    .font(variant.titleFont)

                if !description.isEmpty {
                    Text(description)
                        .font(variant.descriptionFont)
                }
            }

            accessory
        }
        .maxLeading()
        .foregroundStyle(Color.Neutral.text)
        .padding(.horizontal, .Margins.medium)
    }
}

extension VGRSectionTitle where Accessory == EmptyView {
    /// Creates a section title without a trailing accessory.
    public init(_ title: String, description: String = "", variant: Variant = .default) {
        self.init(title, description: description, variant: variant, accessory: { EmptyView() })
    }
}

#Preview {
    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRList {
                    VGRLabelRow("Label", value: "Value")
                    VGRLabelRow("Label", value: "Value")
                }
            } header: {
                VGRSectionTitle("Small variant", description: "Alfa beta gamma delta", variant: .small)
            }

            VGRSection {
                VGRList {
                    VGRLabelRow("Label", value: "Value")
                    VGRLabelRow("Label", value: "Value")
                }
            } header: {
                VGRSectionTitle("Default variant", description: "Alfa beta gamma delta")
            }

            VGRSection {
                VGRList {
                    VGRLabelRow("Label", value: "Value")
                    VGRLabelRow("Label", value: "Value")
                }
            } header: {
                VGRSectionTitle("Spacey variant", description: "Alfa beta gamma delta", variant: .spacey)
            }

            VGRSection {
                VGRList {
                    VGRLabelRow("Label", value: "Value")
                }
            } header: {
                VGRSectionTitle("A considerably longer title that should wrap onto several lines so we can see how the section header handles overflowing headline text",
                                description: "Short description")
            }

            VGRSection {
                VGRList {
                    VGRLabelRow("Label", value: "Value")
                }
            } header: {
                VGRSectionTitle("Short title",
                                description: "A considerably longer description that should wrap onto several lines so we can see how the section header handles overflowing supporting text without breaking the layout of the rest of the section")
            }

            VGRSection {
                VGRList {
                    VGRLabelRow("Label", value: "Value")
                }
            } header: {
                VGRSectionTitle("With accessory", description: "Alfa beta gamma delta") {
                    VGRButtonV2("Knapp",
                                variant: .tonal,
                                fullWidth: false,
                                systemImage: "gearshape") { print("action") }
                        .maxTrailing()
                }
            }
        }
        .navigationTitle("VGRSectionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
