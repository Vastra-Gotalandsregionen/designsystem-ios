import SwiftUI

/// Deviate from system colors here: the MS Forms page background is white regardless of system settings.
public struct VGRSurveyProgressSpinner: View {
    public init() {}
    public var body: some View {
        ProgressView {
            Text(LocalizedStringKey("survey.loading"), bundle: .module)
                .foregroundStyle(Color.black)
        }
        .tint(.black)
        .controlSize(.large)
    }
}

#Preview("Spinner") {
    VGRSurveyProgressSpinner()
        .padding()
        .background(Color.white)
}
