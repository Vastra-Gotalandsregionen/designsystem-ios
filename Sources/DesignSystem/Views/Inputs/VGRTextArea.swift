import SwiftUI

/// A multi-line text input with an optional leading title and bordered editor.
///
/// - Usage:
/// ```swift
/// @State private var notes: String = ""
///
/// VGRTextArea(title: "Anteckningar", placeholder: "Skriv här…", value: $notes)
/// ```
public struct VGRTextArea: View {

    @ScaledMetric private var minHeight: CGFloat = 172

    /// Matches where `TextEditor` draws its first line: the content margin plus UITextView's default insets.
    private static let placeholderInsets = EdgeInsets(
        top: .Margins.xtraSmall + 8,
        leading: .Margins.xtraSmall + 5,
        bottom: .Margins.xtraSmall + 8,
        trailing: .Margins.xtraSmall + 5
    )

    let title: String?
    let placeholder: String?
    let accessibilityLabel: String?
    @Binding var value: String

    /// Creates a `VGRTextArea`.
    ///
    /// - Parameters:
    ///   - title: Optional label rendered above the editor. Pass `nil` for an editor without a title.
    ///   - placeholder: Optional text shown inside the editor while it is empty. VoiceOver reads it as a hint.
    ///   - value: Binding to the edited text.
    ///   - accessibilityLabel: Overrides the accessibility label on the text editor. Defaults to `title` when not provided.
    public init(
        title: String? = nil,
        placeholder: String? = nil,
        value: Binding<String>,
        accessibilityLabel: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.accessibilityLabel = accessibilityLabel ?? title
        self._value = value
    }

    @available(*, deprecated, message: "Use init(title:value:accessibilityLabel:) instead.")
    public init(title: String? = nil, accessibilityLabel: String, value: Binding<String>) {
        self.init(title: title, value: value, accessibilityLabel: accessibilityLabel)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .Margins.xtraSmall) {

            if let title = title {
                Text(title)
                    .font(.headlineSemibold)
                    .foregroundStyle(Color.Neutral.text)
                    .padding(.horizontal, .Margins.medium)
                    .accessibilityHidden(true)
            }

            if let accessibilityLabel {
                styledEditor
                    .accessibilityLabel(accessibilityLabel)
            } else {
                styledEditor
            }
        }
    }

    private var styledEditor: some View {
        TextEditor(text: $value)
            .contentMargins(.Margins.xtraSmall)
            .autocorrectionDisabled()
            .dismissesKeyboardOnEscape()
            .frame(minHeight: minHeight, maxHeight: .infinity)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.Elevation.elevation1)
            .font(.bodyRegular)
            .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .contentShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
            .overlay(alignment: .topLeading) {
                if let placeholder, value.isEmpty {
                    Text(placeholder)
                        .font(.bodyRegular)
                        .foregroundStyle(Color.Neutral.textVariant)
                        .padding(Self.placeholderInsets)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: .Radius.mainRadius)
                    .strokeBorder(Color.Neutral.border, style: StrokeStyle(lineWidth: 1))
            )
            .accessibilityHint(value.isEmpty ? placeholder ?? "" : "")
    }
}

#Preview {
    @Previewable @State var value: String = "Some value"
    @Previewable @State var value2: String = ""
    @Previewable @State var value3: String = ""

    NavigationStack {
        ScrollView {
            VStack(spacing: 0) {
                VGRTextArea(title: "Textarea with label", value: $value)
                    .padding()

                VGRDivider()

                VGRTextArea(value: $value2)
                    .padding()

                VGRDivider()

                VGRTextArea(title: "Textarea with placeholder", placeholder: "Skriv din anteckning här…", value: $value3)
                    .padding()
            }
        }
        .navigationTitle("VGRTextArea")
        .navigationBarTitleDisplayMode(.inline)
    }
}
