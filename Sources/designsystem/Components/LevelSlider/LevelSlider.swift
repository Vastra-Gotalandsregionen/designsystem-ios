import SwiftUI

public struct LevelSlider: View {
    
    @Binding public var selectedIndex: Int?
    public let configuration: LevelSliderConfiguration
    public let action: ((Int) -> Void)?
    
    @State private var elementWidth: CGFloat = 56
    
    private var levels: [Level] {
        configuration.range.map { index in
            Level(id: "\(index)",
                  index: index,
                  background: configuration.backgroundColor(for: index),
                  selected: configuration.selectedColor(for: index))
        }
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { val in
                if let index = getHoveredIndex(location: val.location) {
                    if self.selectedIndex != index {
                        self.selectedIndex = index
                        playSelectionChangedHaptic()
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
    
    private func playSelectionChangedHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    
    public init(selectedIndex: Binding<Int?>, configuration: LevelSliderConfiguration, action: ((Int) -> Void)? = nil) {
        self._selectedIndex = selectedIndex
        self.configuration = configuration
        self.action = action
    }
    
    public var body: some View {
        HStack (alignment: .top, spacing: 4) {
            ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
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
                }
                
                
            }
            .font(.body)
            .fontWeight(.semibold)
        }
        .gesture(drag)
    }
}

#Preview ("Slidah") {
    
    @Previewable @State var selectedIndexHeadache: Int? = nil
    
    
    @Previewable @State var selectedIndexDermatology: Int? = 0
    
     return NavigationStack {
        ScrollView {
            VStack (spacing: 32) {
                VGRShape(backgroundColor: Color.Accent.purpleSurfaceMinimal) {
                    Text("Hur mådde du som värst?")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    VStack(spacing: 6) {
                        Text("Smärtnivå: \(selectedIndexHeadache)")
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                        LevelSlider(
                            selectedIndex: $selectedIndexHeadache,
                            configuration: .headache) { newIndex in
                                print("SelectedIndex: \(newIndex)")
                        }
                    }
                    .padding(16)
                    .background(Color.Elevation.elevation1)
                    .cornerRadius(8)
                }
                
                VGRShape(backgroundColor: Color.Accent.purpleSurfaceMinimal) {
                    Text("Hur mycket kliar, svider, bränns och sticker din hud idag?")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    VStack(spacing: 12) {
                        LevelSlider(selectedIndex: $selectedIndexDermatology, configuration: .dermatology) { newIndex in
                                print("SelectedIndex: \(newIndex)")
                        }
                        
                        Text(selectedIndexDermatology.map { "Level \($0)" } ?? "Level -")
                            .font(.subheadline)
                            .foregroundStyle(Color.Neutral.textVariant)
                        
                    }
                    .padding(16)
                    .background(Color.Elevation.elevation1)
                    .cornerRadius(8)
                }
            }
        }
        .navigationTitle("LevelPickerview")
        .navigationBarTitleDisplayMode(.inline)
    }
}
