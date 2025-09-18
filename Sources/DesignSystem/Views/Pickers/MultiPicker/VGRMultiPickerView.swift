import SwiftUI

public struct VGRMultiPickerView: UIViewRepresentable {
    /// data contains the content of the spinner wheels
    public var data: [[String]]

    /// widths contains the width of the individual components in the spinner wheel
    public var widths: [CGFloat]

    /// adds the possibility to set font on each individual picker component
    public var fonts: [UIFont] = []

    /// selections holds the indexes of the selected items in data
    @Binding public var selections: [Int]

    public var defaultComponentWidth: CGFloat = 80

    /// Public initializer
    public init(data: [[String]],
                widths: [CGFloat],
                selections: Binding<[Int]>,
                defaultComponentWidth: CGFloat = 80,
                fonts: [UIFont.TextStyle] = []) {
        self.data = data
        self.widths = widths
        self._selections = selections
        self.defaultComponentWidth = defaultComponentWidth
        self.fonts = fonts.map { UIFont.preferredFont(forTextStyle: $0) }
    }

    public func makeCoordinator() -> VGRMultiPickerView.Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: UIViewRepresentableContext<VGRMultiPickerView>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)

        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator

        return picker
    }

    public func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<VGRMultiPickerView>) {
        for i in 0 ... (selections.count - 1) {
            view.selectRow(selections[i], inComponent: i, animated: false)
        }
        view.frame = CGRect(origin: .zero, size: context.coordinator.proposedSize)
        context.coordinator.parent = self // fix
    }

    /// Propose a size based on SwiftUI's layout
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIPickerView, context: Context) -> CGSize {
        /// Use the proposed size, falling back to a reasonable default if unspecified
        let proposedSize = proposal.replacingUnspecifiedDimensions(by: CGSize(width: 300, height: 216)) /// Default UIPickerView height is ~216
        context.coordinator.proposedSize = proposedSize
        return proposedSize
    }

    public class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: VGRMultiPickerView
        var proposedSize: CGSize = .zero /// Store the proposed size

        init(_ pickerView: VGRMultiPickerView) {
            parent = pickerView
        }

        public func numberOfComponents(in _: UIPickerView) -> Int {
            return parent.data.count
        }

        public func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return parent.data[component].count
        }

        public func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return parent.data[component][row]
        }

        public func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selections[component] = row
        }

        public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            var font = UIFont.preferredFont(forTextStyle: .title2)
            let label: UILabel = (view as? UILabel) ?? {
                let label: UILabel = UILabel()
                if parent.fonts.count > 0 {
                    let index = min(component,parent.fonts.count-1)
                    font = parent.fonts[index]
                }
                label.font = font
                label.textAlignment = .center
                return label
            }()
            label.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
            return label
        }

        public func pickerView(_: UIPickerView, widthForComponent component: Int) -> CGFloat {
            if component <= parent.widths.count {
                let width = parent.widths[component]
                return width
            }
            return parent.defaultComponentWidth
        }
    }
}

#Preview {
    @Previewable @State var selections: [Int] = [1, 0, 10, 0]

    let data: [[String]] = [
        ["Once", "Twice", "Thrice"],
        ["in"],
        Array(20 ... 40).map { "\($0)" },
        ["Day", "Week", "Month", "Year"],
    ]

    let widths: [CGFloat] = [
        90, 40, 60, 80,
    ]

    NavigationStack {
        ScrollView {
            VStack {
                VGRMultiPickerView(data: data,
                                   widths: widths,
                                   selections: $selections,
                                   fonts: [.title2, .headline, .title2, .headline])

                Text("\(data[0][selections[0]]) \(data[1][selections[1]]) \(data[2][selections[2]]) \(data[3][selections[3]])")
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color.Elevation.background)
        .navigationTitle("VGRMultiPickerView")
        .navigationBarTitleDisplayMode(.inline)
    }
}
