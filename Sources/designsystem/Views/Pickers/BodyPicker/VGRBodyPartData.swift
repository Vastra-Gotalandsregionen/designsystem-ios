import Foundation

/// VGRBodyPartData is a structure used to communicate the selectable parts to the user.
/// This struct represents the data behind the user facing UI, whereas VGRBodyPart represents the visual representation
/// of body parts.
struct VGRBodyPartData {
	let id: String
    var side: VGRBodySide = .notApplicable
    var visualparts: [VGRBodyOrientation:VGRBodyPart] = [:]
    var subparts: [VGRBodyPartData] = []
}

enum VGRBodySide {
	case left
	case right
    case notApplicable
}

enum VGRBodyOrientation {
	case front
	case back
}


extension VGRBodyPartData {
    static let body: [VGRBodyPartData] = [
        .init(
            id: "left.leg",
            side: .left,
            visualparts: [.front: VGRBodyPart.front(.leftLeg), .back: VGRBodyPart.back(.leftLeg)],
            subparts: [
                .init(id: "left.lower.leg", side: .left, visualparts: [.front: VGRBodyPart.front(.leftThigh), .back: VGRBodyPart.back(.leftThigh)]),
                .init(id: "left.upper.leg", side: .left, visualparts: [.front: VGRBodyPart.front(.leftCalf), .back: VGRBodyPart.back(.leftCalf)]),
                .init(id: "left.knee", side: .left, visualparts: [.front: VGRBodyPart.front(.leftKnee)]),
                .init(id: "left.hollow.of.knee", side: .left, visualparts: [.back: VGRBodyPart.back(.leftHollowOfKnee)])
            ]
        ),
        .init(
            id: "right.leg",
            side: .left,
            visualparts: [.front: VGRBodyPart.front(.leftLeg), .back: VGRBodyPart.back(.leftLeg)],
            subparts: [
                .init(id: "right.lower.leg", side: .right, visualparts: [.front: VGRBodyPart.front(.rightThigh), .back: VGRBodyPart.back(.rightThigh)]),
                .init(id: "right.upper.leg", side: .right, visualparts: [.front: VGRBodyPart.front(.rightCalf), .back: VGRBodyPart.back(.rightCalf)]),
                .init(id: "right.knee", side: .right, visualparts: [.front: VGRBodyPart.front(.rightKnee)]),
                .init(id: "right.hollow.of.knee", side: .right, visualparts: [.back: VGRBodyPart.back(.rightHollowOfKnee)])
            ]
        ),
        .init(
            id: "head",
            subparts: [
                .init(id: "head.face", visualparts: [.front: VGRBodyPart.front(.face)]),
                .init(id: "head.throat", visualparts: [.front: VGRBodyPart.front(.throat)]),
                .init(id: "head.scalp", visualparts: [.front: VGRBodyPart.front(.scalp), .back: VGRBodyPart.back(.scalp)]),
                .init(id: "head.neck", visualparts: [.front: VGRBodyPart.back(.neck)])
            ]
        ),
    ]
}
