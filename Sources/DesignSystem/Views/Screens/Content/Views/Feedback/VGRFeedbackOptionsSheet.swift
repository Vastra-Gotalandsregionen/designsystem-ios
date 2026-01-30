import SwiftUI

/// A sheet that displays feedback options when the user indicates content was not helpful.
/// Users can select one or more reasons why the content wasn't helpful.
public struct VGRFeedbackOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOptions: Set<VGRFeedbackOption> = []

    private let options: [VGRFeedbackOption]
    private let onSave: (Set<VGRFeedbackOption>) -> Void

    /// Creates a feedback options sheet with specified options.
    /// - Parameters:
    ///   - options: Array of feedback options to display. Defaults to all options.
    ///   - onSave: Closure called when the user taps Save, with the selected options.
    public init(
        options: [VGRFeedbackOption] = VGRFeedbackOption.allCases.map { $0 },
        onSave: @escaping (Set<VGRFeedbackOption>) -> Void
    ) {
        self.options = options
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("feedback.sheet.description".localizedBundle)
                        .font(.subheadline)
                        .foregroundStyle(Color.Neutral.text)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(options.enumerated()), id: \.element) { index, option in
                            optionRow(option)

                            if index < options.count - 1 {
                                VGRDivider()
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.Elevation.elevation1)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VGRButton(
                        label: "feedback.sheet.save".localizedBundle,
                        isEnabled: .constant(!selectedOptions.isEmpty)
                    ) {
                        onSave(selectedOptions)
                        dismiss()
                    }
                }
                .padding(.top, VGRSpacing.verticalSmall)
                .padding(.horizontal, VGRSpacing.horizontal)
                .padding(.bottom, VGRSpacing.verticalMedium)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("feedback.sheet.title".localizedBundle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    VGRCloseButton { dismiss() }
                }
            }
        }
        .background(Color.Elevation.background)
    }

    private func optionRow(_ option: VGRFeedbackOption) -> some View {
        let isSelected = selectedOptions.contains(option)

        return Button {
            if isSelected {
                selectedOptions.remove(option)
            } else {
                selectedOptions.insert(option)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.Primary.action)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)

                Text(option.displayText)
                    .font(.body)
                    .foregroundStyle(Color.Neutral.text)

                Spacer()
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint("feedback.option.a11y.hint".localizedBundle)
    }
}

#Preview {
    VGRFeedbackOptionsSheet { options in
        print("Selected: \(options.map { $0.rawValue })")
    }
}

#Preview("Custom Options") {
    VGRFeedbackOptionsSheet(options: [.notRelevant, .alreadyKnew, .other]) { options in
        print("Selected: \(options.map { $0.rawValue })")
    }
}
