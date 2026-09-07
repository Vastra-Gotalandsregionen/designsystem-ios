import Foundation
import SwiftUI

/// A `Shape` that renders a specific body part using a vector path.
///
/// The shape is based on a `VGRBodyPart` and normalized to fit the given
/// rectangle while preserving aspect ratio.
///
/// Body part paths are immutable and expensive to build (each is hand-coded as
/// hundreds of curve commands), so the unscaled `Path` of every part is built
/// once by `VGRBodyPathCache` and fitting it to `rect` is a single affine
/// transform. This matters because SwiftUI evaluates `path(in:)` for the fill,
/// again for the stroke, and again for every `contentShape` hit test.
struct VGRBodyPartShape: Shape {
    let bodyPart: VGRBodyPart

    func path(in rect: CGRect) -> Path {
        VGRBodyPathCache.shared
            .path(for: bodyPart)
            .applying(VGRBodyPathCache.transform(fitting: rect))
    }
}

/// A `Shape` that renders the outlines of every neutral body part for an
/// orientation as one path, so region boundaries can be stroked in a single
/// pass instead of once per part.
struct VGRBodyOutlineShape: Shape {
    let orientation: VGRBodyOrientation

    func path(in rect: CGRect) -> Path {
        VGRBodyPathCache.shared
            .outline(for: orientation)
            .applying(VGRBodyPathCache.transform(fitting: rect))
    }
}

/// Lazily filled, thread-safe cache of unscaled body part paths.
///
/// Keyed by `VGRBodyPart`, so composite parts (ears, hips, groins, the face
/// with its ear cutouts) are cached as their own entries and their sub-paths
/// are only ever built once.
final class VGRBodyPathCache: @unchecked Sendable {
    static let shared = VGRBodyPathCache()

    /// Absolute size (hardcoded) of the Body vector (from Figma)
    static let sourceBounds = CGRect(x: 0, y: 0, width: 721, height: 1979)

    private let lock = NSLock()
    private var paths: [VGRBodyPart: Path] = [:]
    private var outlines: [VGRBodyOrientation: Path] = [:]

    /// Returns the transform that fits the source vector into `rect`, keeping
    /// the aspect ratio and anchoring at the rect's origin.
    static func transform(fitting rect: CGRect) -> CGAffineTransform {
        let scale = min(rect.width / sourceBounds.width, rect.height / sourceBounds.height)
        return CGAffineTransform(a: scale, b: 0, c: 0, d: scale,
                                 tx: rect.minX - sourceBounds.minX * scale,
                                 ty: rect.minY - sourceBounds.minY * scale)
    }

    /// The unscaled path of a single body part, built on first use.
    func path(for part: VGRBodyPart) -> Path {
        lock.lock()
        defer { lock.unlock() }

        if let cached = paths[part] { return cached }

        let built = Path(part.path.cgPath)
        paths[part] = built
        return built
    }

    /// The unscaled outlines of all neutral parts for an orientation as one
    /// path, built on first use.
    func outline(for orientation: VGRBodyOrientation) -> Path {
        lock.lock()
        if let cached = outlines[orientation] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        /// Built outside the lock since `path(for:)` takes it. Two threads
        /// racing here would store the same value, which is harmless.
        var outline = Path()
        let parts = orientation == .front ? VGRBodyPart.neutralFront : VGRBodyPart.neutralBack
        for part in parts {
            outline.addPath(path(for: part))
        }

        lock.lock()
        outlines[orientation] = outline
        lock.unlock()
        return outline
    }
}
