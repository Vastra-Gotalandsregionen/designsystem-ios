import SwiftUI

public struct LevelSliderConfiguration {
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

    private func color(for index:Int, in colorRange: [ClosedRange<Int>: Color]) -> Color {
        for (colorRange, color) in colorRange {
            if colorRange.contains(index) {
                return color
            }
        }
        return Color.gray
    }

    public func backgroundColor(for index: Int) -> Color {
        return color(for: index, in: backgroundRanges)
    }
    
    public func selectedColor(for index: Int) -> Color {
        return color(for: index, in: selectedRanges)
    }
}

//MARK: Pre-configured sliders.
public extension LevelSliderConfiguration {
    static var migraine: LevelSliderConfiguration {
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
                3...3: Color.Accent.redSurface
            ],
            selectedRanges: [
                0...0: Color.Accent.green,
                1...1: Color.Accent.lime,
                2...2: Color.Accent.yellow,
                3...3: Color.Accent.red
            ]
        )
    }
    
    static var reumatology: LevelSliderConfiguration {
        LevelSliderConfiguration(
            range: 0...4,
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
