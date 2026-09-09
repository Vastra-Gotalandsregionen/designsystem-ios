import SwiftUI

/// Deviate from system colors here: the MS Forms page background is white regardless of system settings.
struct VGRSurveyProgressSpinner: View {
    init() {}
    var body: some View {
        VStack {
            ProgressView {
                Text("survey.loading".loc(in: .module))
                    .font(.bodyRegular)
                    .foregroundStyle(Color.Neutral.text)
                    .padding(.Margins.medium)
            }
            .tint(.Primary.action)
            .controlSize(.extraLarge)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Elevation.background)
    }
}

#Preview("Spinner") {
    VGRSurveyProgressSpinner()
}
