import SwiftUI


/// A `Shape` that renders a specific body part using a vector path.
///
/// The shape is based on a `VGRBodyPart` and normalized to fit the given
/// rectangle while preserving aspect ratio. 
struct VGRBodyPartShape: Shape {
    let bodyPart: VGRBodyPart

    func path(in rect: CGRect) -> Path {
        let bpath = UIBezierPath()
        bpath.append(bodyPart.path)
        let norm = normalize(bpath, to: rect)
        return Path(norm.cgPath)
    }

    /// Normalize resizes the original body image to fit the shapes rectangle
    private func normalize(_ path: UIBezierPath, to rect: CGRect) -> UIBezierPath {
        /// Absolute size (hardcoded) of the Body vector (from Figma)
        let boundingBox = CGRect(x: 0, y: 0, width: 240, height: 662)
        let scaleX = rect.width / boundingBox.width
        let scaleY = rect.height / boundingBox.height
        let scale = min(scaleX, scaleY)  // Keep aspect ratio

        let normalizedPath = UIBezierPath()

        path.cgPath.applyWithBlock { elementPointer in
            let element = elementPointer.pointee
            let points = element.points

            switch element.type {
                case .moveToPoint:
                    normalizedPath.move(to: scalePoint(points[0], boundingBox, scale, rect))
                case .addLineToPoint:
                    normalizedPath.addLine(to: scalePoint(points[0], boundingBox, scale, rect))
                case .addQuadCurveToPoint:
                    normalizedPath.addQuadCurve(to: scalePoint(points[1], boundingBox, scale, rect),
                                                controlPoint: scalePoint(points[0], boundingBox, scale, rect))
                case .addCurveToPoint:
                    normalizedPath.addCurve(to: scalePoint(points[2], boundingBox, scale, rect),
                                            controlPoint1: scalePoint(points[0], boundingBox, scale, rect),
                                            controlPoint2: scalePoint(points[1], boundingBox, scale, rect))
                case .closeSubpath:
                    normalizedPath.close()
                @unknown default:
                    break
            }
        }

        return normalizedPath
    }

    private func scalePoint(_ point: CGPoint, _ boundingBox: CGRect, _ scale: CGFloat, _ rect: CGRect) -> CGPoint {
        let normalizedX = (point.x - boundingBox.minX) * scale + rect.minX
        let normalizedY = (point.y - boundingBox.minY) * scale + rect.minY
        return CGPoint(x: normalizedX, y: normalizedY)
    }
}
