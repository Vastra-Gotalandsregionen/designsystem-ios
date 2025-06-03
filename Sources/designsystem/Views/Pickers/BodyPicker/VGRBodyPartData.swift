import Foundation

/// VGRBodyPartData is a structure used to communicate the selectable parts to the user.
/// This struct represents the data behind the user facing UI, whereas VGRBodyPart represents the visual representation
/// of body parts.
public struct VGRBodyPartData : Sendable, Hashable, Identifiable {
	public let id: String
    public var side: VGRBodySide = .notApplicable
    public var visualparts: [VGRBodyOrientation:VGRBodyPart] = [:]
    public var subparts: [VGRBodyPartData] = []

    /// displayName returns the localized name of the current body part, prefixed with the side of the body (eg. "left hollow of knee", "right arm", etc)
    public var displayName: String {
        /// Get localized side if applicable
        let side = self.side == .notApplicable ? "" : "bodypicker.side.\(self.side)".localizedBundle + " "

        /// Get localized body part name
        let name = "bodypicker.\(self.id)".localizedBundle

        return "\(side)\(name)"
    }
}

public enum VGRBodySide: String, Sendable, Hashable {
	case left = "left"
	case right = "right"
    case notApplicable = ""
}

public enum VGRBodyOrientation : String, Sendable, Hashable {
	case front
	case back
}

extension VGRBodyPartData {

    public static func parts(matching ids: [String]) -> [VGRBodyPartData] {
        var result: [VGRBodyPartData] = []

        func collect(from parts: [VGRBodyPartData]) {
            for part in parts {
                if ids.contains(part.id) {
                    result.append(part)
                }
                collect(from: part.subparts)
            }
        }

        collect(from: VGRBodyPartData.body)
        return result
    }

    public static let body: [VGRBodyPartData] = [
        .init(
            id: "left.leg",
            side: .left,
            visualparts: [.front: VGRBodyPart.front(.leftLeg), .back: VGRBodyPart.back(.leftLeg)],
            subparts: [
                .init(id: "left.upper.leg", side: .left, visualparts: [.front: VGRBodyPart.front(.leftThigh), .back: VGRBodyPart.back(.leftThigh)]),
                .init(id: "left.knee", side: .left, visualparts: [.front: VGRBodyPart.front(.leftKnee)]),
                .init(id: "left.hollow.of.knee", side: .left, visualparts: [.back: VGRBodyPart.back(.leftHollowOfKnee)]),
                .init(id: "left.lower.leg", side: .left, visualparts: [.front: VGRBodyPart.front(.leftCalf), .back: VGRBodyPart.back(.leftCalf)]),
            ]
        ),
        .init(
            id: "right.leg",
            side: .right,
            visualparts: [.front: VGRBodyPart.front(.rightLeg), .back: VGRBodyPart.back(.rightLeg)],
            subparts: [
                .init(id: "right.upper.leg", side: .right, visualparts: [.front: VGRBodyPart.front(.rightThigh), .back: VGRBodyPart.back(.rightThigh)]),
                .init(id: "right.knee", side: .right, visualparts: [.front: VGRBodyPart.front(.rightKnee)]),
                .init(id: "right.hollow.of.knee", side: .right, visualparts: [.back: VGRBodyPart.back(.rightHollowOfKnee)]),
                .init(id: "right.lower.leg", side: .right, visualparts: [.front: VGRBodyPart.front(.rightCalf), .back: VGRBodyPart.back(.rightCalf)]),
            ]
        ),
        .init(
            id: "head",
            visualparts: [.front: VGRBodyPart.front(.head), .back: VGRBodyPart.back(.head)],
            subparts: [
                .init(id: "head.face", visualparts: [.front: VGRBodyPart.front(.face)]),
                .init(id: "head.throat", visualparts: [.front: VGRBodyPart.front(.throat)]),
                .init(id: "head.scalp", visualparts: [.front: VGRBodyPart.front(.scalp), .back: VGRBodyPart.back(.head)]),
//                .init(id: "head.back", visualparts: []),
                .init(id: "head.neck", visualparts: [.back: VGRBodyPart.back(.neck)])
            ]
        ),
        .init(
            id: "pelvis",
            visualparts: [.front: VGRBodyPart.front(.pelvisFront)],
            subparts: [
                .init(id: "pelvis.front.genitalia", visualparts: [.front: VGRBodyPart.front(.pelvisFront)]),
                .init(id: "pelvis.back.between.cheeks", visualparts: [.back: VGRBodyPart.back(.pelvisBack)]),
            ]
        ),
        .init(
            id: "left.hand",
            side: .left,
            subparts: [
                .init(id: "left.hand.palm", side: .left, visualparts: [.front: VGRBodyPart.front(.leftPalm)]),
                .init(id: "left.hand.back.of.hand", side: .left, visualparts: [.back: VGRBodyPart.back(.leftBackOfHand)]),
            ]
        ),
        .init(
            id: "right.hand",
            side: .right,
            subparts: [
                .init(id: "right.hand.palm", side: .right, visualparts: [.front: VGRBodyPart.front(.rightPalm)]),
                .init(id: "right.hand.back.of.hand", side: .right, visualparts: [.back: VGRBodyPart.back(.rightBackOfHand)]),
            ]
        ),
        .init(
            id: "left.arm",
            side: .left,
            visualparts: [.front: VGRBodyPart.front(.leftArm), .back: VGRBodyPart.back(.leftArm)],
            subparts: [
                .init(id: "left.upper.arm", side: .left, visualparts: [.front: VGRBodyPart.front(.leftUpperArm), .back: VGRBodyPart.back(.leftUpperArm)]),
                .init(id: "left.elbow", side: .left, visualparts: [.back: VGRBodyPart.back(.leftArmElbow)]),
                .init(id: "left.armfold", side: .left, visualparts: [.front: VGRBodyPart.front(.leftArmFold)]),
                .init(id: "left.under.arm", side: .left, visualparts: [.front: VGRBodyPart.front(.leftUnderArm), .back: VGRBodyPart.back(.leftUnderArm)]),
            ]
        ),
        .init(
            id: "right.arm",
            side: .right,
            visualparts: [.front: VGRBodyPart.front(.rightArm), .back: VGRBodyPart.back(.rightArm)],
            subparts: [
                .init(id: "right.upper.arm", side: .right, visualparts: [.front: VGRBodyPart.front(.rightUpperArm), .back: VGRBodyPart.back(.rightUpperArm)]),
                .init(id: "right.elbow", side: .right, visualparts: [.back: VGRBodyPart.back(.rightArmElbow)]),
                .init(id: "right.armfold", side: .right, visualparts: [.front: VGRBodyPart.front(.rightArmFold)]),
                .init(id: "right.under.arm", side: .right, visualparts: [.front: VGRBodyPart.front(.rightUnderArm), .back: VGRBodyPart.back(.rightUnderArm)]),
            ]
        ),
        .init(
            id: "torso",
            side: .notApplicable,
            visualparts: [.front: VGRBodyPart.front(.upperBody), .back: VGRBodyPart.back(.torso)],
            subparts: [
                .init(id: "torso.left.armpit", side: .left, visualparts: [.front: VGRBodyPart.front(.leftArmPit), .back: VGRBodyPart.back(.leftArmPit)]),
                .init(id: "torso.chest", visualparts: [.front: VGRBodyPart.front(.torso)]),
                .init(id: "torso.back", visualparts: [.back: VGRBodyPart.back(.back)]),
                .init(id: "torso.right.armpit", side: .right, visualparts: [.front: VGRBodyPart.front(.rightArmPit), .back: VGRBodyPart.back(.rightArmPit)]),
            ]
        ),
        .init(
            id: "right.foot",
            side: .right,
            visualparts: [.front: VGRBodyPart.front(.rightFoot)],
            subparts: [
                .init(id: "right.foot.base", side: .right, visualparts: [.front: VGRBodyPart.front(.rightFoot), .back: VGRBodyPart.back(.rightFoot)]),
                .init(id: "right.foot.sole", side: .right, visualparts: [.front: VGRBodyPart.front(.rightFoot), .back: VGRBodyPart.back(.rightFoot)]),
            ]
        ),
        .init(
            id: "left.foot",
            side: .left,
            visualparts: [.front: VGRBodyPart.front(.leftFoot)],
            subparts: [
                .init(id: "left.foot.base", side: .left, visualparts: [.front: VGRBodyPart.front(.leftFoot), .back: VGRBodyPart.back(.leftFoot)]),
                .init(id: "left.foot.sole", side: .left, visualparts: [.front: VGRBodyPart.front(.leftFoot), .back: VGRBodyPart.back(.leftFoot)]),
            ]
        ),
    ]
}
