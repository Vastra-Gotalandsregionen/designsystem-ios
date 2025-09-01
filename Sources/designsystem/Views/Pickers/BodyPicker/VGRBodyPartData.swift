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

    /// Returns all `VGRBodyPartData` instances whose `id` matches any of the given identifiers.
    ///
    /// - Parameter ids: An array of body part identifiers to look for.
    /// - Returns: An array of `VGRBodyPartData` objects matching the provided ids.
    ///
    /// The search is recursive and traverses the entire body hierarchy defined in
    /// `VGRBodyPartData.body`. Both top-level parts and nested subparts will be included
    /// if their `id` is contained in the input.
    ///
    /// Example:
    /// ```swift
    /// let matches = VGRBodyPartData.parts(matching: ["left.knee", "head"])
    /// // returns the "left.knee" subpart and the "head" top-level part
    /// ```
    public static func parts(matching ids: [String]) -> [VGRBodyPartData] {
        let idSet = Set(ids)

        func collect(from parts: [VGRBodyPartData]) -> [VGRBodyPartData] {
            parts.flatMap { part -> [VGRBodyPartData] in
                let matched = idSet.contains(part.id) ? [part] : []
                return matched + collect(from: part.subparts)
            }
        }

        return collect(from: VGRBodyPartData.body)
    }

    /// Returns the parent `VGRBodyPartData` of the given body part identifier.
    ///
    /// - Parameter id: The identifier of the body part whose parent should be found.
    /// - Returns:
    ///   - The immediate parent `VGRBodyPartData` if the body part is nested under another part.
    ///   - The body part itself if it is a top-level part.
    ///   - `nil` if no part with the given identifier exists in the hierarchy.
    ///
    /// The search is recursive and will traverse the full body hierarchy until a match is found.
    ///
    /// Example:
    /// ```swift
    /// if let parent = VGRBodyPartData.parent(of: "left.knee") {
    ///     print(parent.id) // "left.leg"
    /// }
    ///
    /// if let parent = VGRBodyPartData.parent(of: "head") {
    ///     print(parent.id) // "head" (since it’s top-level)
    /// }
    /// ```
    public static func parent(of id: String) -> VGRBodyPartData? {

        func findParent(in parts: [VGRBodyPartData], lookingFor id: String) -> VGRBodyPartData? {
            for part in parts {
                /// If one of this part's subparts matches, return this part
                if part.subparts.contains(where: { $0.id == id }) {
                    return part
                }
                /// Otherwise, keep searching deeper
                if let found = findParent(in: part.subparts, lookingFor: id) {
                    return found
                }
            }
            return nil
        }

        /// First, check if the id is a top-level part → return itself
        if let topLevel = body.first(where: { $0.id == id }) {
            return topLevel
        }

        /// Otherwise, search recursively for its parent
        return findParent(in: body, lookingFor: id)
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
                .init(id: "torso.front", visualparts: [.front: VGRBodyPart.front(.torso)]),
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
