import SwiftUI

/// A single-line text input with an optional leading title and a bordered,
/// rounded field. Comes in three flavours selected by initializer:
///
/// - Plain `String` binding for free-form text.
/// - `ParseableFormatStyle` binding (e.g. `.number`, `.currency(code:)`) for
///   typed values that round-trip through a format.
/// - `Formatter` binding for legacy `Formatter`-based conversion.
///
/// Pass `showWarning: true` to render a warning-coloured border around the
/// field — useful for surfacing validation errors without replacing the
/// field's own chrome. The title, when provided, is rendered above the
/// field; omit it for an un-labelled input.
///
/// ### Usage
/// ```swift
/// @State private var name: String = ""
/// VGRTextInput(title: "Namn", value: $name)
///
/// @State private var age: Int = 0
/// VGRTextInput(title: "Ålder", placeholder: "0", value: $age, format: .number)
///
/// @State private var amount: Decimal = 0
/// VGRTextInput(
///     title: "Belopp",
///     value: $amount,
///     formatter: NumberFormatter()
/// )
/// ```
public struct VGRTextInput: View {

    /// Optional label rendered above the field. `nil` hides the label row.
    let title: String?

    /// When `true`, the field's border is replaced with the warning style.
    /// Drive this from validation state.
    let showWarning: Bool

    private let field: AnyView


    /// Creates a `VGRTextInput` bound to a `String`.
    ///
    /// - Parameters:
    ///   - title: Optional label rendered above the field. Pass `nil` for a field without a title.
    ///   - placeholder: Placeholder text shown when the field is empty.
    ///   - value: Binding to the edited text.
    ///   - showWarning: When `true`, the field is drawn with a warning-coloured
    ///     border. Defaults to `false`.
    ///   - keyboardType: Keyboard to present when the field is focused. Defaults to `.default`.
    public init(
        title: String? = nil,
        placeholder: String = "",
        value: Binding<String>,
        showWarning: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.showWarning = showWarning
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
    ///   - showWarning: When `true`, the field is drawn with a warning-coloured
    ///     border. Defaults to `false`.
    ///   - format: A parseable format style whose `FormatOutput` is `String`.
    ///   - keyboardType: Keyboard to present when the field is focused. Defaults to `.numberPad`
    ///     since format-based inputs are typically numeric.
    public init<F: ParseableFormatStyle>(
        title: String? = nil,
        placeholder: String = "",
        value: Binding<F.FormatInput>,
        showWarning: Bool = false,
        format: F,
        keyboardType: UIKeyboardType = .numberPad
    ) where F.FormatOutput == String {
        self.title = title
        self.showWarning = showWarning
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
    ///   - showWarning: When `true`, the field is drawn with a warning-coloured
    ///     border. Defaults to `false`.
    ///   - formatter: A `Formatter` used to convert between the value and its string representation.
    ///   - keyboardType: Keyboard to present when the field is focused. Defaults to `.default`.
    public init<V>(
        title: String? = nil,
        placeholder: String = "",
        value: Binding<V>,
        showWarning: Bool = false,
        formatter: Formatter,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.showWarning = showWarning
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
                .roundedBorder(!showWarning, borderColor: Color.Neutral.border, lineWidth: 1)
                .warningBorder(showWarning)
        }
    }
}

#Preview {
    @Previewable @State var showWarning: Bool = false
    @Previewable @State var weight: Double = 0.0
    @Previewable @State var value: String = "Some value"
    @Previewable @State var value2: String = ""
    @Previewable @State var age: Int = 0

    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRList {
                    VGRToggleRow(title: "Visa varning", isOn: $showWarning)
                }
            }

            VGRSection {
                VGRTextInput(title: "Textinput with label",
                             placeholder: "Ange värde",
                             value: $value,
                             showWarning: showWarning)
            }

            VGRDivider()

            VGRSection {
                VGRTextInput(placeholder: "Ange värde",
                             value: $value2,
                             showWarning: showWarning)
            }

            VGRDivider()

            VGRSection {
                VGRTextInput(
                    title: "Ålder",
                    placeholder: "Ange ålder",
                    value: $age,
                    showWarning: showWarning,
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
                    showWarning: showWarning,
                    format: .number.precision(.fractionLength(2)),
                    keyboardType: .decimalPad
                )
            }
        }
        .navigationTitle("VGRTextInput")
        .navigationBarTitleDisplayMode(.inline)
    }
}
