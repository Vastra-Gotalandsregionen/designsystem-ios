import SwiftUI

/// A single-line text input with an optional leading title and bordered field.
///
/// - Usage:
/// ```swift
/// @State private var name: String = ""
///
/// VGRTextInput(title: "Namn", value: $name)
///
/// @State private var age: Int = 0
///
/// VGRTextInput(title: "Ålder", placeholder: "0", value: $age, format: .number)
/// ```
public struct VGRTextInput: View {

    let title: String?
    private let field: AnyView

    /// Creates a `VGRTextInput` bound to a `String`.
    ///
    /// - Parameters:
    ///   - title: Optional label rendered above the field. Pass `nil` for a field without a title.
    ///   - placeholder: Placeholder text shown when the field is empty.
    ///   - value: Binding to the edited text.
    ///   - keyboardType: Keyboard to present when the field is focused. Defaults to `.default`.
    public init(
        title: String? = nil,
        placeholder: String = "",
        value: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.field = AnyView(
            TextField(placeholder, text: value)
                .keyboardType(keyboardType)
        )
    }

    /// Creates a `VGRTextInput` that parses and formats its value using a `ParseableFormatStyle`
    /// (e.g. `.number`, `.currency(code:)`, `.percent`).
    ///
    /// - Parameters:
    ///   - title: Optional label rendered above the field.
    ///   - placeholder: Placeholder text shown when the field is empty.
    ///   - value: Binding to the underlying value being formatted.
    ///   - format: A parseable format style whose `FormatOutput` is `String`.
    ///   - keyboardType: Keyboard to present when the field is focused. Defaults to `.numberPad`
    ///     since format-based inputs are typically numeric.
    public init<F: ParseableFormatStyle>(
        title: String? = nil,
        placeholder: String = "",
        value: Binding<F.FormatInput>,
        format: F,
        keyboardType: UIKeyboardType = .numberPad
    ) where F.FormatOutput == String {
        self.title = title
        self.field = AnyView(
            TextField(placeholder, value: value, format: format)
                .keyboardType(keyboardType)
        )
    }

    /// Creates a `VGRTextInput` that converts between its value and a string using a `Formatter`.
    ///
    /// - Parameters:
    ///   - title: Optional label rendered above the field.
    ///   - placeholder: Placeholder text shown when the field is empty.
    ///   - value: Binding to the underlying value being formatted.
    ///   - formatter: A `Formatter` used to convert between the value and its string representation.
    ///   - keyboardType: Keyboard to present when the field is focused. Defaults to `.default`.
    public init<V>(
        title: String? = nil,
        placeholder: String = "",
        value: Binding<V>,
        formatter: Formatter,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.field = AnyView(
            TextField(placeholder, value: value, formatter: formatter)
                .keyboardType(keyboardType)
        )
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .Margins.xtraSmall) {

            if let title = title {
                Text(title)
                    .font(.headlineSemibold)
                    .foregroundStyle(Color.Neutral.text)
                    .padding(.horizontal, .Margins.medium)
            }

            field
                .autocorrectionDisabled()
                .padding(.Margins.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.Elevation.elevation1)
                .font(.bodyRegular)
                .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
                .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: .Radius.mainRadius)
                        .strokeBorder(Color.Neutral.border, style: StrokeStyle(lineWidth: 1))
                )
        }
    }
}

#Preview {
    @Previewable @State var weight: Double = 0.0
    @Previewable @State var value: String = "Some value"
    @Previewable @State var value2: String = ""
    @Previewable @State var age: Int = 0

    NavigationStack {
        VGRContainer {

            VGRSection {
                VGRTextInput(title: "Textinput with label", placeholder: "Ange värde", value: $value)
            }

            VGRDivider()

            VGRSection {
                VGRTextInput(placeholder: "Ange värde", value: $value2)
            }

            VGRDivider()

            VGRSection {
                VGRTextInput(
                    title: "Ålder",
                    placeholder: "Ange ålder",
                    value: $age,
                    format: .number,
                    keyboardType: .numberPad
                )
            }

            VGRDivider()

            VGRSection {
                VGRTextInput(
                    title: "Vikt",
                    placeholder: "Ange vikt",
                    value: $weight,
                    format: .number.precision(.fractionLength(2)),
                    keyboardType: .decimalPad
                )
            }
        }
        .navigationTitle("VGRTextInput")
        .navigationBarTitleDisplayMode(.inline)
    }
}
