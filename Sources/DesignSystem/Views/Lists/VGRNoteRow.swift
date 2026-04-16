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
    let note: String

    /// Creates a note row.
    /// - Parameter note: The text to display.
    public init(_ note: String) {
        self.note = note
    }

    public var body: some View {
        HStack {
            Text(note)
                .font(.bodyRegular)
                .foregroundStyle(Color.Neutral.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.Margins.medium)
        }
        .frame(minHeight: minHeight, alignment: .topLeading)
        .overlay {
            RoundedRectangle(cornerRadius: .Radius.mainRadius)
                .strokeBorder(Color.Neutral.borderDisabled, lineWidth: 1)
                .accessibilityHidden(true)
        }
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
                VGRNoteRow("OK")
            }
        }
        .navigationTitle("VGRNoteRow")
    }
}
