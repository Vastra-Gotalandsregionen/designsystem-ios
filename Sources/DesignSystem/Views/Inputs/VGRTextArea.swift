import SwiftUI

/// A multi-line text input with an optional leading title and bordered editor.
///
/// - Usage:
/// ```swift
/// @State private var notes: String = ""
///
/// VGRTextArea(title: "Anteckningar", value: $notes)
/// ```
public struct VGRTextArea: View {

    @ScaledMetric private var minHeight: CGFloat = 172

    let title: String?
    @Binding var value: String

    /// Creates a `VGRTextArea`.
    ///
    /// - Parameters:
    ///   - title: Optional label rendered above the editor. Pass `nil` for an editor without a title.
    ///   - value: Binding to the edited text.
    public init(title: String? = nil, value: Binding<String>) {
        self.title = title
        self._value = value
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .Margins.xtraSmall) {

            if let title = title {
                Text(title)
                    .font(.headlineSemibold)
                    .foregroundStyle(Color.Neutral.text)
                    .padding(.horizontal, .Margins.medium)
            }

            TextEditor(text: $value)
                .contentMargins(.Margins.xtraSmall)
                .autocorrectionDisabled()
                .frame(minHeight: minHeight, maxHeight: .infinity)
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
    @Previewable @State var value: String = "Some value"
    @Previewable @State var value2: String = ""

    NavigationStack {
        ScrollView {
            VStack(spacing: 0) {
                VGRTextArea(title: "Textarea with label", value: $value)
                    .padding()

                VGRDivider()

                VGRTextArea(value: $value2)
                    .padding()
            }
        }
        .navigationTitle("VGRTextArea")
        .navigationBarTitleDisplayMode(.inline)
    }
}
