import SwiftUI

public struct LevelSlider: View {
    
    @Binding public var selectedIndex: Int?
    public var isDeselectable: Bool = true
    public let configuration: LevelSliderConfiguration
    public let action: ((Int) -> Void)?
    
    @State private var elementWidth: CGFloat = 56
    
    private let generator = UIImpactFeedbackGenerator(style: .soft)
    
    private var levels: [Level] {
        configuration.range.map { index in
            Level(id: "\(index)",
                  index: index,
                  background: configuration.backgroundColor(for: index),
                  selected: configuration.selectedColor(for: index))
        }
    }
    
    private func valueText(isSelected: Bool) -> String {
        isSelected
        ? "general.selected".localizedBundle
        : "general.notselected".localizedBundle
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { val in
                if let index = getHoveredIndex(location: val.location) {
                    if self.selectedIndex != index {
                        self.selectedIndex = index
                        Haptics.lightImpact()
                    } else {
                        /// Make a single tap toggle the selectedIndex
                        if isDeselectable && val.translation.width == 0 {
                            self.selectedIndex = nil
                            Haptics.lightImpact()
                        }
                    }
                }
            }
            .onEnded { val in
                if let action {
                    action(selectedIndex ?? 0)
                }
            }
    }
    
    func getHoveredIndex(location: CGPoint) -> Int? {
        
        /// Default itemWidth
        let itemWidth: CGFloat = elementWidth
        
        for index in 0...levels.count-1 {
            let itemStartX = CGFloat(index) * (itemWidth)
            let itemEndX = itemStartX + itemWidth
            
            if location.x >= itemStartX && location.x <= itemEndX {
                return index
            }
        }
        
        return nil
    }
    
    public init(selectedIndex: Binding<Int?>,
                isDeselectable: Bool = true,
                configuration: LevelSliderConfiguration,
                action: ((Int) -> Void)? = nil) {
        self._selectedIndex = selectedIndex
        self.isDeselectable = isDeselectable
        self.configuration = configuration
        self.action = action
    }
    
    public var body: some View {
        HStack (alignment: .top, spacing: 4) {
            ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                let isSelected = (selectedIndex == level.index)
                if index == 0 {
                    Text(level.id)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onSizeChanged { size in
                            elementWidth = size.width
                        }
                        .background(level.background)
                        .clipShape(
                            .rect(topLeadingRadius: 50,
                                  bottomLeadingRadius: 50,
                                  bottomTrailingRadius: 4,
                                  topTrailingRadius: 4
                                 )
                        )
                        .overlay {
                            if selectedIndex == level.index {
                                CustomRoundedRect(topLeadingRadius: 50,
                                                  bottomLeadingRadius: 50,
                                                  bottomTrailingRadius: 4,
                                                  topTrailingRadius: 4,
                                                  strokeWidth: 2)
                                .stroke(level.selected, lineWidth: 2)
                            }
                        }
                        .accessibilityLabel(level.id)
                        .accessibilityValue(valueText(isSelected: isSelected))
                        .accessibilityAddTraits(.isButton)
                } else if index == levels.count-1 {
                    Text(level.id)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(level.background)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 4,
                                bottomLeadingRadius: 4,
                                bottomTrailingRadius: 50,
                                topTrailingRadius: 50
                            )
                        )
                        .overlay {
                            if selectedIndex == level.index {
                                CustomRoundedRect(topLeadingRadius: 4,
                                                  bottomLeadingRadius: 4,
                                                  bottomTrailingRadius: 50,
                                                  topTrailingRadius: 50,
                                                  strokeWidth: 2)
                                .stroke(level.selected, lineWidth: 2)
                            }
                        }
                        .accessibilityLabel(level.id)
                        .accessibilityValue(valueText(isSelected: isSelected))
                        .accessibilityAddTraits(.isButton)
                } else {
                    Text(level.id)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(level.background)
                        .cornerRadius(4)
                        .overlay {
                            if selectedIndex == level.index {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(level.selected, lineWidth: 2)
                            }
                        }
                        .accessibilityLabel(level.id)
                        .accessibilityValue(valueText(isSelected: isSelected))
                        .accessibilityAddTraits(.isButton)
                }
            }
            .font(.body)
            .fontWeight(.semibold)
        }
        .gesture(drag)
        .overlay(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { newSize in
            DispatchQueue.main.async {
                self.elementWidth = newSize.width / CGFloat(levels.count)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedIndexHeadache: Int? = 0
    @Previewable @State var selectedIndexDermatology: Int? = nil
    @Previewable @State var selectedIndexReumatology: Int? = nil
    @Previewable @State var selectedIndexCustom: Int? = 0
    
    return NavigationStack {
        ScrollView {
            VStack (spacing: 32) {
                
                //MARK: - This example represents what we have in Migraine.
                VGRShape(backgroundColor: Color.Primary.blueSurfaceMinimal) {
                    Text("Migraine")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(selectedIndexHeadache.map { "Smärtnivå \($0)" } ?? "Smärtnivå: ")
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                        
                        LevelSlider(
                            selectedIndex: $selectedIndexHeadache,
                            isDeselectable: false,
                            configuration: .migraine) { newIndex in
                                print("SelectedIndex: \(newIndex)")
                            }
                        
                        Text(selectedIndexHeadache.map { "Level \($0)" } ?? "Inget valt")
                            .font(.subheadline)
                            .foregroundStyle(Color.Neutral.textVariant)
                    }
                    .padding(16)
                    .background(Color.Elevation.elevation1)
                    .cornerRadius(8)
                }
                
                //MARK: - This example represents what we have in Dermatology.
                VGRShape(backgroundColor: Color.Accent.purpleSurfaceMinimal) {
                    Text("Dermatology")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    VStack(spacing: 12) {
                        LevelSlider(selectedIndex: $selectedIndexDermatology, configuration: .dermatology) { newIndex in
                            print("SelectedIndex: \(newIndex)")
                        }
                        
                        Text(selectedIndexDermatology.map { "Level \($0)" } ?? "Inget valt")
                            .font(.subheadline)
                            .foregroundStyle(Color.Neutral.textVariant)
                        
                    }
                    .padding(16)
                    .background(Color.Elevation.elevation1)
                    .cornerRadius(8)
                }
                
                //MARK: - This example represents what we have in Reumatology.
                VGRShape(backgroundColor: Color.Accent.brownSurfaceMinimal) {
                    Text("Reumatology")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    VStack(spacing: 12) {
                        LevelSlider(selectedIndex: $selectedIndexReumatology, configuration: .reumatology) { newIndex in
                            print("SelectedIndex: \(newIndex)")
                        }
                        
                        Text(selectedIndexReumatology.map { "Level \($0)" } ?? "Inget valt")
                            .font(.subheadline)
                            .foregroundStyle(Color.Neutral.textVariant)
                        
                    }
                    .padding(16)
                    .background(Color.Elevation.elevation1)
                    .cornerRadius(8)
                }
                
                //MARK: - This example represents a completely custom configuration.
                VGRShape(backgroundColor: Color.Accent.cyanSurfaceMinimal) {
                    Text("Custom - (Default 0)")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    VStack(spacing: 12) {
                        LevelSlider(
                            selectedIndex: $selectedIndexCustom,
                            configuration: LevelSliderConfiguration(
                                range: 0...9,
                                backgroundRanges: [
                                    0...0 : Color.Accent.brownSurface,
                                    1...1 : Color.Accent.cyanSurface,
                                    2...2 : Color.Accent.greenSurface,
                                    3...3 : Color.Accent.orangeSurface,
                                    4...4 : Color.Accent.pinkSurface,
                                    5...5 : Color.Accent.purpleSurface,
                                    6...6 : Color.Accent.redSurface,
                                    7...7 : Color.Accent.yellowSurface,
                                    8...8 : Color.Accent.brownSurface,
                                    9...9 : Color.Accent.cyanSurface
                                    
                                ],
                                selectedRanges: [
                                    0...0 : Color.Accent.brown,
                                    1...1 : Color.Accent.cyan,
                                    2...2 : Color.Accent.green,
                                    3...3 : Color.Accent.orange,
                                    4...4 : Color.Accent.pink,
                                    5...5 : Color.Accent.purple,
                                    6...6 : Color.Accent.red,
                                    7...7 : Color.Accent.yellow,
                                    8...8 : Color.Accent.brown,
                                    9...9 : Color.Accent.cyan
                                ])
                        ) { newIndex in
                            print("SelectedIndex: \(newIndex)")
                        }
                        
                        Text(selectedIndexCustom.map { "Level \($0)" } ?? "Level -")
                            .font(.subheadline)
                            .foregroundStyle(Color.Neutral.textVariant)
                        
                    }
                    .padding(16)
                    .background(Color.Elevation.elevation1)
                    .cornerRadius(8)
                }
            }
        }
        .navigationTitle("LevelPicker")
        .navigationBarTitleDisplayMode(.inline)
    }
}
