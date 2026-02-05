import SwiftUI

/// Generic content element view that displays a configurable callout.
/// When the button is tapped, it triggers the onAction callback and optionally dismisses the current sheet.
/// All content (header, description, button label, image) comes from the VGRContentElement properties.
struct VGRContentActionCalloutView: View {
    let element: VGRContentElement
    let onAction: (() -> Void)?
    var dismissAction: (() -> Void)?

    var body: some View {
        VGRCalloutV2(
            header: element.actionHeader,
            description: element.actionDescription,
            image: Image(element.actionImage),
            imageType: .illustration
        ) {
            VGRButton(
                label: element.actionButtonLabel,
                variant: .secondary
            ) {
                onAction?()
                dismissAction?()
            }
            .accessibilityLabel(element.actionButtonA11yLabel.isEmpty ? element.actionButtonLabel : element.actionButtonA11yLabel)
        }
        .padding(.vertical, VGRSpacing.verticalMedium)
        .padding(.horizontal, VGRSpacing.horizontal)
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Article content here...")
                .padding(.horizontal, 16)

            VGRContentActionCalloutView(
                element: VGRContentElement(
                    type: .actionCallout,
                    actionId: "navigateToAnalysis",
                    actionHeader: "Analys",
                    actionDescription: "I analysen kan du se alla dina skattningar över tid.",
                    actionButtonLabel: "Utforska analysen",
                    actionButtonA11yLabel: "Navigera till Analys",
                    actionImage: "illustration_analysis"
                ),
                onAction: {
                    print("Action triggered")
                },
                dismissAction: {
                    print("Dismiss action called")
                }
            )
        }
    }
    .background(Color.Elevation.background)
}
