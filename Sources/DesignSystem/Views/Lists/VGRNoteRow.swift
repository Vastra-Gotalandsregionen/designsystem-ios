import SwiftUI

/// A row that displays a multi-line note inside a rounded, bordered
/// frame. Stands apart from the other rows in this folder because it
/// renders its own chrome rather than composing over ``VGRListRow``.
///
/// A minimum height keeps short notes reading as a text block instead
/// of collapsing to a single line; the row grows vertically to fit
/// longer content. Intended for read-only display of free-form text —
/// patient notes, comments, descriptive paragraphs — typically placed
/// directly inside a ``VGRSection`` rather than nested in a ``VGRList``
/// (the inner border would clash with the list's outer card).
///
/// ### Usage
/// ```swift
/// VGRContainer {
///     VGRSection(header: "Anteckning") {
///         VGRNoteRow("Tidigare händelser hanterades i samråd med vårdgivaren.")
///     }
/// }
/// ```
public struct VGRNoteRow: View {

    /// Minimum height of the note field so short notes still read as a
    /// text block instead of collapsing to a single line.
    @ScaledMetric private var minHeight: CGFloat = 172

    /// The note text displayed in the row.
    var note: String?

    /// The placeholder to show if the note is empty
    let placeholder: String

    /// Creates a note row.
    /// - Parameter note: The text to display.
    /// - Parameter placeholder: The placeholder text to display if `note` is empty
    public init(_ note: String?, placeholder: String = "") {
        self.note = note
        self.placeholder = placeholder
    }

    /// Computed property, to support placeholder / empty state
    private var noteText: String {
        guard let text = self.note else { return self.placeholder }
        return text.isEmpty ? self.placeholder : text
    }

    public var body: some View {
        HStack {
            Text(noteText)
                .font(.bodyRegular)
                .foregroundStyle(Color.Neutral.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.Margins.medium)
        }
        .frame(minHeight: minHeight, alignment: .topLeading)
        .roundedBorder(borderColor: Color.Neutral.borderDisabled, lineWidth: 1)
    }
}

#Preview {
    NavigationStack {
        VGRContainer {
            VGRSection(header: "Anteckning") {
                VGRNoteRow("Tidigare händelser hanterades i samråd med vårdgivaren och dokumenterades i journalen. Flera uppföljningar har genomförts under det senaste kvartalet och inga nya avvikelser har rapporterats.\n\nTidigare händelser hanterades i samråd med vårdgivaren och dokumenterades i journalen. Flera uppföljningar har genomförts under det senaste kvartalet och inga nya avvikelser har rapporterats.\n\nTidigare händelser hanterades i samråd med vårdgivaren och dokumenterades i journalen. Flera uppföljningar har genomförts under det senaste kvartalet och inga nya avvikelser har rapporterats.")
            }

            VGRSection(header: "Kort anteckning",
                       footer: "Minsta höjden håller uppe raden även när noten är kort.") {
                VGRNoteRow("", placeholder: "Ingen anteckning")
            }

            VGRSection(header: "Kort anteckning",
                       footer: "Detta är en footer") {
                VGRNoteRow(nil, placeholder: "Även ett 'nil' värde accepteras för att trigga placeholdern")
            }
        }
        .navigationTitle("VGRNoteRow")
    }
}
