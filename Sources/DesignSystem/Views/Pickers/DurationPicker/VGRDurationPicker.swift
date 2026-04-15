import SwiftUI

/// A duration spinner for selecting a length of time in minutes and seconds.
///
/// Thin wrapper around `VGRMultiPickerView` preconfigured with two
/// 0–59 columns and trailing label columns (e.g. "minuter", "sekunder").
/// The component renders only the wheels; any surrounding chrome — row label,
/// summary text, expand/collapse, padding — belongs in the consuming view.
///
/// - Usage:
/// ```swift
/// @State private var minutes: Int = 0
/// @State private var seconds: Int = 0
///
/// VGRDurationPicker(minutes: $minutes, seconds: $seconds)
/// ```
public struct VGRDurationPicker: View {

    /// The selected number of minutes (0–59).
    @Binding var minutes: Int

    /// The selected number of seconds (0–59).
    @Binding var seconds: Int

    /// Label shown after the minutes column (e.g. "minuter").
    let minutesLabel: String

    /// Label shown after the seconds column (e.g. "sekunder").
    let secondsLabel: String

    @State private var selections: [Int] = [0, 0, 0, 0]

    /// Creates a `VGRDurationPicker`.
    ///
    /// - Parameters:
    ///   - minutes: Binding to the selected minute count (0–59).
    ///   - seconds: Binding to the selected second count (0–59).
    ///   - minutesLabel: Label after the minutes wheel. Defaults to the design system bundle key `durationpicker.minutes.full`.
    ///   - secondsLabel: Label after the seconds wheel. Defaults to the design system bundle key `durationpicker.seconds.full`.
    public init(minutes: Binding<Int>,
                seconds: Binding<Int>,
                minutesLabel: String? = nil,
                secondsLabel: String? = nil) {
        self._minutes = minutes
        self._seconds = seconds
        self.minutesLabel = minutesLabel ?? "durationpicker.minutes.full".localizedBundle
        self.secondsLabel = secondsLabel ?? "durationpicker.seconds.full".localizedBundle
    }

    private var pickerData: [[String]] {
        [
            Array(0 ... 59).map { "\($0)" },
            [minutesLabel],
            Array(0 ... 59).map { "\($0)" },
            [secondsLabel],
        ]
    }

    private let widths: [CGFloat] = [48, 65, 48, 75]

    public var body: some View {
        VGRMultiPickerView(
            data: pickerData,
            widths: widths,
            selections: $selections,
            fonts: [.title2, .headline, .title2, .headline]
        )
        .onChange(of: selections) { _, selections in
            minutes = selections[0]
            seconds = selections[2]
        }
        .onAppear {
            selections[0] = minutes
            selections[2] = seconds
        }
    }
}

#Preview {
    @Previewable @State var minutes: Int = 13
    @Previewable @State var seconds: Int = 37

    NavigationStack {
        ScrollView {
            VStack {
                Text("\(minutes) min \(seconds) sek")
                VGRDurationPicker(minutes: $minutes, seconds: $seconds)
            }
            .frame(maxWidth: .infinity,
                   alignment: .center)
        }
        .navigationTitle("VGRDurationPicker")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.Elevation.background)
    }
}
