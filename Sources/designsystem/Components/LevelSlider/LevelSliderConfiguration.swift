import SwiftUI

public struct LevelSliderConfiguration {
    /// Determines the total range of the slider
    public let range: ClosedRange<Int>

    private let backgroundRanges: [ClosedRange<Int>: Color]
    private let selectedRanges: [ClosedRange<Int>: Color]
    
    public init(range: ClosedRange<Int>,
                backgroundRanges: [ClosedRange<Int>: Color],
                selectedRanges: [ClosedRange<Int>: Color]) {
        self.range = range
        self.backgroundRanges = backgroundRanges
        self.selectedRanges = selectedRanges
    }
    
    public func backgroundColor(for index: Int) -> Color {
        for (colorRange, color) in backgroundRanges {
            if colorRange.contains(index) {
                return color
            }
        }
        return Color.gray
    }
    
    public func selectedColor(for index: Int) -> Color {
        for (range, color) in selectedRanges {
            if range.contains(index) {
                return color
            }
        }
        return Color.gray
    }
}

public struct Level: Identifiable {
    public let id: String
    let index: Int
    let background: Color
    let selected: Color
}

//MARK: Pre-configured sliders.
public extension LevelSliderConfiguration {
    static var headache: LevelSliderConfiguration {
        LevelSliderConfiguration(
            range: 0...5,
            backgroundRanges: [
                0...0: Color.Accent.greenSurface,
                1...2: Color.Accent.yellowSurface,
                3...5: Color.Accent.redSurface
            ],
            selectedRanges: [
                0...0: Color.Accent.green,
                1...2: Color.Accent.orange,
                3...5: Color.Accent.red
            ]
        )
    }
    static var dermatology: LevelSliderConfiguration {
        LevelSliderConfiguration(
            range: 0...3,
            backgroundRanges: [
                0...0: Color.Accent.greenSurface,
                1...1: Color.Accent.limeSurface,
                2...2: Color.Accent.yellowSurface,
                3...4: Color.Accent.redSurface
            ],
            selectedRanges: [
                0...0: Color.Accent.green,
                1...1: Color.Accent.lime,
                2...2: Color.Accent.yellow,
                3...4: Color.Accent.red
            ]
        )
    }
}
