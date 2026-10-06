import SwiftUI

/// The five discrete states a ``Blob2`` can display.
///
/// The raw value matches the integer index used by the legacy ``Blob`` view,
/// so `BlobState(rawValue: 2)` is the same state as `Blob(state: 2)`.
public enum BlobState: Int, CaseIterable, Sendable {
    case one
    case two
    case three
    case four
    case five

    /// Creates a state from a legacy integer index. `nil` or an index outside
    /// `0..<5` gives ``one``, mirroring the fallback in ``Blob``.
    public init(index: Int?) {
        self = index.flatMap(BlobState.init(rawValue:)) ?? .one
    }
}

/// A two-layer organic blob drawn with SwiftUI.
///
/// The blob has five states that differ in shape and color. Changing ``state``
/// morphs the outline and cross-fades the colors with ``Blob2/transition``.
/// Both layers idle with a slow wobble, pulse and rotation that run independently
/// of each other. The inner layer is clipped to the outer layer, so it can never
/// be drawn outside it.
///
/// The view is square and scales to the smaller of the proposed width and height.
///
/// ```swift
/// Blob2(state: .three)
///     .frame(width: 164, height: 164)
/// ```
public struct Blob2: View {
    /// The animation used when ``state`` changes: a bouncy spring that overshoots
    /// the target shape and wobbles briefly before settling.
    public static let transition: Animation = .spring(duration: 0.75, bounce: 0.45)

    let state: BlobState

    @State private var startDate = Date()

    public init(state: BlobState) {
        self.state = state
    }

    /// Creates a blob from a legacy integer index. See ``BlobState/init(index:)``.
    public init(index: Int?) {
        self.init(state: BlobState(index: index))
    }

    public var body: some View {
        TimelineView(.animation) { context in
            BlobLayers(
                outer: Self.outerKeyframes[state.rawValue].vector,
                inner: Self.innerKeyframes[state.rawValue].vector,
                time: context.date.timeIntervalSince(startDate)
            )
        }
        .animation(Self.transition, value: state)
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

/// Draws both layers from interpolated vectors. Conforming the view, not just the
/// shapes, to `Animatable` lets SwiftUI interpolate the outline and the fill color
/// as one value, so they always stay in step during a state change.
private struct BlobLayers: View, Animatable {
    var outer: BlobVector
    var inner: BlobVector
    var time: TimeInterval

    nonisolated var animatableData: AnimatablePair<BlobVector, BlobVector> {
        get { AnimatablePair(outer, inner) }
        set {
            outer = newValue.first
            inner = newValue.second
        }
    }

    var body: some View {
        let outerShape = BlobLayerShape(vector: outer, time: time, motion: .outer)
        let innerShape = BlobLayerShape(vector: inner, time: time, motion: .inner)

        ZStack {
            outerShape.fill(outer.color)
            innerShape.fill(inner.color)
                .clipShape(outerShape)
        }
    }
}

// MARK: - Idle motion

/// Parameters for a layer's idle motion. Periods are in seconds, amplitudes in
/// fractions of the layer's size (pulse, wobble) or radians (rotation).
struct BlobMotion {
    let rotationAmplitude: Double
    let rotationPeriod: Double
    let pulseAmplitude: Double
    let pulsePeriod: Double
    let wobbleAmplitude: Double
    let wobblePeriod: Double
    /// Offsets every oscillator so two layers with similar periods never move in step.
    let phase: Double

    static let outer = BlobMotion(
        rotationAmplitude: .pi / 28,
        rotationPeriod: 7.5,
        pulseAmplitude: 0.045,
        pulsePeriod: 5,
        wobbleAmplitude: 0.055,
        wobblePeriod: 3.8,
        phase: 0
    )

    static let inner = BlobMotion(
        rotationAmplitude: .pi / 22,
        rotationPeriod: 6.2,
        pulseAmplitude: 0.06,
        pulsePeriod: 4,
        wobbleAmplitude: 0.07,
        wobblePeriod: 3,
        phase: 2.1
    )
}

// MARK: - Shape

/// One blob layer at a given moment. `vector` is the interpolated outline, see
/// ``BlobVector``; `time` drives the idle motion.
struct BlobLayerShape: Shape {
    let vector: BlobVector
    let time: TimeInterval
    let motion: BlobMotion

    func path(in rect: CGRect) -> Path {
        let values = vector.values
        let vertexCount = vector.vertexCount
        guard vertexCount >= 2 else { return Path() }

        let canvas = Blob2.canvasSize
        let canvasCenter = CGPoint(x: canvas / 2, y: canvas / 2)
        let side = min(rect.width, rect.height)
        let scale = side / canvas

        // Idle transform: a slow rotation and pulse around the canvas center.
        let twoPi = 2 * Double.pi
        let angle = motion.rotationAmplitude * sin(twoPi * time / motion.rotationPeriod + motion.phase)
        let pulse = 1 + motion.pulseAmplitude * sin(twoPi * time / motion.pulsePeriod + motion.phase * 1.3)
        let transform = CGAffineTransform(translationX: rect.midX, y: rect.midY)
            .rotated(by: angle)
            .scaledBy(x: scale * pulse, y: scale * pulse)
            .translatedBy(x: -canvasCenter.x, y: -canvasCenter.y)

        // Idle wobble: push each vertex, with its control points, along the
        // direction from the center. Two sines with different periods and a
        // per-vertex phase make the motion organic rather than a uniform pulse.
        func wobbled(_ index: Int) -> (vertex: CGPoint, inControl: CGPoint, outControl: CGPoint) {
            let base = index * 6
            let vertex = CGPoint(x: values[base], y: values[base + 1])
            let inControl = CGPoint(x: values[base + 2], y: values[base + 3])
            let outControl = CGPoint(x: values[base + 4], y: values[base + 5])

            let dx = vertex.x - canvasCenter.x
            let dy = vertex.y - canvasCenter.y
            let radius = (dx * dx + dy * dy).squareRoot()
            guard radius > 0 else { return (vertex, inControl, outControl) }

            let phase = Double(index) * 2.4 + motion.phase
            let wave = 0.6 * sin(twoPi * time / motion.wobblePeriod + phase)
                + 0.4 * sin(twoPi * time / (motion.wobblePeriod * 0.63) + phase * 1.7 + 0.8)
            let offset = motion.wobbleAmplitude * wave * radius
            let shift = CGPoint(x: dx / radius * offset, y: dy / radius * offset)

            return (
                CGPoint(x: vertex.x + shift.x, y: vertex.y + shift.y),
                CGPoint(x: inControl.x + shift.x, y: inControl.y + shift.y),
                CGPoint(x: outControl.x + shift.x, y: outControl.y + shift.y)
            )
        }

        var path = Path()
        let points = (0..<vertexCount).map(wobbled)
        path.move(to: points[0].vertex)
        for index in 0..<vertexCount {
            let from = points[index]
            let to = points[(index + 1) % vertexCount]
            path.addCurve(to: to.vertex, control1: from.outControl, control2: to.inControl)
        }
        path.closeSubpath()
        return path.applying(transform)
    }
}

// MARK: - Animatable vector

/// A variable-length vector so a whole outline plus color can be interpolated
/// by SwiftUI as one animatable value.
///
/// Layout: six values per vertex as described in `Blob2+Data.swift`, followed by
/// three trailing values for the fill color's red, green and blue components.
struct BlobVector: VectorArithmetic {
    var values: [Double]

    var vertexCount: Int { max(values.count - 3, 0) / 6 }

    var color: Color {
        guard values.count >= 3 else { return .clear }
        let v = values
        return Color(red: v[v.count - 3], green: v[v.count - 2], blue: v[v.count - 1])
    }

    static var zero: BlobVector { BlobVector(values: []) }

    static func + (lhs: BlobVector, rhs: BlobVector) -> BlobVector {
        combine(lhs, rhs, +)
    }

    static func - (lhs: BlobVector, rhs: BlobVector) -> BlobVector {
        combine(lhs, rhs, -)
    }

    mutating func scale(by rhs: Double) {
        values = values.map { $0 * rhs }
    }

    var magnitudeSquared: Double {
        values.reduce(0) { $0 + $1 * $1 }
    }

    /// Element-wise operation that treats a shorter operand as zero-padded, so
    /// `.zero` can be combined with any vector.
    private static func combine(_ lhs: BlobVector, _ rhs: BlobVector, _ op: (Double, Double) -> Double) -> BlobVector {
        let count = max(lhs.values.count, rhs.values.count)
        var result = [Double](repeating: 0, count: count)
        for index in 0..<count {
            let l = index < lhs.values.count ? lhs.values[index] : 0
            let r = index < rhs.values.count ? rhs.values[index] : 0
            result[index] = op(l, r)
        }
        return BlobVector(values: result)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var state: BlobState = .one

    VStack(spacing: 16) {
        Blob2(state: state)
            .frame(width: 164, height: 164)

        Picker("State", selection: $state) {
            ForEach(BlobState.allCases, id: \.self) {
                Text("\($0.rawValue + 1)").tag($0)
            }
        }
        .pickerStyle(.segmented)
    }
    .padding(16)
}
