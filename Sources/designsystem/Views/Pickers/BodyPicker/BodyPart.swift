import SwiftUI

/// Represents a specific selectable area on the human body, used for visual segmentation.
///
/// A `BodyPart` can represent both front and back views of the body, allowing for
/// consistent identification of areas for interaction, selection, or annotation.
///
/// Each case should be associated with a side (`front` or `back`) and a specific anatomical region.
///
/// Example usage:
/// ```swift
/// let part = BodyPart.front(.leftArm)
/// ```
///
/// You can use this to render shapes, handle selections, and manage hierarchical body part relationships.
public enum BodyPart: Sendable, Equatable, Hashable, Identifiable {
    case back(BodyPart.Back)
    case front(BodyPart.Front)

    public var id: String {
        switch self {
            case .front(let part): return "front.\(part.rawValue)"
            case .back(let part): return "back.\(part.rawValue)"
        }
    }
    
    public static func fromID(_ id: String) -> BodyPart? {
            if id.starts(with: "front.") {
                let key = id.replacingOccurrences(of: "front.", with: "")
                return BodyPart.Front(rawValue: key).map { .front($0) }
            } else if id.starts(with: "back.") {
                let key = id.replacingOccurrences(of: "back.", with: "")
                return BodyPart.Back(rawValue: key).map { .back($0) }
            } else {
                return nil
            }
        }

    /// frontHierarchy describes the front body as a dictionary of parent-children relationships
    public static let frontHierarchy: [BodyPart: [BodyPart]] = [
        .front(.head): [.front(.scalp), .front(.face), .front(.throat)],
        .front(.upperBody): [.front(.torso), .front(.rightArmPit), .front(.leftArmPit), .front(.pelvisFront)],
        .front(.leftArm): [.front(.leftUpperArm), .front(.leftArmFold), .front(.leftUnderArm), .front(.leftPalm)],
        .front(.rightArm): [.front(.rightUpperArm), .front(.rightArmFold), .front(.rightUnderArm), .front(.rightPalm)],
        .front(.leftLeg): [.front(.leftThigh), .front(.leftKnee), .front(.leftCalf), .front(.leftFoot)],
        .front(.rightLeg): [.front(.rightThigh), .front(.rightKnee), .front(.rightCalf), .front(.rightFoot)],
    ]

    public static let neutralFront: [BodyPart] = [
        BodyPart.front(.head),
        BodyPart.front(.throat),
        BodyPart.front(.leftArm),
        BodyPart.front(.leftPalm),
        BodyPart.front(.rightArm),
        BodyPart.front(.rightPalm),
        BodyPart.front(.upperBody),
        BodyPart.front(.pelvisFront),
        BodyPart.front(.leftLeg),
        BodyPart.front(.leftFoot),
        BodyPart.front(.rightLeg),
        BodyPart.front(.rightFoot)
    ]

    /// backHierarchy describes the back body as a dictionary of parent-children relationships
    public static let backHierarchy: [BodyPart: [BodyPart]] = [
        .back(.head): [.back(.scalp), .back(.backOfHead), .back(.neck)],
        .back(.back): [.back(.torso), .back(.rightArmPit), .back(.leftArmPit), .back(.pelvisBack)],
        .back(.leftArm): [.back(.leftUpperArm), .back(.leftArmElbow), .back(.leftUnderArm), .back(.leftBackOfHand)],
        .back(.rightArm): [.back(.rightUpperArm), .back(.rightArmElbow), .back(.rightUnderArm), .back(.rightBackOfHand)],
        .back(.leftLeg): [.back(.leftThigh), .back(.leftHollowOfKnee), .back(.leftCalf), .back(.leftFoot)],
        .back(.rightLeg): [.back(.rightThigh), .back(.rightHollowOfKnee), .back(.rightCalf), .back(.rightFoot)],
    ]

    public static let neutralBack: [BodyPart] = [
        BodyPart.back(.head),
        BodyPart.back(.neck),
        BodyPart.back(.leftArm),
        BodyPart.back(.leftBackOfHand),
        BodyPart.back(.rightArm),
        BodyPart.back(.rightBackOfHand),
        BodyPart.back(.torso),
        BodyPart.back(.pelvisBack),
        BodyPart.back(.leftLeg),
        BodyPart.back(.leftFoot),
        BodyPart.back(.rightLeg),
        BodyPart.back(.rightFoot),
    ]

    public enum BodySide: String {
        case left = "side.left"
        case right = "side.right"
        case notApplicable
    }

    /// returns a side for body parts that need to distinguish between sides (left & right), for example legs & arms
    public var side: BodySide { //TODO: Behöver lägga till alla
        switch self {
            case .front(.leftArm), .front(.leftLeg), .back(.leftArm), .back(.leftLeg), .front(.leftArmPit), .back(.leftArmPit):
                return .left
            case .front(.rightArm), .front(.rightLeg), .back(.rightArm), .back(.rightLeg), .front(.rightArmPit), .back(.rightArmPit):
                return .right
            default:
                return .notApplicable
        }
    }

    /// used for sorting when drawing, to avoid overlapping body parts
    public var drawOrder: Int {
        switch self {
            case .front(.head),
                    .front(.face),
                    .front(.throat),
                    .front(.torso),
                    .front(.upperBody),
                    .front(.pelvisFront),
                    .front(.leftLeg),
                    .front(.rightLeg),
                    .front(.leftArm),
                    .front(.rightArm): return 0

            case .front(.leftPalm),
                    .front(.rightPalm): return 2

            case .front(.scalp): return 3

            case .back(.head),
                    .back(.backOfHead),
                    .back(.neck),
                    .back(.torso),
                    .back(.back),
                    .back(.pelvisBack),
                    .back(.leftLeg),
                    .back(.rightLeg),
                    .back(.leftArm),
                    .back(.rightArm): return 0

            case .back(.leftBackOfHand),
                    .back(.rightBackOfHand): return 2

            case .back(.scalp): return 3

            default: return 10
        }
    }

    /// Returns the proper UIBezierPath for the current bodyPart
    public var path: UIBezierPath {
        switch self {
            case .back(let back):
                return back.path
            case .front(let front):
                return front.path
        }
    }

    public enum Back: String, CaseIterable, Sendable, Equatable {
        case head = "head",
             neck = "neck",
             backOfHead = "of_head",
             scalp = "scalp"

        case torso = "torso",
             back = "back",
             pelvisBack = "pelvis",
             rightArmPit = "right_armpit",
             leftArmPit = "left_armpit"

        case leftArm = "left_arm",
             leftUpperArm = "left_upper_arm",
             leftArmElbow = "left_arm_elbow",
             leftUnderArm = "left_under_arm",
             leftBackOfHand = "left_back_of_hand"

        case rightArm = "right_arm",
             rightUpperArm = "right_upper_arm",
             rightArmElbow = "right_arm_elbow",
             rightUnderArm = "right_under_arm",
             rightBackOfHand = "right_back_of_hand"

        case leftLeg = "left_leg",
             leftThigh = "left_thigh",
             leftHollowOfKnee = "left_hollow_of_knee",
             leftCalf = "left_calf",
             leftFoot = "left_foot"

        case rightLeg = "right_leg",
             rightThigh = "right_thigh",
             rightHollowOfKnee = "right_hollow_of_knee",
             rightCalf = "right_calf",
             rightFoot = "right_foot"

        var path: UIBezierPath {
            switch self {
                case .rightFoot:
                    let rightFootPath = UIBezierPath()
                    rightFootPath.move(to: CGPoint(x: 128.84, y: 609.52))
                    rightFootPath.addCurve(to: CGPoint(x: 128.84, y: 630.38), controlPoint1: CGPoint(x: 129.01, y: 614.48), controlPoint2: CGPoint(x: 127.62, y: 624.75))
                    rightFootPath.addCurve(to: CGPoint(x: 137.62, y: 637.6), controlPoint1: CGPoint(x: 129.38, y: 632.81), controlPoint2: CGPoint(x: 131.62, y: 637.12))
                    rightFootPath.addCurve(to: CGPoint(x: 145.94, y: 636.62), controlPoint1: CGPoint(x: 140.22, y: 637.81), controlPoint2: CGPoint(x: 142.62, y: 638.58))
                    rightFootPath.addCurve(to: CGPoint(x: 152.88, y: 618.48), controlPoint1: CGPoint(x: 149.41, y: 634.56), controlPoint2: CGPoint(x: 153.07, y: 620.38))
                    rightFootPath.addCurve(to: CGPoint(x: 148.88, y: 611.84), controlPoint1: CGPoint(x: 152.68, y: 616.58), controlPoint2: CGPoint(x: 149.22, y: 613.73))
                    rightFootPath.addLine(to: CGPoint(x: 148.46, y: 609.51))
                    rightFootPath.addCurve(to: CGPoint(x: 128.84, y: 609.51), controlPoint1: CGPoint(x: 138.78, y: 614.11), controlPoint2: CGPoint(x: 128.84, y: 609.51))
                    rightFootPath.addLine(to: CGPoint(x: 128.84, y: 609.52))
                    rightFootPath.close()
                    return rightFootPath.reversing()

                case .rightCalf:
                    let rightCalfPath = UIBezierPath()
                    rightCalfPath.move(to: CGPoint(x: 166.12, y: 486.91))
                    rightCalfPath.addCurve(to: CGPoint(x: 166.02, y: 485.84), controlPoint1: CGPoint(x: 166.09, y: 486.54), controlPoint2: CGPoint(x: 166.05, y: 486.19))
                    rightCalfPath.addCurve(to: CGPoint(x: 127.42, y: 487.4), controlPoint1: CGPoint(x: 158.48, y: 484.17), controlPoint2: CGPoint(x: 134.99, y: 485.86))
                    rightCalfPath.addCurve(to: CGPoint(x: 128.84, y: 609.52), controlPoint1: CGPoint(x: 126.73, y: 519.24), controlPoint2: CGPoint(x: 128.11, y: 589.1))
                    rightCalfPath.addCurve(to: CGPoint(x: 148.45, y: 609.52), controlPoint1: CGPoint(x: 128.84, y: 609.52), controlPoint2: CGPoint(x: 138, y: 615.03))
                    rightCalfPath.addCurve(to: CGPoint(x: 148.2, y: 608.31), controlPoint1: CGPoint(x: 148.45, y: 609.52), controlPoint2: CGPoint(x: 148.3, y: 608.72))
                    rightCalfPath.addCurve(to: CGPoint(x: 147.07, y: 601.93), controlPoint1: CGPoint(x: 147.69, y: 606.25), controlPoint2: CGPoint(x: 147.31, y: 604.12))
                    rightCalfPath.addCurve(to: CGPoint(x: 167.18, y: 512.67), controlPoint1: CGPoint(x: 147.51, y: 582.73), controlPoint2: CGPoint(x: 166.26, y: 530.65))
                    rightCalfPath.addCurve(to: CGPoint(x: 166.08, y: 486.84), controlPoint1: CGPoint(x: 167.77, y: 508.99), controlPoint2: CGPoint(x: 166.28, y: 487.27))
                    rightCalfPath.addCurve(to: CGPoint(x: 166.13, y: 486.92), controlPoint1: CGPoint(x: 166.09, y: 486.87), controlPoint2: CGPoint(x: 166.11, y: 486.89))
                    rightCalfPath.addLine(to: CGPoint(x: 166.12, y: 486.91))
                    rightCalfPath.close()
                    return rightCalfPath.reversing()

                case .rightHollowOfKnee:
                    let rightKneePath = UIBezierPath()
                    rightKneePath.move(to: CGPoint(x: 166.91, y: 451.06))
                    rightKneePath.addCurve(to: CGPoint(x: 127.84, y: 450.26), controlPoint1: CGPoint(x: 155.77, y: 456.32), controlPoint2: CGPoint(x: 138.64, y: 455.82))
                    rightKneePath.addCurve(to: CGPoint(x: 127.99, y: 474.49), controlPoint1: CGPoint(x: 127.84, y: 450.26), controlPoint2: CGPoint(x: 128.51, y: 469.23))
                    rightKneePath.addLine(to: CGPoint(x: 127.41, y: 487.38))
                    rightKneePath.addCurve(to: CGPoint(x: 166.01, y: 485.82), controlPoint1: CGPoint(x: 134.99, y: 485.85), controlPoint2: CGPoint(x: 158.47, y: 484.15))
                    rightKneePath.addCurve(to: CGPoint(x: 164.21, y: 468.43), controlPoint1: CGPoint(x: 165.13, y: 476.92), controlPoint2: CGPoint(x: 164, y: 470.88))
                    rightKneePath.addLine(to: CGPoint(x: 166.9, y: 451.05))
                    rightKneePath.addLine(to: CGPoint(x: 166.91, y: 451.06))
                    rightKneePath.close()
                    return rightKneePath.reversing()

                case .rightThigh:
                    let rightThighPath = UIBezierPath()
                    rightThighPath.move(to: CGPoint(x: 180.37, y: 329.35))
                    rightThighPath.addCurve(to: CGPoint(x: 123.08, y: 348.8), controlPoint1: CGPoint(x: 175.01, y: 347.12), controlPoint2: CGPoint(x: 123.08, y: 348.8))
                    rightThighPath.addCurve(to: CGPoint(x: 127.85, y: 450.26), controlPoint1: CGPoint(x: 124.69, y: 367.62), controlPoint2: CGPoint(x: 127.83, y: 449.89))
                    rightThighPath.addCurve(to: CGPoint(x: 166.93, y: 451.06), controlPoint1: CGPoint(x: 138.64, y: 455.81), controlPoint2: CGPoint(x: 155.78, y: 456.32))
                    rightThighPath.addCurve(to: CGPoint(x: 176.62, y: 398.47), controlPoint1: CGPoint(x: 166.94, y: 450.96), controlPoint2: CGPoint(x: 174.07, y: 408.81))
                    rightThighPath.addCurve(to: CGPoint(x: 180.38, y: 329.35), controlPoint1: CGPoint(x: 179.44, y: 387.02), controlPoint2: CGPoint(x: 182.77, y: 321.39))
                    rightThighPath.addLine(to: CGPoint(x: 180.37, y: 329.35))
                    rightThighPath.close()
                    return rightThighPath.reversing()

                case .rightLeg:
                    let rightLegPath = UIBezierPath()
                    rightLegPath.move(to: CGPoint(x: 128, y: 474.99))
                    rightLegPath.addCurve(to: CGPoint(x: 127.83, y: 450.17), controlPoint1: CGPoint(x: 128.52, y: 469.71), controlPoint2: CGPoint(x: 127.83, y: 450.17))
                    rightLegPath.addCurve(to: CGPoint(x: 127.78, y: 450.13), controlPoint1: CGPoint(x: 127.81, y: 450.16), controlPoint2: CGPoint(x: 127.8, y: 450.15))
                    rightLegPath.addCurve(to: CGPoint(x: 123.08, y: 349.29), controlPoint1: CGPoint(x: 127.78, y: 450.13), controlPoint2: CGPoint(x: 124.69, y: 368.11))
                    rightLegPath.addCurve(to: CGPoint(x: 180.37, y: 329.84), controlPoint1: CGPoint(x: 123.08, y: 349.29), controlPoint2: CGPoint(x: 175.02, y: 347.61))
                    rightLegPath.addCurve(to: CGPoint(x: 176.6, y: 398.96), controlPoint1: CGPoint(x: 182.75, y: 321.88), controlPoint2: CGPoint(x: 179.43, y: 387.52))
                    rightLegPath.addCurve(to: CGPoint(x: 167, y: 451.21), controlPoint1: CGPoint(x: 174.06, y: 409.3), controlPoint2: CGPoint(x: 167, y: 451.21))
                    rightLegPath.addCurve(to: CGPoint(x: 166.96, y: 451.24), controlPoint1: CGPoint(x: 167, y: 451.22), controlPoint2: CGPoint(x: 166.97, y: 451.23))
                    rightLegPath.addCurve(to: CGPoint(x: 164.22, y: 468.93), controlPoint1: CGPoint(x: 165.34, y: 461.17), controlPoint2: CGPoint(x: 164.44, y: 466.38))
                    rightLegPath.addCurve(to: CGPoint(x: 166.12, y: 487.4), controlPoint1: CGPoint(x: 164.01, y: 471.48), controlPoint2: CGPoint(x: 165.24, y: 477.9))
                    rightLegPath.addCurve(to: CGPoint(x: 166.07, y: 487.32), controlPoint1: CGPoint(x: 166.12, y: 487.37), controlPoint2: CGPoint(x: 166.09, y: 487.35))
                    rightLegPath.addCurve(to: CGPoint(x: 167.18, y: 513.15), controlPoint1: CGPoint(x: 166.27, y: 487.75), controlPoint2: CGPoint(x: 167.76, y: 509.47))
                    rightLegPath.addCurve(to: CGPoint(x: 147.06, y: 602.41), controlPoint1: CGPoint(x: 166.25, y: 531.13), controlPoint2: CGPoint(x: 147.5, y: 583.21))
                    rightLegPath.addCurve(to: CGPoint(x: 148.19, y: 608.79), controlPoint1: CGPoint(x: 147.31, y: 604.61), controlPoint2: CGPoint(x: 147.69, y: 606.74))
                    rightLegPath.addCurve(to: CGPoint(x: 148.44, y: 610), controlPoint1: CGPoint(x: 148.29, y: 609.2), controlPoint2: CGPoint(x: 148.44, y: 610))
                    rightLegPath.addCurve(to: CGPoint(x: 128.83, y: 610), controlPoint1: CGPoint(x: 138, y: 615.51), controlPoint2: CGPoint(x: 128.83, y: 610))
                    rightLegPath.addCurve(to: CGPoint(x: 128, y: 474.98), controlPoint1: CGPoint(x: 127.97, y: 585.94), controlPoint2: CGPoint(x: 126.2, y: 493.29))
                    rightLegPath.addLine(to: CGPoint(x: 128, y: 474.99))
                    rightLegPath.close()
                    return rightLegPath.reversing()

                case .leftFoot:
                    let leftFootPath = UIBezierPath()
                    leftFootPath.move(to: CGPoint(x: 93.9, y: 609.52))
                    leftFootPath.addLine(to: CGPoint(x: 93.47, y: 611.85))
                    leftFootPath.addCurve(to: CGPoint(x: 89.48, y: 618.49), controlPoint1: CGPoint(x: 93.13, y: 613.74), controlPoint2: CGPoint(x: 89.68, y: 616.6))
                    leftFootPath.addCurve(to: CGPoint(x: 96.42, y: 636.63), controlPoint1: CGPoint(x: 89.28, y: 620.38), controlPoint2: CGPoint(x: 92.93, y: 634.56))
                    leftFootPath.addCurve(to: CGPoint(x: 104.74, y: 637.61), controlPoint1: CGPoint(x: 99.72, y: 638.59), controlPoint2: CGPoint(x: 102.13, y: 637.82))
                    leftFootPath.addCurve(to: CGPoint(x: 113.51, y: 630.39), controlPoint1: CGPoint(x: 110.73, y: 637.12), controlPoint2: CGPoint(x: 112.98, y: 632.82))
                    leftFootPath.addCurve(to: CGPoint(x: 113.52, y: 609.53), controlPoint1: CGPoint(x: 114.73, y: 624.76), controlPoint2: CGPoint(x: 113.34, y: 614.49))
                    leftFootPath.addCurve(to: CGPoint(x: 93.91, y: 609.53), controlPoint1: CGPoint(x: 113.52, y: 609.53), controlPoint2: CGPoint(x: 103.58, y: 614.13))
                    leftFootPath.addLine(to: CGPoint(x: 93.9, y: 609.52))
                    leftFootPath.close()
                    return leftFootPath

                case .leftLeg:
                    let leftLegPath = UIBezierPath()
                    leftLegPath.move(to: CGPoint(x: 114.39, y: 474.99))
                    leftLegPath.addCurve(to: CGPoint(x: 114.56, y: 450.17), controlPoint1: CGPoint(x: 113.86, y: 469.71), controlPoint2: CGPoint(x: 114.56, y: 450.17))
                    leftLegPath.addCurve(to: CGPoint(x: 114.61, y: 450.13), controlPoint1: CGPoint(x: 114.58, y: 450.16), controlPoint2: CGPoint(x: 114.58, y: 450.15))
                    leftLegPath.addCurve(to: CGPoint(x: 119.31, y: 349.29), controlPoint1: CGPoint(x: 114.61, y: 450.13), controlPoint2: CGPoint(x: 117.69, y: 368.11))
                    leftLegPath.addCurve(to: CGPoint(x: 62.03, y: 329.84), controlPoint1: CGPoint(x: 119.31, y: 349.29), controlPoint2: CGPoint(x: 67.37, y: 347.61))
                    leftLegPath.addCurve(to: CGPoint(x: 65.79, y: 398.96), controlPoint1: CGPoint(x: 59.64, y: 321.88), controlPoint2: CGPoint(x: 62.97, y: 387.52))
                    leftLegPath.addCurve(to: CGPoint(x: 75.39, y: 451.21), controlPoint1: CGPoint(x: 68.33, y: 409.3), controlPoint2: CGPoint(x: 75.39, y: 451.21))
                    leftLegPath.addCurve(to: CGPoint(x: 75.43, y: 451.24), controlPoint1: CGPoint(x: 75.4, y: 451.22), controlPoint2: CGPoint(x: 75.42, y: 451.23))
                    leftLegPath.addCurve(to: CGPoint(x: 78.17, y: 468.93), controlPoint1: CGPoint(x: 77.05, y: 461.17), controlPoint2: CGPoint(x: 77.96, y: 466.38))
                    leftLegPath.addCurve(to: CGPoint(x: 76.27, y: 487.4), controlPoint1: CGPoint(x: 78.38, y: 471.48), controlPoint2: CGPoint(x: 77.16, y: 477.9))
                    leftLegPath.addCurve(to: CGPoint(x: 76.32, y: 487.32), controlPoint1: CGPoint(x: 76.28, y: 487.37), controlPoint2: CGPoint(x: 76.3, y: 487.35))
                    leftLegPath.addCurve(to: CGPoint(x: 75.22, y: 513.15), controlPoint1: CGPoint(x: 76.12, y: 487.75), controlPoint2: CGPoint(x: 74.63, y: 509.47))
                    leftLegPath.addCurve(to: CGPoint(x: 95.33, y: 602.41), controlPoint1: CGPoint(x: 76.14, y: 531.13), controlPoint2: CGPoint(x: 94.89, y: 583.21))
                    leftLegPath.addCurve(to: CGPoint(x: 94.2, y: 608.79), controlPoint1: CGPoint(x: 95.08, y: 604.61), controlPoint2: CGPoint(x: 94.71, y: 606.74))
                    leftLegPath.addCurve(to: CGPoint(x: 93.95, y: 610), controlPoint1: CGPoint(x: 94.1, y: 609.2), controlPoint2: CGPoint(x: 93.95, y: 610))
                    leftLegPath.addCurve(to: CGPoint(x: 113.56, y: 610), controlPoint1: CGPoint(x: 104.39, y: 615.51), controlPoint2: CGPoint(x: 113.56, y: 610))
                    leftLegPath.addCurve(to: CGPoint(x: 114.39, y: 474.98), controlPoint1: CGPoint(x: 114.42, y: 585.94), controlPoint2: CGPoint(x: 116.19, y: 493.29))
                    leftLegPath.addLine(to: CGPoint(x: 114.39, y: 474.99))
                    leftLegPath.close()
                    return leftLegPath.reversing()


                case .leftCalf:
                    let leftCalfPath = UIBezierPath()
                    leftCalfPath.move(to: CGPoint(x: 76.15, y: 486.91))
                    leftCalfPath.addCurve(to: CGPoint(x: 76.25, y: 485.84), controlPoint1: CGPoint(x: 76.18, y: 486.54), controlPoint2: CGPoint(x: 76.22, y: 486.19))
                    leftCalfPath.addCurve(to: CGPoint(x: 114.84, y: 487.4), controlPoint1: CGPoint(x: 83.79, y: 484.17), controlPoint2: CGPoint(x: 107.28, y: 485.86))
                    leftCalfPath.addCurve(to: CGPoint(x: 113.42, y: 609.52), controlPoint1: CGPoint(x: 115.53, y: 519.24), controlPoint2: CGPoint(x: 114.16, y: 589.1))
                    leftCalfPath.addCurve(to: CGPoint(x: 93.82, y: 609.52), controlPoint1: CGPoint(x: 113.42, y: 609.52), controlPoint2: CGPoint(x: 104.27, y: 615.03))
                    leftCalfPath.addCurve(to: CGPoint(x: 94.07, y: 608.31), controlPoint1: CGPoint(x: 93.82, y: 609.52), controlPoint2: CGPoint(x: 93.97, y: 608.72))
                    leftCalfPath.addCurve(to: CGPoint(x: 95.2, y: 601.93), controlPoint1: CGPoint(x: 94.58, y: 606.25), controlPoint2: CGPoint(x: 94.96, y: 604.12))
                    leftCalfPath.addCurve(to: CGPoint(x: 75.09, y: 512.67), controlPoint1: CGPoint(x: 94.76, y: 582.73), controlPoint2: CGPoint(x: 76.01, y: 530.65))
                    leftCalfPath.addCurve(to: CGPoint(x: 76.19, y: 486.84), controlPoint1: CGPoint(x: 74.5, y: 508.99), controlPoint2: CGPoint(x: 75.99, y: 487.27))
                    leftCalfPath.addCurve(to: CGPoint(x: 76.14, y: 486.92), controlPoint1: CGPoint(x: 76.18, y: 486.87), controlPoint2: CGPoint(x: 76.16, y: 486.89))
                    leftCalfPath.addLine(to: CGPoint(x: 76.15, y: 486.91))
                    leftCalfPath.close()
                    return leftCalfPath

                case .leftHollowOfKnee:
                    let leftKneePath = UIBezierPath()
                    leftKneePath.move(to: CGPoint(x: 75.35, y: 451.06))
                    leftKneePath.addCurve(to: CGPoint(x: 114.42, y: 450.26), controlPoint1: CGPoint(x: 86.49, y: 456.32), controlPoint2: CGPoint(x: 103.62, y: 455.82))
                    leftKneePath.addCurve(to: CGPoint(x: 114.27, y: 474.49), controlPoint1: CGPoint(x: 114.42, y: 450.26), controlPoint2: CGPoint(x: 113.75, y: 469.23))
                    leftKneePath.addLine(to: CGPoint(x: 114.85, y: 487.38))
                    leftKneePath.addCurve(to: CGPoint(x: 76.25, y: 485.82), controlPoint1: CGPoint(x: 107.28, y: 485.85), controlPoint2: CGPoint(x: 83.79, y: 484.15))
                    leftKneePath.addCurve(to: CGPoint(x: 78.05, y: 468.43), controlPoint1: CGPoint(x: 77.13, y: 476.92), controlPoint2: CGPoint(x: 78.26, y: 470.88))
                    leftKneePath.addLine(to: CGPoint(x: 75.36, y: 451.05))
                    leftKneePath.addLine(to: CGPoint(x: 75.35, y: 451.06))
                    leftKneePath.close()
                    return leftKneePath

                case .leftThigh:
                    let leftThighPath = UIBezierPath()
                    leftThighPath.move(to: CGPoint(x: 61.91, y: 329.35))
                    leftThighPath.addCurve(to: CGPoint(x: 119.19, y: 348.8), controlPoint1: CGPoint(x: 67.26, y: 347.12), controlPoint2: CGPoint(x: 119.19, y: 348.8))
                    leftThighPath.addCurve(to: CGPoint(x: 114.41, y: 450.26), controlPoint1: CGPoint(x: 117.57, y: 367.62), controlPoint2: CGPoint(x: 114.44, y: 449.89))
                    leftThighPath.addCurve(to: CGPoint(x: 75.35, y: 451.06), controlPoint1: CGPoint(x: 103.62, y: 455.81), controlPoint2: CGPoint(x: 86.49, y: 456.32))
                    leftThighPath.addCurve(to: CGPoint(x: 65.65, y: 398.47), controlPoint1: CGPoint(x: 75.33, y: 450.96), controlPoint2: CGPoint(x: 68.2, y: 408.81))
                    leftThighPath.addCurve(to: CGPoint(x: 61.89, y: 329.35), controlPoint1: CGPoint(x: 62.84, y: 387.02), controlPoint2: CGPoint(x: 59.5, y: 321.39))
                    leftThighPath.addLine(to: CGPoint(x: 61.91, y: 329.35))
                    leftThighPath.close()
                    return leftThighPath

                case .leftArm:
                    let leftArmPath = UIBezierPath()
                    leftArmPath.move(to: CGPoint(x: 56.55, y: 127.41))
                    leftArmPath.addCurve(to: CGPoint(x: 41.15, y: 166.47), controlPoint1: CGPoint(x: 52.02, y: 131.6), controlPoint2: CGPoint(x: 44.16, y: 144.31))
                    leftArmPath.addCurve(to: CGPoint(x: 37.02, y: 210.41), controlPoint1: CGPoint(x: 38.15, y: 188.63), controlPoint2: CGPoint(x: 37.39, y: 208.15))
                    leftArmPath.addCurve(to: CGPoint(x: 34.02, y: 229.94), controlPoint1: CGPoint(x: 36.64, y: 212.66), controlPoint2: CGPoint(x: 34.02, y: 229.94))
                    leftArmPath.addLine(to: CGPoint(x: 33.97, y: 230.02))
                    leftArmPath.addLine(to: CGPoint(x: 30.34, y: 254.42))
                    leftArmPath.addCurve(to: CGPoint(x: 30.53, y: 253.88), controlPoint1: CGPoint(x: 30.36, y: 254.23), controlPoint2: CGPoint(x: 30.43, y: 254.05))
                    leftArmPath.addCurve(to: CGPoint(x: 30.39, y: 254.34), controlPoint1: CGPoint(x: 30.46, y: 254.03), controlPoint2: CGPoint(x: 30.41, y: 254.18))
                    leftArmPath.addCurve(to: CGPoint(x: 21.56, y: 308.37), controlPoint1: CGPoint(x: 27.78, y: 274.25), controlPoint2: CGPoint(x: 21.56, y: 308.37))
                    leftArmPath.addCurve(to: CGPoint(x: 42.51, y: 308.37), controlPoint1: CGPoint(x: 33.15, y: 303.09), controlPoint2: CGPoint(x: 42.51, y: 308.37))
                    leftArmPath.addCurve(to: CGPoint(x: 59.93, y: 254.73), controlPoint1: CGPoint(x: 45.22, y: 298.03), controlPoint2: CGPoint(x: 58.73, y: 261.92))
                    leftArmPath.addCurve(to: CGPoint(x: 59.88, y: 254.59), controlPoint1: CGPoint(x: 59.93, y: 254.69), controlPoint2: CGPoint(x: 59.91, y: 254.64))
                    leftArmPath.addCurve(to: CGPoint(x: 63.73, y: 231.57), controlPoint1: CGPoint(x: 60.41, y: 251.44), controlPoint2: CGPoint(x: 61.96, y: 242.24))
                    leftArmPath.addCurve(to: CGPoint(x: 63.87, y: 231.14), controlPoint1: CGPoint(x: 63.8, y: 231.43), controlPoint2: CGPoint(x: 63.85, y: 231.29))
                    leftArmPath.addCurve(to: CGPoint(x: 67.44, y: 209.12), controlPoint1: CGPoint(x: 66.35, y: 216.22), controlPoint2: CGPoint(x: 67.44, y: 209.12))
                    leftArmPath.addLine(to: CGPoint(x: 71.24, y: 186.1))
                    leftArmPath.addCurve(to: CGPoint(x: 64.38, y: 152.14), controlPoint1: CGPoint(x: 69.99, y: 180.78), controlPoint2: CGPoint(x: 67.28, y: 163.67))
                    leftArmPath.addCurve(to: CGPoint(x: 56.54, y: 127.42), controlPoint1: CGPoint(x: 60.55, y: 136.94), controlPoint2: CGPoint(x: 56.54, y: 127.42))
                    leftArmPath.addLine(to: CGPoint(x: 56.55, y: 127.41))
                    leftArmPath.close()
                    return leftArmPath

                case .leftBackOfHand:
                    let leftHandPath = UIBezierPath()
                    leftHandPath.move(to: CGPoint(x: 21.57, y: 307.9))
                    leftHandPath.addCurve(to: CGPoint(x: 11.09, y: 320.39), controlPoint1: CGPoint(x: 21.57, y: 307.9), controlPoint2: CGPoint(x: 14.97, y: 316.85))
                    leftHandPath.addCurve(to: CGPoint(x: 5.75, y: 330.5), controlPoint1: CGPoint(x: 9.28, y: 322.55), controlPoint2: CGPoint(x: 7.75, y: 326.88))
                    leftHandPath.addCurve(to: CGPoint(x: 1.61, y: 342.14), controlPoint1: CGPoint(x: 2.42, y: 336.53), controlPoint2: CGPoint(x: 0.6, y: 340.69))
                    leftHandPath.addCurve(to: CGPoint(x: 11.55, y: 333.92), controlPoint1: CGPoint(x: 2.62, y: 343.59), controlPoint2: CGPoint(x: 8.92, y: 338.82))
                    leftHandPath.addCurve(to: CGPoint(x: 8.27, y: 357.08), controlPoint1: CGPoint(x: 12.2, y: 332.73), controlPoint2: CGPoint(x: 8.27, y: 357.08))
                    leftHandPath.addCurve(to: CGPoint(x: 9.73, y: 362.19), controlPoint1: CGPoint(x: 8.27, y: 357.08), controlPoint2: CGPoint(x: 7.83, y: 361.63))
                    leftHandPath.addCurve(to: CGPoint(x: 12.95, y: 358.74), controlPoint1: CGPoint(x: 11.62, y: 362.75), controlPoint2: CGPoint(x: 12.39, y: 361.07))
                    leftHandPath.addCurve(to: CGPoint(x: 17.71, y: 341), controlPoint1: CGPoint(x: 14.69, y: 351.35), controlPoint2: CGPoint(x: 16.59, y: 340.8))
                    leftHandPath.addCurve(to: CGPoint(x: 14.65, y: 361.39), controlPoint1: CGPoint(x: 18.82, y: 341.2), controlPoint2: CGPoint(x: 14.65, y: 361.39))
                    leftHandPath.addCurve(to: CGPoint(x: 15.96, y: 365.33), controlPoint1: CGPoint(x: 14.65, y: 361.39), controlPoint2: CGPoint(x: 13.81, y: 364.83))
                    leftHandPath.addCurve(to: CGPoint(x: 18.89, y: 361.83), controlPoint1: CGPoint(x: 18.11, y: 365.83), controlPoint2: CGPoint(x: 18.89, y: 361.83))
                    leftHandPath.addCurve(to: CGPoint(x: 24.32, y: 341.77), controlPoint1: CGPoint(x: 18.89, y: 361.83), controlPoint2: CGPoint(x: 23.32, y: 341.65))
                    leftHandPath.addCurve(to: CGPoint(x: 21.64, y: 361.46), controlPoint1: CGPoint(x: 25.07, y: 341.86), controlPoint2: CGPoint(x: 22.36, y: 355.96))
                    leftHandPath.addCurve(to: CGPoint(x: 22.77, y: 364.91), controlPoint1: CGPoint(x: 21.43, y: 363.16), controlPoint2: CGPoint(x: 21.11, y: 364.43))
                    leftHandPath.addCurve(to: CGPoint(x: 25.59, y: 361.96), controlPoint1: CGPoint(x: 24.3, y: 365.35), controlPoint2: CGPoint(x: 25.02, y: 363.58))
                    leftHandPath.addCurve(to: CGPoint(x: 31, y: 342.02), controlPoint1: CGPoint(x: 27.61, y: 356.3), controlPoint2: CGPoint(x: 30.11, y: 341.8))
                    leftHandPath.addCurve(to: CGPoint(x: 30, y: 356.3), controlPoint1: CGPoint(x: 31.84, y: 342.23), controlPoint2: CGPoint(x: 31, y: 350.58))
                    leftHandPath.addCurve(to: CGPoint(x: 31.16, y: 361.23), controlPoint1: CGPoint(x: 29.66, y: 358.29), controlPoint2: CGPoint(x: 28.64, y: 360.84))
                    leftHandPath.addCurve(to: CGPoint(x: 34.12, y: 356.51), controlPoint1: CGPoint(x: 33.51, y: 361.59), controlPoint2: CGPoint(x: 34.12, y: 356.51))
                    leftHandPath.addCurve(to: CGPoint(x: 38.2, y: 339.23), controlPoint1: CGPoint(x: 34.12, y: 356.51), controlPoint2: CGPoint(x: 37.83, y: 341.86))
                    leftHandPath.addCurve(to: CGPoint(x: 41.55, y: 313.93), controlPoint1: CGPoint(x: 38.58, y: 336.6), controlPoint2: CGPoint(x: 42.51, y: 325))
                    leftHandPath.addCurve(to: CGPoint(x: 42.51, y: 307.92), controlPoint1: CGPoint(x: 41.52, y: 313.6), controlPoint2: CGPoint(x: 42.09, y: 309.36))
                    leftHandPath.addCurve(to: CGPoint(x: 21.55, y: 307.92), controlPoint1: CGPoint(x: 42.51, y: 307.92), controlPoint2: CGPoint(x: 33.23, y: 302.64))
                    leftHandPath.addLine(to: CGPoint(x: 21.57, y: 307.9))
                    leftHandPath.close()
                    return leftHandPath

                case .leftUnderArm:
                    let leftUnderArmPath = UIBezierPath()
                    leftUnderArmPath.move(to: CGPoint(x: 59.73, y: 254.66))
                    leftUnderArmPath.addCurve(to: CGPoint(x: 30.5, y: 254.43), controlPoint1: CGPoint(x: 56.23, y: 252.92), controlPoint2: CGPoint(x: 36.99, y: 252.48))
                    leftUnderArmPath.addLine(to: CGPoint(x: 30.32, y: 254.48))
                    leftUnderArmPath.addCurve(to: CGPoint(x: 21.58, y: 307.85), controlPoint1: CGPoint(x: 27.66, y: 274.48), controlPoint2: CGPoint(x: 21.58, y: 307.85))
                    leftUnderArmPath.addCurve(to: CGPoint(x: 42.53, y: 307.85), controlPoint1: CGPoint(x: 33.17, y: 302.57), controlPoint2: CGPoint(x: 42.53, y: 307.85))
                    leftUnderArmPath.addCurve(to: CGPoint(x: 59.85, y: 254.72), controlPoint1: CGPoint(x: 45.18, y: 297.73), controlPoint2: CGPoint(x: 58.18, y: 262.92))
                    leftUnderArmPath.addLine(to: CGPoint(x: 59.73, y: 254.66))
                    leftUnderArmPath.close()
                    return leftUnderArmPath

                case .leftArmElbow:
                    let leftArmFoldPath = UIBezierPath()
                    leftArmFoldPath.move(to: CGPoint(x: 30.31, y: 254.48))
                    leftArmFoldPath.addCurve(to: CGPoint(x: 59.84, y: 254.72), controlPoint1: CGPoint(x: 36.62, y: 252.59), controlPoint2: CGPoint(x: 56.1, y: 252.86))
                    leftArmFoldPath.addCurve(to: CGPoint(x: 63.93, y: 230.33), controlPoint1: CGPoint(x: 60.65, y: 250.84), controlPoint2: CGPoint(x: 63.16, y: 234.93))
                    leftArmFoldPath.addCurve(to: CGPoint(x: 34.09, y: 229.02), controlPoint1: CGPoint(x: 59.36, y: 232.63), controlPoint2: CGPoint(x: 41.01, y: 233.92))
                    leftArmFoldPath.addLine(to: CGPoint(x: 30.31, y: 254.48))
                    leftArmFoldPath.close()
                    return leftArmFoldPath

                case .leftUpperArm:
                    let leftUpperArmPath = UIBezierPath()
                    leftUpperArmPath.move(to: CGPoint(x: 64.41, y: 151.63))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 56.57, y: 126.91), controlPoint1: CGPoint(x: 60.58, y: 136.43), controlPoint2: CGPoint(x: 56.57, y: 126.91))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 41.17, y: 165.97), controlPoint1: CGPoint(x: 52.04, y: 131.1), controlPoint2: CGPoint(x: 44.18, y: 143.81))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 37.04, y: 209.91), controlPoint1: CGPoint(x: 38.17, y: 188.13), controlPoint2: CGPoint(x: 37.41, y: 207.65))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 34.1, y: 229.03), controlPoint1: CGPoint(x: 36.7, y: 211.96), controlPoint2: CGPoint(x: 34.5, y: 226.42))
                    leftUpperArmPath.addLine(to: CGPoint(x: 34.27, y: 229.15))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 63.61, y: 230.5), controlPoint1: CGPoint(x: 41.12, y: 234), controlPoint2: CGPoint(x: 59.25, y: 232.7))
                    leftUpperArmPath.addLine(to: CGPoint(x: 63.94, y: 230.34))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 67.47, y: 208.61), controlPoint1: CGPoint(x: 66.38, y: 215.62), controlPoint2: CGPoint(x: 67.47, y: 208.61))
                    leftUpperArmPath.addLine(to: CGPoint(x: 71.27, y: 185.59))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 64.41, y: 151.63), controlPoint1: CGPoint(x: 70.02, y: 180.28), controlPoint2: CGPoint(x: 67.31, y: 163.16))
                    leftUpperArmPath.close()
                    return leftUpperArmPath

                case .rightBackOfHand:
                    let rightHandPath = UIBezierPath()
                    rightHandPath.move(to: CGPoint(x: 220.43, y: 307.87))
                    rightHandPath.addCurve(to: CGPoint(x: 230.91, y: 320.36), controlPoint1: CGPoint(x: 220.43, y: 307.87), controlPoint2: CGPoint(x: 227.03, y: 316.82))
                    rightHandPath.addCurve(to: CGPoint(x: 236.25, y: 330.47), controlPoint1: CGPoint(x: 232.72, y: 322.52), controlPoint2: CGPoint(x: 234.25, y: 326.85))
                    rightHandPath.addCurve(to: CGPoint(x: 240.4, y: 342.11), controlPoint1: CGPoint(x: 239.59, y: 336.5), controlPoint2: CGPoint(x: 241.41, y: 340.66))
                    rightHandPath.addCurve(to: CGPoint(x: 230.44, y: 333.89), controlPoint1: CGPoint(x: 239.38, y: 343.56), controlPoint2: CGPoint(x: 233.09, y: 338.79))
                    rightHandPath.addCurve(to: CGPoint(x: 233.74, y: 357.05), controlPoint1: CGPoint(x: 229.81, y: 332.7), controlPoint2: CGPoint(x: 233.74, y: 357.05))
                    rightHandPath.addCurve(to: CGPoint(x: 232.28, y: 362.16), controlPoint1: CGPoint(x: 233.74, y: 357.05), controlPoint2: CGPoint(x: 234.18, y: 361.6))
                    rightHandPath.addCurve(to: CGPoint(x: 229.06, y: 358.71), controlPoint1: CGPoint(x: 230.38, y: 362.72), controlPoint2: CGPoint(x: 229.6, y: 361.04))
                    rightHandPath.addCurve(to: CGPoint(x: 224.28, y: 340.97), controlPoint1: CGPoint(x: 227.31, y: 351.32), controlPoint2: CGPoint(x: 225.41, y: 340.77))
                    rightHandPath.addCurve(to: CGPoint(x: 227.34, y: 361.36), controlPoint1: CGPoint(x: 223.18, y: 341.17), controlPoint2: CGPoint(x: 227.34, y: 361.36))
                    rightHandPath.addCurve(to: CGPoint(x: 226.03, y: 365.3), controlPoint1: CGPoint(x: 227.34, y: 361.36), controlPoint2: CGPoint(x: 228.19, y: 364.8))
                    rightHandPath.addCurve(to: CGPoint(x: 223.12, y: 361.8), controlPoint1: CGPoint(x: 223.88, y: 365.8), controlPoint2: CGPoint(x: 223.12, y: 361.8))
                    rightHandPath.addCurve(to: CGPoint(x: 217.69, y: 341.74), controlPoint1: CGPoint(x: 223.12, y: 361.8), controlPoint2: CGPoint(x: 218.69, y: 341.62))
                    rightHandPath.addCurve(to: CGPoint(x: 220.35, y: 361.43), controlPoint1: CGPoint(x: 216.93, y: 341.83), controlPoint2: CGPoint(x: 219.65, y: 355.93))
                    rightHandPath.addCurve(to: CGPoint(x: 219.24, y: 364.88), controlPoint1: CGPoint(x: 220.57, y: 363.13), controlPoint2: CGPoint(x: 220.9, y: 364.4))
                    rightHandPath.addCurve(to: CGPoint(x: 216.41, y: 361.93), controlPoint1: CGPoint(x: 217.69, y: 365.32), controlPoint2: CGPoint(x: 216.99, y: 363.55))
                    rightHandPath.addCurve(to: CGPoint(x: 211, y: 341.99), controlPoint1: CGPoint(x: 214.38, y: 356.27), controlPoint2: CGPoint(x: 211.88, y: 341.77))
                    rightHandPath.addCurve(to: CGPoint(x: 212, y: 356.27), controlPoint1: CGPoint(x: 210.16, y: 342.2), controlPoint2: CGPoint(x: 211, y: 350.55))
                    rightHandPath.addCurve(to: CGPoint(x: 210.84, y: 361.2), controlPoint1: CGPoint(x: 212.34, y: 358.26), controlPoint2: CGPoint(x: 213.37, y: 360.81))
                    rightHandPath.addCurve(to: CGPoint(x: 207.88, y: 356.48), controlPoint1: CGPoint(x: 208.5, y: 361.56), controlPoint2: CGPoint(x: 207.88, y: 356.48))
                    rightHandPath.addCurve(to: CGPoint(x: 203.81, y: 339.2), controlPoint1: CGPoint(x: 207.88, y: 356.48), controlPoint2: CGPoint(x: 204.18, y: 341.83))
                    rightHandPath.addCurve(to: CGPoint(x: 200.44, y: 313.9), controlPoint1: CGPoint(x: 203.43, y: 336.57), controlPoint2: CGPoint(x: 199.5, y: 324.97))
                    rightHandPath.addCurve(to: CGPoint(x: 199.5, y: 307.89), controlPoint1: CGPoint(x: 200.47, y: 313.57), controlPoint2: CGPoint(x: 199.91, y: 309.33))
                    rightHandPath.addCurve(to: CGPoint(x: 220.44, y: 307.89), controlPoint1: CGPoint(x: 199.5, y: 307.89), controlPoint2: CGPoint(x: 208.76, y: 302.61))
                    rightHandPath.addLine(to: CGPoint(x: 220.43, y: 307.87))
                    rightHandPath.close()
                    return rightHandPath.reversing()

                case .rightArm:
                    let rightArmPath = UIBezierPath()
                    rightArmPath.move(to: CGPoint(x: 185.43, y: 127.41))
                    rightArmPath.addCurve(to: CGPoint(x: 200.82, y: 166.47), controlPoint1: CGPoint(x: 189.96, y: 131.6), controlPoint2: CGPoint(x: 197.81, y: 144.31))
                    rightArmPath.addCurve(to: CGPoint(x: 204.96, y: 210.41), controlPoint1: CGPoint(x: 203.82, y: 188.63), controlPoint2: CGPoint(x: 204.59, y: 208.15))
                    rightArmPath.addCurve(to: CGPoint(x: 207.96, y: 229.94), controlPoint1: CGPoint(x: 205.34, y: 212.66), controlPoint2: CGPoint(x: 207.96, y: 229.94))
                    rightArmPath.addLine(to: CGPoint(x: 208, y: 230.02))
                    rightArmPath.addLine(to: CGPoint(x: 211.63, y: 254.42))
                    rightArmPath.addCurve(to: CGPoint(x: 211.44, y: 253.88), controlPoint1: CGPoint(x: 211.62, y: 254.23), controlPoint2: CGPoint(x: 211.54, y: 254.05))
                    rightArmPath.addCurve(to: CGPoint(x: 211.59, y: 254.34), controlPoint1: CGPoint(x: 211.51, y: 254.03), controlPoint2: CGPoint(x: 211.56, y: 254.18))
                    rightArmPath.addCurve(to: CGPoint(x: 220.41, y: 308.37), controlPoint1: CGPoint(x: 214.19, y: 274.25), controlPoint2: CGPoint(x: 220.41, y: 308.37))
                    rightArmPath.addCurve(to: CGPoint(x: 199.47, y: 308.37), controlPoint1: CGPoint(x: 208.82, y: 303.09), controlPoint2: CGPoint(x: 199.47, y: 308.37))
                    rightArmPath.addCurve(to: CGPoint(x: 182.04, y: 254.73), controlPoint1: CGPoint(x: 196.75, y: 298.03), controlPoint2: CGPoint(x: 183.25, y: 261.92))
                    rightArmPath.addCurve(to: CGPoint(x: 182.09, y: 254.59), controlPoint1: CGPoint(x: 182.04, y: 254.69), controlPoint2: CGPoint(x: 182.06, y: 254.64))
                    rightArmPath.addCurve(to: CGPoint(x: 178.25, y: 231.57), controlPoint1: CGPoint(x: 181.56, y: 251.44), controlPoint2: CGPoint(x: 180.01, y: 242.24))
                    rightArmPath.addCurve(to: CGPoint(x: 178.1, y: 231.14), controlPoint1: CGPoint(x: 178.18, y: 231.43), controlPoint2: CGPoint(x: 178.12, y: 231.29))
                    rightArmPath.addCurve(to: CGPoint(x: 174.53, y: 209.12), controlPoint1: CGPoint(x: 175.62, y: 216.22), controlPoint2: CGPoint(x: 174.53, y: 209.12))
                    rightArmPath.addLine(to: CGPoint(x: 170.74, y: 186.1))
                    rightArmPath.addCurve(to: CGPoint(x: 177.59, y: 152.14), controlPoint1: CGPoint(x: 171.99, y: 180.78), controlPoint2: CGPoint(x: 174.69, y: 163.67))
                    rightArmPath.addCurve(to: CGPoint(x: 185.44, y: 127.42), controlPoint1: CGPoint(x: 181.43, y: 136.94), controlPoint2: CGPoint(x: 185.44, y: 127.42))
                    rightArmPath.addLine(to: CGPoint(x: 185.43, y: 127.41))
                    rightArmPath.close()
                    return rightArmPath

                case .rightUpperArm:
                    let rightUpperArmPath = UIBezierPath()
                    rightUpperArmPath.move(to: CGPoint(x: 177.59, y: 151.65))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 185.43, y: 126.93), controlPoint1: CGPoint(x: 181.41, y: 136.45), controlPoint2: CGPoint(x: 185.43, y: 126.93))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 200.82, y: 165.99), controlPoint1: CGPoint(x: 189.96, y: 131.12), controlPoint2: CGPoint(x: 197.81, y: 143.83))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 204.96, y: 209.93), controlPoint1: CGPoint(x: 203.82, y: 188.15), controlPoint2: CGPoint(x: 204.59, y: 207.67))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 207.9, y: 229.05), controlPoint1: CGPoint(x: 205.29, y: 211.98), controlPoint2: CGPoint(x: 207.5, y: 226.44))
                    rightUpperArmPath.addLine(to: CGPoint(x: 207.72, y: 229.17))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 178.38, y: 230.52), controlPoint1: CGPoint(x: 200.88, y: 234.02), controlPoint2: CGPoint(x: 182.75, y: 232.72))
                    rightUpperArmPath.addLine(to: CGPoint(x: 178.06, y: 230.36))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 174.53, y: 208.63), controlPoint1: CGPoint(x: 175.62, y: 215.64), controlPoint2: CGPoint(x: 174.53, y: 208.63))
                    rightUpperArmPath.addLine(to: CGPoint(x: 170.72, y: 185.61))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 177.59, y: 151.65), controlPoint1: CGPoint(x: 171.97, y: 180.3), controlPoint2: CGPoint(x: 174.69, y: 163.18))
                    rightUpperArmPath.close()
                    return rightUpperArmPath

                case .rightArmElbow:
                    let rightArmFoldPath = UIBezierPath()
                    rightArmFoldPath.move(to: CGPoint(x: 211.68, y: 254.5))
                    rightArmFoldPath.addCurve(to: CGPoint(x: 182.15, y: 254.74), controlPoint1: CGPoint(x: 205.37, y: 252.61), controlPoint2: CGPoint(x: 185.88, y: 252.88))
                    rightArmFoldPath.addCurve(to: CGPoint(x: 178.06, y: 230.35), controlPoint1: CGPoint(x: 181.34, y: 250.86), controlPoint2: CGPoint(x: 178.82, y: 234.95))
                    rightArmFoldPath.addCurve(to: CGPoint(x: 207.9, y: 229.04), controlPoint1: CGPoint(x: 182.62, y: 232.65), controlPoint2: CGPoint(x: 200.97, y: 233.94))
                    rightArmFoldPath.addLine(to: CGPoint(x: 211.68, y: 254.5))
                    rightArmFoldPath.close()
                    return rightArmFoldPath

                case .rightUnderArm:
                    let rightUnderArmPath = UIBezierPath()
                    rightUnderArmPath.move(to: CGPoint(x: 182.26, y: 254.68))
                    rightUnderArmPath.addCurve(to: CGPoint(x: 211.5, y: 254.45), controlPoint1: CGPoint(x: 185.76, y: 252.94), controlPoint2: CGPoint(x: 205, y: 252.5))
                    rightUnderArmPath.addLine(to: CGPoint(x: 211.68, y: 254.5))
                    rightUnderArmPath.addCurve(to: CGPoint(x: 220.41, y: 307.87), controlPoint1: CGPoint(x: 214.34, y: 274.5), controlPoint2: CGPoint(x: 220.41, y: 307.87))
                    rightUnderArmPath.addCurve(to: CGPoint(x: 199.47, y: 307.87), controlPoint1: CGPoint(x: 208.82, y: 302.59), controlPoint2: CGPoint(x: 199.47, y: 307.87))
                    rightUnderArmPath.addCurve(to: CGPoint(x: 182.15, y: 254.74), controlPoint1: CGPoint(x: 196.81, y: 297.75), controlPoint2: CGPoint(x: 183.81, y: 262.94))
                    rightUnderArmPath.addLine(to: CGPoint(x: 182.26, y: 254.68))
                    rightUnderArmPath.close()
                    return rightUnderArmPath

                case .pelvisBack:
                    let pelvisPath = UIBezierPath()
                    pelvisPath.move(to: CGPoint(x: 67.97, y: 287.62))
                    pelvisPath.addCurve(to: CGPoint(x: 61.48, y: 328.61), controlPoint1: CGPoint(x: 64.94, y: 299.47), controlPoint2: CGPoint(x: 62.1, y: 316.43))
                    pelvisPath.addCurve(to: CGPoint(x: 119.25, y: 348.79), controlPoint1: CGPoint(x: 70.19, y: 348.3), controlPoint2: CGPoint(x: 119.25, y: 348.79))
                    pelvisPath.addCurve(to: CGPoint(x: 121.31, y: 329.67), controlPoint1: CGPoint(x: 119.25, y: 348.79), controlPoint2: CGPoint(x: 119.42, y: 330.8))
                    pelvisPath.addCurve(to: CGPoint(x: 123.09, y: 348.79), controlPoint1: CGPoint(x: 122.19, y: 330.2), controlPoint2: CGPoint(x: 123.09, y: 348.79))
                    pelvisPath.addCurve(to: CGPoint(x: 180.95, y: 329.01), controlPoint1: CGPoint(x: 123.09, y: 348.79), controlPoint2: CGPoint(x: 174.14, y: 348.31))
                    pelvisPath.addCurve(to: CGPoint(x: 174.63, y: 287.61), controlPoint1: CGPoint(x: 180.32, y: 316.83), controlPoint2: CGPoint(x: 177.65, y: 299.41))
                    pelvisPath.addLine(to: CGPoint(x: 172.5, y: 278.53))
                    pelvisPath.addCurve(to: CGPoint(x: 121.22, y: 291.69), controlPoint1: CGPoint(x: 172.5, y: 278.53), controlPoint2: CGPoint(x: 153.09, y: 291.69))
                    pelvisPath.addCurve(to: CGPoint(x: 69.58, y: 278.96), controlPoint1: CGPoint(x: 89.33, y: 291.69), controlPoint2: CGPoint(x: 69.58, y: 278.96))
                    pelvisPath.addLine(to: CGPoint(x: 67.98, y: 287.61))
                    pelvisPath.addLine(to: CGPoint(x: 67.97, y: 287.62))
                    pelvisPath.close()
                    return pelvisPath

                case .torso, .back:
                    let torsoPath = UIBezierPath()
                    torsoPath.move(to: CGPoint(x: 170.86, y: 186.26))
                    torsoPath.addCurve(to: CGPoint(x: 177.54, y: 151.63), controlPoint1: CGPoint(x: 172.28, y: 180.23), controlPoint2: CGPoint(x: 174.86, y: 165.11))
                    torsoPath.addLine(to: CGPoint(x: 185.13, y: 126.75))
                    torsoPath.addCurve(to: CGPoint(x: 144.5, y: 108.01), controlPoint1: CGPoint(x: 182.14, y: 124.56), controlPoint2: CGPoint(x: 173.93, y: 116.97))
                    torsoPath.addCurve(to: CGPoint(x: 120.75, y: 113.68), controlPoint1: CGPoint(x: 144.5, y: 108.01), controlPoint2: CGPoint(x: 137.61, y: 113.68))
                    torsoPath.addCurve(to: CGPoint(x: 97, y: 108.02), controlPoint1: CGPoint(x: 103.89, y: 113.68), controlPoint2: CGPoint(x: 97, y: 108.02))
                    torsoPath.addCurve(to: CGPoint(x: 56.37, y: 126.97), controlPoint1: CGPoint(x: 67.57, y: 116.97), controlPoint2: CGPoint(x: 59.36, y: 124.78))
                    torsoPath.addLine(to: CGPoint(x: 63.96, y: 151.63))
                    torsoPath.addCurve(to: CGPoint(x: 70.64, y: 186.26), controlPoint1: CGPoint(x: 66.64, y: 165.11), controlPoint2: CGPoint(x: 69.22, y: 180.23))
                    torsoPath.addCurve(to: CGPoint(x: 73.34, y: 207.69), controlPoint1: CGPoint(x: 70.86, y: 188.4), controlPoint2: CGPoint(x: 72.3, y: 199.14))
                    torsoPath.addCurve(to: CGPoint(x: 73.9, y: 218.2), controlPoint1: CGPoint(x: 73.68, y: 211.06), controlPoint2: CGPoint(x: 73.9, y: 214.44))
                    torsoPath.addCurve(to: CGPoint(x: 69.54, y: 278.97), controlPoint1: CGPoint(x: 73.9, y: 222.33), controlPoint2: CGPoint(x: 72.86, y: 262.06))
                    torsoPath.addCurve(to: CGPoint(x: 120.95, y: 291.79), controlPoint1: CGPoint(x: 69.54, y: 278.97), controlPoint2: CGPoint(x: 89.08, y: 291.79))
                    torsoPath.addCurve(to: CGPoint(x: 172.45, y: 278.54), controlPoint1: CGPoint(x: 152.83, y: 291.79), controlPoint2: CGPoint(x: 172.45, y: 278.54))
                    torsoPath.addCurve(to: CGPoint(x: 167.6, y: 218.2), controlPoint1: CGPoint(x: 169.2, y: 261.91), controlPoint2: CGPoint(x: 167.6, y: 222.34))
                    torsoPath.addCurve(to: CGPoint(x: 168.16, y: 207.69), controlPoint1: CGPoint(x: 167.6, y: 214.45), controlPoint2: CGPoint(x: 167.82, y: 211.06))
                    torsoPath.addCurve(to: CGPoint(x: 170.86, y: 186.26), controlPoint1: CGPoint(x: 169.19, y: 199.14), controlPoint2: CGPoint(x: 170.64, y: 188.4))
                    torsoPath.close()
                    return torsoPath

                case .rightArmPit:
                    let rightArmPitPath = UIBezierPath()
                    rightArmPitPath.move(to: CGPoint(x: 162.34, y: 157.9))
                    rightArmPitPath.addCurve(to: CGPoint(x: 177.62, y: 151.63), controlPoint1: CGPoint(x: 169.04, y: 153.15), controlPoint2: CGPoint(x: 177.62, y: 151.65))
                    rightArmPitPath.addCurve(to: CGPoint(x: 170.94, y: 186.26), controlPoint1: CGPoint(x: 174.94, y: 165.11), controlPoint2: CGPoint(x: 172.35, y: 180.23))
                    rightArmPitPath.addCurve(to: CGPoint(x: 168.24, y: 207.7), controlPoint1: CGPoint(x: 170.72, y: 188.4), controlPoint2: CGPoint(x: 169.28, y: 199.15))
                    rightArmPitPath.addCurve(to: CGPoint(x: 157.06, y: 187.32), controlPoint1: CGPoint(x: 168.24, y: 207.7), controlPoint2: CGPoint(x: 159.79, y: 198.45))
                    rightArmPitPath.addCurve(to: CGPoint(x: 162.34, y: 157.9), controlPoint1: CGPoint(x: 154.34, y: 176.19), controlPoint2: CGPoint(x: 155.65, y: 162.65))
                    rightArmPitPath.close()
                    return rightArmPitPath

                case .leftArmPit:
                    let leftArmPitPath = UIBezierPath()
                    leftArmPitPath.move(to: CGPoint(x: 79.31, y: 157.9))
                    leftArmPitPath.addCurve(to: CGPoint(x: 64.04, y: 151.63), controlPoint1: CGPoint(x: 72.61, y: 153.15), controlPoint2: CGPoint(x: 64.04, y: 151.65))
                    leftArmPitPath.addCurve(to: CGPoint(x: 70.72, y: 186.26), controlPoint1: CGPoint(x: 66.72, y: 165.11), controlPoint2: CGPoint(x: 69.3, y: 180.23))
                    leftArmPitPath.addCurve(to: CGPoint(x: 73.42, y: 207.7), controlPoint1: CGPoint(x: 70.94, y: 188.4), controlPoint2: CGPoint(x: 72.38, y: 199.15))
                    leftArmPitPath.addCurve(to: CGPoint(x: 84.59, y: 187.32), controlPoint1: CGPoint(x: 73.42, y: 207.7), controlPoint2: CGPoint(x: 81.86, y: 198.45))
                    leftArmPitPath.addCurve(to: CGPoint(x: 79.31, y: 157.9), controlPoint1: CGPoint(x: 87.32, y: 176.19), controlPoint2: CGPoint(x: 86.01, y: 162.65))
                    leftArmPitPath.close()
                    return leftArmPitPath.reversing()

                case .head, .backOfHead:
                    let headPath = UIBezierPath()
                    headPath.move(to: CGPoint(x: 91.3, y: 17.45))
                    headPath.addCurve(to: CGPoint(x: 133.84, y: 3.48), controlPoint1: CGPoint(x: 98.03, y: 1.47), controlPoint2: CGPoint(x: 118.97, y: -2.79))
                    headPath.addLine(to: CGPoint(x: 133.85, y: 3.48))
                    headPath.addCurve(to: CGPoint(x: 150.32, y: 22.98), controlPoint1: CGPoint(x: 142.56, y: 7.15), controlPoint2: CGPoint(x: 147.74, y: 14.03))
                    headPath.addCurve(to: CGPoint(x: 150.47, y: 23.56), controlPoint1: CGPoint(x: 150.38, y: 23.16), controlPoint2: CGPoint(x: 150.42, y: 23.36))
                    headPath.addCurve(to: CGPoint(x: 150.6, y: 24.09), controlPoint1: CGPoint(x: 150.51, y: 23.74), controlPoint2: CGPoint(x: 150.55, y: 23.91))
                    headPath.addLine(to: CGPoint(x: 150.61, y: 24.09))
                    headPath.addCurve(to: CGPoint(x: 151.5, y: 44.8), controlPoint1: CGPoint(x: 152.27, y: 30.45), controlPoint2: CGPoint(x: 153, y: 38.3))
                    headPath.addCurve(to: CGPoint(x: 155.19, y: 44.75), controlPoint1: CGPoint(x: 152.69, y: 44.36), controlPoint2: CGPoint(x: 154.12, y: 44.37))
                    headPath.addLine(to: CGPoint(x: 155.19, y: 44.76))
                    headPath.addCurve(to: CGPoint(x: 158.99, y: 52.63), controlPoint1: CGPoint(x: 158.18, y: 45.81), controlPoint2: CGPoint(x: 158.85, y: 49.91))
                    headPath.addCurve(to: CGPoint(x: 149.25, y: 66.61), controlPoint1: CGPoint(x: 159.18, y: 56.84), controlPoint2: CGPoint(x: 154.97, y: 68.36))
                    headPath.addCurve(to: CGPoint(x: 147, y: 74.26), controlPoint1: CGPoint(x: 148.63, y: 69.19), controlPoint2: CGPoint(x: 147.97, y: 71.8))
                    headPath.addCurve(to: CGPoint(x: 139.19, y: 83.61), controlPoint1: CGPoint(x: 145.51, y: 78.03), controlPoint2: CGPoint(x: 142.21, y: 80.98))
                    headPath.addLine(to: CGPoint(x: 139.19, y: 83.63))
                    headPath.addCurve(to: CGPoint(x: 119.35, y: 86.68), controlPoint1: CGPoint(x: 139.19, y: 83.63), controlPoint2: CGPoint(x: 129.78, y: 86.68))
                    headPath.addCurve(to: CGPoint(x: 100.36, y: 83.89), controlPoint1: CGPoint(x: 108.92, y: 86.68), controlPoint2: CGPoint(x: 100.89, y: 84.5))
                    headPath.addCurve(to: CGPoint(x: 92.54, y: 74.25), controlPoint1: CGPoint(x: 97.35, y: 81.17), controlPoint2: CGPoint(x: 94.04, y: 78.1))
                    headPath.addCurve(to: CGPoint(x: 90.3, y: 66.61), controlPoint1: CGPoint(x: 91.58, y: 71.79), controlPoint2: CGPoint(x: 90.91, y: 69.19))
                    headPath.addCurve(to: CGPoint(x: 80.56, y: 52.63), controlPoint1: CGPoint(x: 84.57, y: 68.37), controlPoint2: CGPoint(x: 80.37, y: 56.84))
                    headPath.addCurve(to: CGPoint(x: 84.43, y: 44.72), controlPoint1: CGPoint(x: 80.68, y: 49.85), controlPoint2: CGPoint(x: 81.39, y: 45.76))
                    headPath.addCurve(to: CGPoint(x: 88.05, y: 44.81), controlPoint1: CGPoint(x: 85.49, y: 44.36), controlPoint2: CGPoint(x: 86.88, y: 44.37))
                    headPath.addCurve(to: CGPoint(x: 89.05, y: 24.09), controlPoint1: CGPoint(x: 86.56, y: 38.37), controlPoint2: CGPoint(x: 87.32, y: 30.63))
                    headPath.addLine(to: CGPoint(x: 89.05, y: 24.09))
                    headPath.addCurve(to: CGPoint(x: 91.3, y: 17.45), controlPoint1: CGPoint(x: 89.68, y: 21.79), controlPoint2: CGPoint(x: 90.43, y: 19.51))
                    headPath.close()
                    return headPath.reversing()

                case .neck:
                    let neckPath = UIBezierPath()
                    neckPath.move(to: CGPoint(x: 138.69, y: 95.85))
                    neckPath.addCurve(to: CGPoint(x: 139.19, y: 83.6), controlPoint1: CGPoint(x: 138.72, y: 92.19), controlPoint2: CGPoint(x: 138.96, y: 87.25))
                    neckPath.addCurve(to: CGPoint(x: 119.5, y: 86.5), controlPoint1: CGPoint(x: 139.19, y: 83.6), controlPoint2: CGPoint(x: 129.11, y: 86.5))
                    neckPath.addCurve(to: CGPoint(x: 100.36, y: 83.89), controlPoint1: CGPoint(x: 108.72, y: 86.5), controlPoint2: CGPoint(x: 100.36, y: 83.89))
                    neckPath.addCurve(to: CGPoint(x: 100.88, y: 95.85), controlPoint1: CGPoint(x: 100.61, y: 87.52), controlPoint2: CGPoint(x: 100.83, y: 92.22))
                    neckPath.addCurve(to: CGPoint(x: 96.73, y: 108.59), controlPoint1: CGPoint(x: 100.92, y: 100.67), controlPoint2: CGPoint(x: 101, y: 105.7))
                    neckPath.addCurve(to: CGPoint(x: 120.19, y: 114.26), controlPoint1: CGPoint(x: 96.73, y: 108.59), controlPoint2: CGPoint(x: 103.42, y: 114.26))
                    neckPath.addCurve(to: CGPoint(x: 144.24, y: 108.59), controlPoint1: CGPoint(x: 136.97, y: 114.26), controlPoint2: CGPoint(x: 144.24, y: 108.59))
                    neckPath.addCurve(to: CGPoint(x: 138.69, y: 95.85), controlPoint1: CGPoint(x: 139.99, y: 105.7), controlPoint2: CGPoint(x: 138.65, y: 100.66))
                    neckPath.addLine(to: CGPoint(x: 138.69, y: 95.85))
                    neckPath.close()
                    return neckPath.reversing()

                case .scalp:
                    let scalpPath = UIBezierPath()
                    scalpPath.move(to: CGPoint(x: 133.84, y: 3.05))
                    scalpPath.addCurve(to: CGPoint(x: 91.3, y: 17.02), controlPoint1: CGPoint(x: 118.97, y: -3.22), controlPoint2: CGPoint(x: 98.03, y: 1.04))
                    scalpPath.addCurve(to: CGPoint(x: 89.02, y: 23.65), controlPoint1: CGPoint(x: 90.42, y: 19.1), controlPoint2: CGPoint(x: 89.65, y: 21.34))
                    scalpPath.addLine(to: CGPoint(x: 150.62, y: 23.65))
                    scalpPath.addCurve(to: CGPoint(x: 150.32, y: 22.55), controlPoint1: CGPoint(x: 150.53, y: 23.28), controlPoint2: CGPoint(x: 150.43, y: 22.91))
                    scalpPath.addCurve(to: CGPoint(x: 133.85, y: 3.05), controlPoint1: CGPoint(x: 147.74, y: 13.6), controlPoint2: CGPoint(x: 142.56, y: 6.72))
                    scalpPath.addLine(to: CGPoint(x: 133.84, y: 3.05))
                    scalpPath.close()
                    return scalpPath.reversing()
            }
        }
    }

    public enum Front: String, CaseIterable, Sendable, Equatable {
        case head = "head",
             face = "face",
             faceFeatures = "face_features",
             throat = "throat",
             scalp = "scalp"

        case upperBody = "upper_body",
             torso = "torso",
             pelvisFront = "pelvis",
             rightArmPit = "right_armpit",
             leftArmPit = "left_armpit"

        case leftArm = "left_arm",
             leftUpperArm = "left_upper_arm",
             leftArmFold = "left_armfold",
             leftUnderArm = "left_under_arm",
             leftPalm = "left_palm"

        case rightArm = "right_arm",
             rightUpperArm = "right_upper_arm",
             rightArmFold = "right_armfold",
             rightUnderArm = "right_under_arm",
             rightPalm = "right_palm"

        case leftThigh = "left_thigh",
             leftKnee = "left_knee",
             leftCalf = "left_calf",
             leftFoot = "left_foot",
             leftLeg = "left_leg"

        case rightLeg = "right_leg",
             rightThigh = "right_thigh",
             rightKnee = "right_knee",
             rightCalf = "right_calf",
             rightFoot = "right_foot"

        public var path: UIBezierPath {
            switch self {
                case .faceFeatures:
                    let facePath = UIBezierPath()
                    //// Face Expression
                    //// Nose Drawing
                    let nosePath = UIBezierPath()
                    nosePath.move(to: CGPoint(x: 115.52, y: 59.25))
                    nosePath.addCurve(to: CGPoint(x: 113.38, y: 64.4), controlPoint1: CGPoint(x: 114.85, y: 60.85), controlPoint2: CGPoint(x: 113, y: 62.54))
                    nosePath.addCurve(to: CGPoint(x: 114.85, y: 64), controlPoint1: CGPoint(x: 113.58, y: 65.34), controlPoint2: CGPoint(x: 115.05, y: 64.94))
                    nosePath.addCurve(to: CGPoint(x: 116.32, y: 60.95), controlPoint1: CGPoint(x: 114.68, y: 63.16), controlPoint2: CGPoint(x: 115.92, y: 61.64))
                    nosePath.addCurve(to: CGPoint(x: 117.5, y: 57.73), controlPoint1: CGPoint(x: 116.94, y: 59.84), controlPoint2: CGPoint(x: 117.27, y: 59))
                    nosePath.addCurve(to: CGPoint(x: 118.16, y: 50.29), controlPoint1: CGPoint(x: 117.95, y: 55.28), controlPoint2: CGPoint(x: 118.17, y: 52.77))
                    nosePath.addCurve(to: CGPoint(x: 116.62, y: 50.29), controlPoint1: CGPoint(x: 118.16, y: 49.33), controlPoint2: CGPoint(x: 116.62, y: 49.32))
                    nosePath.addCurve(to: CGPoint(x: 115.52, y: 59.26), controlPoint1: CGPoint(x: 116.64, y: 53.18), controlPoint2: CGPoint(x: 116.63, y: 56.57))
                    nosePath.addLine(to: CGPoint(x: 115.52, y: 59.25))
                    nosePath.close()
                    facePath.append(nosePath)


                    //// Eyebrow Left Drawing
                    let eyebrowLeftPath = UIBezierPath()
                    eyebrowLeftPath.move(to: CGPoint(x: 141.91, y: 35.3))
                    eyebrowLeftPath.addCurve(to: CGPoint(x: 131.3, y: 32.07), controlPoint1: CGPoint(x: 138.78, y: 33.61), controlPoint2: CGPoint(x: 134.97, y: 31.57))
                    eyebrowLeftPath.addCurve(to: CGPoint(x: 121.94, y: 35.3), controlPoint1: CGPoint(x: 128.06, y: 32.51), controlPoint2: CGPoint(x: 124.85, y: 33.88))
                    eyebrowLeftPath.addCurve(to: CGPoint(x: 122.71, y: 36.59), controlPoint1: CGPoint(x: 121.06, y: 35.73), controlPoint2: CGPoint(x: 121.83, y: 37.02))
                    eyebrowLeftPath.addCurve(to: CGPoint(x: 130.38, y: 33.76), controlPoint1: CGPoint(x: 125.14, y: 35.41), controlPoint2: CGPoint(x: 127.74, y: 34.34))
                    eyebrowLeftPath.addCurve(to: CGPoint(x: 141.13, y: 36.59), controlPoint1: CGPoint(x: 134.21, y: 32.92), controlPoint2: CGPoint(x: 137.83, y: 34.81))
                    eyebrowLeftPath.addCurve(to: CGPoint(x: 141.91, y: 35.3), controlPoint1: CGPoint(x: 141.99, y: 37.06), controlPoint2: CGPoint(x: 142.77, y: 35.76))
                    eyebrowLeftPath.close()
                    facePath.append(eyebrowLeftPath)

                    //// Eye Left Drawing
                    let eyeLeftPath = UIBezierPath()
                    eyeLeftPath.move(to: CGPoint(x: 138.71, y: 42.52))
                    eyeLeftPath.addCurve(to: CGPoint(x: 134.67, y: 45.13), controlPoint1: CGPoint(x: 137.65, y: 43.68), controlPoint2: CGPoint(x: 136.21, y: 44.7))
                    eyeLeftPath.addCurve(to: CGPoint(x: 126.86, y: 42.74), controlPoint1: CGPoint(x: 131.86, y: 45.92), controlPoint2: CGPoint(x: 129.04, y: 44.37))
                    eyeLeftPath.addCurve(to: CGPoint(x: 126.09, y: 44.03), controlPoint1: CGPoint(x: 126.09, y: 42.15), controlPoint2: CGPoint(x: 125.32, y: 43.45))
                    eyeLeftPath.addCurve(to: CGPoint(x: 139.78, y: 43.57), controlPoint1: CGPoint(x: 130.52, y: 47.36), controlPoint2: CGPoint(x: 135.84, y: 47.88))
                    eyeLeftPath.addCurve(to: CGPoint(x: 138.7, y: 42.51), controlPoint1: CGPoint(x: 140.44, y: 42.85), controlPoint2: CGPoint(x: 139.37, y: 41.79))
                    eyeLeftPath.addLine(to: CGPoint(x: 138.71, y: 42.52))
                    eyeLeftPath.close()
                    facePath.append(eyeLeftPath)


                    //// Eyebrow Right Drawing
                    let eyebrowRightPath = UIBezierPath()
                    eyebrowRightPath.move(to: CGPoint(x: 107.96, y: 33.77))
                    eyebrowRightPath.addCurve(to: CGPoint(x: 115.62, y: 36.6), controlPoint1: CGPoint(x: 110.6, y: 34.35), controlPoint2: CGPoint(x: 113.2, y: 35.42))
                    eyebrowRightPath.addCurve(to: CGPoint(x: 116.4, y: 35.31), controlPoint1: CGPoint(x: 116.5, y: 37.03), controlPoint2: CGPoint(x: 117.28, y: 35.74))
                    eyebrowRightPath.addCurve(to: CGPoint(x: 107.05, y: 32.08), controlPoint1: CGPoint(x: 113.5, y: 33.89), controlPoint2: CGPoint(x: 110.28, y: 32.52))
                    eyebrowRightPath.addCurve(to: CGPoint(x: 96.44, y: 35.3), controlPoint1: CGPoint(x: 103.38, y: 31.58), controlPoint2: CGPoint(x: 99.56, y: 33.62))
                    eyebrowRightPath.addCurve(to: CGPoint(x: 97.21, y: 36.59), controlPoint1: CGPoint(x: 95.58, y: 35.77), controlPoint2: CGPoint(x: 96.34, y: 37.06))
                    eyebrowRightPath.addCurve(to: CGPoint(x: 107.96, y: 33.77), controlPoint1: CGPoint(x: 100.49, y: 34.82), controlPoint2: CGPoint(x: 104.13, y: 32.93))
                    eyebrowRightPath.close()
                    facePath.append(eyebrowRightPath)


                    //// Eye Right Drawing
                    let eyeRightPath = UIBezierPath()
                    eyeRightPath.move(to: CGPoint(x: 111.48, y: 42.74))
                    eyeRightPath.addCurve(to: CGPoint(x: 103.67, y: 45.13), controlPoint1: CGPoint(x: 109.3, y: 44.38), controlPoint2: CGPoint(x: 106.49, y: 45.92))
                    eyeRightPath.addCurve(to: CGPoint(x: 99.64, y: 42.52), controlPoint1: CGPoint(x: 102.13, y: 44.7), controlPoint2: CGPoint(x: 100.7, y: 43.68))
                    eyeRightPath.addCurve(to: CGPoint(x: 98.55, y: 43.58), controlPoint1: CGPoint(x: 98.98, y: 41.8), controlPoint2: CGPoint(x: 97.9, y: 42.86))
                    eyeRightPath.addCurve(to: CGPoint(x: 112.25, y: 44.04), controlPoint1: CGPoint(x: 102.51, y: 47.89), controlPoint2: CGPoint(x: 107.82, y: 47.37))
                    eyeRightPath.addCurve(to: CGPoint(x: 111.47, y: 42.75), controlPoint1: CGPoint(x: 113.02, y: 43.46), controlPoint2: CGPoint(x: 112.25, y: 42.16))
                    eyeRightPath.addLine(to: CGPoint(x: 111.48, y: 42.74))
                    eyeRightPath.close()
                    facePath.append(eyeRightPath)


                    //// Nostril Right Drawing
                    let nostrilRightPath = UIBezierPath()
                    nostrilRightPath.move(to: CGPoint(x: 117.67, y: 66.45))
                    nostrilRightPath.addCurve(to: CGPoint(x: 117.01, y: 66.18), controlPoint1: CGPoint(x: 117.45, y: 66.35), controlPoint2: CGPoint(x: 117.24, y: 66.26))
                    nostrilRightPath.addCurve(to: CGPoint(x: 115.7, y: 65.87), controlPoint1: CGPoint(x: 116.59, y: 66.03), controlPoint2: CGPoint(x: 116.14, y: 65.9))
                    nostrilRightPath.addCurve(to: CGPoint(x: 115.25, y: 65.98), controlPoint1: CGPoint(x: 115.55, y: 65.87), controlPoint2: CGPoint(x: 115.37, y: 65.87))
                    nostrilRightPath.addCurve(to: CGPoint(x: 115.36, y: 66.48), controlPoint1: CGPoint(x: 115.1, y: 66.14), controlPoint2: CGPoint(x: 115.24, y: 66.35))
                    nostrilRightPath.addCurve(to: CGPoint(x: 116.2, y: 66.99), controlPoint1: CGPoint(x: 115.58, y: 66.72), controlPoint2: CGPoint(x: 115.9, y: 66.87))
                    nostrilRightPath.addCurve(to: CGPoint(x: 117.33, y: 67.26), controlPoint1: CGPoint(x: 116.56, y: 67.13), controlPoint2: CGPoint(x: 116.94, y: 67.23))
                    nostrilRightPath.addCurve(to: CGPoint(x: 118.13, y: 67.09), controlPoint1: CGPoint(x: 117.57, y: 67.28), controlPoint2: CGPoint(x: 117.94, y: 67.28))
                    nostrilRightPath.addCurve(to: CGPoint(x: 118.08, y: 66.7), controlPoint1: CGPoint(x: 118.25, y: 66.97), controlPoint2: CGPoint(x: 118.19, y: 66.81))
                    nostrilRightPath.addCurve(to: CGPoint(x: 117.67, y: 66.43), controlPoint1: CGPoint(x: 117.97, y: 66.59), controlPoint2: CGPoint(x: 117.81, y: 66.51))
                    nostrilRightPath.addLine(to: CGPoint(x: 117.67, y: 66.45))
                    nostrilRightPath.close()
                    facePath.append(nostrilRightPath)


                    //// Nostril Left Drawing
                    let nostrilLeftPath = UIBezierPath()
                    nostrilLeftPath.move(to: CGPoint(x: 120.51, y: 67.27))
                    nostrilLeftPath.addCurve(to: CGPoint(x: 121.73, y: 67.05), controlPoint1: CGPoint(x: 120.92, y: 67.29), controlPoint2: CGPoint(x: 121.35, y: 67.19))
                    nostrilLeftPath.addCurve(to: CGPoint(x: 122.71, y: 66.49), controlPoint1: CGPoint(x: 122.08, y: 66.93), controlPoint2: CGPoint(x: 122.46, y: 66.76))
                    nostrilLeftPath.addCurve(to: CGPoint(x: 122.86, y: 66.04), controlPoint1: CGPoint(x: 122.82, y: 66.37), controlPoint2: CGPoint(x: 122.94, y: 66.2))
                    nostrilLeftPath.addCurve(to: CGPoint(x: 122.48, y: 65.87), controlPoint1: CGPoint(x: 122.79, y: 65.91), controlPoint2: CGPoint(x: 122.62, y: 65.88))
                    nostrilLeftPath.addCurve(to: CGPoint(x: 121.23, y: 66.12), controlPoint1: CGPoint(x: 122.06, y: 65.86), controlPoint2: CGPoint(x: 121.62, y: 65.99))
                    nostrilLeftPath.addCurve(to: CGPoint(x: 120.08, y: 66.64), controlPoint1: CGPoint(x: 120.84, y: 66.25), controlPoint2: CGPoint(x: 120.42, y: 66.39))
                    nostrilLeftPath.addCurve(to: CGPoint(x: 119.88, y: 67), controlPoint1: CGPoint(x: 119.97, y: 66.72), controlPoint2: CGPoint(x: 119.84, y: 66.85))
                    nostrilLeftPath.addCurve(to: CGPoint(x: 120.51, y: 67.27), controlPoint1: CGPoint(x: 119.95, y: 67.23), controlPoint2: CGPoint(x: 120.31, y: 67.26))
                    nostrilLeftPath.close()
                    facePath.append(nostrilLeftPath)


                    //// Mouth Drawing
                    let mouthPath = UIBezierPath()
                    mouthPath.move(to: CGPoint(x: 126.72, y: 78.78))
                    mouthPath.addCurve(to: CGPoint(x: 111.37, y: 78.78), controlPoint1: CGPoint(x: 121.63, y: 78.35), controlPoint2: CGPoint(x: 116.47, y: 78.47))
                    mouthPath.addCurve(to: CGPoint(x: 111.37, y: 80.28), controlPoint1: CGPoint(x: 110.39, y: 78.84), controlPoint2: CGPoint(x: 110.39, y: 80.34))
                    mouthPath.addCurve(to: CGPoint(x: 126.72, y: 80.28), controlPoint1: CGPoint(x: 116.47, y: 79.97), controlPoint2: CGPoint(x: 121.63, y: 79.85))
                    mouthPath.addCurve(to: CGPoint(x: 126.72, y: 78.78), controlPoint1: CGPoint(x: 127.7, y: 80.36), controlPoint2: CGPoint(x: 127.69, y: 78.86))
                    mouthPath.close()
                    facePath.append(mouthPath)

                    return facePath

                case .head, .face:
                    let facePath = UIBezierPath()
                    facePath.move(to: CGPoint(x: 158.16, y: 53.7))
                    facePath.addCurve(to: CGPoint(x: 154.37, y: 45.83), controlPoint1: CGPoint(x: 158.03, y: 50.98), controlPoint2: CGPoint(x: 157.35, y: 46.88))
                    facePath.addCurve(to: CGPoint(x: 150.67, y: 45.88), controlPoint1: CGPoint(x: 153.3, y: 45.45), controlPoint2: CGPoint(x: 151.87, y: 45.44))
                    facePath.addCurve(to: CGPoint(x: 149.74, y: 25.37), controlPoint1: CGPoint(x: 152.2, y: 39.26), controlPoint2: CGPoint(x: 151.46, y: 31.82))
                    facePath.addCurve(to: CGPoint(x: 149.44, y: 24.27), controlPoint1: CGPoint(x: 149.64, y: 25), controlPoint2: CGPoint(x: 149.54, y: 24.63))
                    facePath.addCurve(to: CGPoint(x: 132.97, y: 4.77), controlPoint1: CGPoint(x: 146.85, y: 15.32), controlPoint2: CGPoint(x: 141.68, y: 8.44))
                    facePath.addCurve(to: CGPoint(x: 90.43, y: 18.74), controlPoint1: CGPoint(x: 118.09, y: -1.5), controlPoint2: CGPoint(x: 97.16, y: 2.76))
                    facePath.addCurve(to: CGPoint(x: 88.15, y: 25.37), controlPoint1: CGPoint(x: 89.55, y: 20.82), controlPoint2: CGPoint(x: 88.78, y: 23.06))
                    facePath.addCurve(to: CGPoint(x: 87.24, y: 45.88), controlPoint1: CGPoint(x: 86.34, y: 32), controlPoint2: CGPoint(x: 85.72, y: 39.33))
                    facePath.addCurve(to: CGPoint(x: 83.62, y: 45.79), controlPoint1: CGPoint(x: 86.07, y: 45.44), controlPoint2: CGPoint(x: 84.68, y: 45.43))
                    facePath.addCurve(to: CGPoint(x: 79.75, y: 53.7), controlPoint1: CGPoint(x: 80.58, y: 46.83), controlPoint2: CGPoint(x: 79.87, y: 50.92))
                    facePath.addCurve(to: CGPoint(x: 89.49, y: 67.68), controlPoint1: CGPoint(x: 79.56, y: 57.91), controlPoint2: CGPoint(x: 83.76, y: 69.44))
                    facePath.addCurve(to: CGPoint(x: 91.73, y: 75.32), controlPoint1: CGPoint(x: 90.1, y: 70.26), controlPoint2: CGPoint(x: 90.77, y: 72.86))
                    facePath.addCurve(to: CGPoint(x: 99.55, y: 84.96), controlPoint1: CGPoint(x: 93.23, y: 79.17), controlPoint2: CGPoint(x: 96.54, y: 82.24))
                    facePath.addCurve(to: CGPoint(x: 101.12, y: 86.57), controlPoint1: CGPoint(x: 100.08, y: 85.57), controlPoint2: CGPoint(x: 101.12, y: 86.57))
                    facePath.addCurve(to: CGPoint(x: 119.87, y: 93.63), controlPoint1: CGPoint(x: 101.12, y: 86.57), controlPoint2: CGPoint(x: 109.44, y: 93.63))
                    facePath.addCurve(to: CGPoint(x: 136.74, y: 86.26), controlPoint1: CGPoint(x: 130.3, y: 93.63), controlPoint2: CGPoint(x: 136.74, y: 86.26))
                    facePath.addLine(to: CGPoint(x: 138.37, y: 84.7))
                    facePath.addLine(to: CGPoint(x: 138.37, y: 84.68))
                    facePath.addCurve(to: CGPoint(x: 146.18, y: 75.33), controlPoint1: CGPoint(x: 141.38, y: 82.05), controlPoint2: CGPoint(x: 144.69, y: 79.1))
                    facePath.addCurve(to: CGPoint(x: 148.42, y: 67.68), controlPoint1: CGPoint(x: 147.15, y: 72.87), controlPoint2: CGPoint(x: 147.81, y: 70.26))
                    facePath.addCurve(to: CGPoint(x: 158.16, y: 53.7), controlPoint1: CGPoint(x: 154.15, y: 69.43), controlPoint2: CGPoint(x: 158.35, y: 57.91))
                    facePath.close()
                    return facePath
                    
                case .scalp:
                    //// Scalp Drawing
                    let scalpPath = UIBezierPath()
                    scalpPath.move(to: CGPoint(x: 133.2, y: 4.77))
                    scalpPath.addCurve(to: CGPoint(x: 90.11, y: 18.74), controlPoint1: CGPoint(x: 118.13, y: -1.5), controlPoint2: CGPoint(x: 96.93, y: 2.76))
                    scalpPath.addCurve(to: CGPoint(x: 87.8, y: 25.37), controlPoint1: CGPoint(x: 89.22, y: 20.82), controlPoint2: CGPoint(x: 88.44, y: 23.06))
                    scalpPath.addLine(to: CGPoint(x: 150.19, y: 25.37))
                    scalpPath.addCurve(to: CGPoint(x: 149.89, y: 24.27), controlPoint1: CGPoint(x: 150.09, y: 25), controlPoint2: CGPoint(x: 149.99, y: 24.63))
                    scalpPath.addCurve(to: CGPoint(x: 133.21, y: 4.77), controlPoint1: CGPoint(x: 147.26, y: 15.32), controlPoint2: CGPoint(x: 142.03, y: 8.44))
                    scalpPath.addLine(to: CGPoint(x: 133.2, y: 4.77))
                    scalpPath.close()

                    return scalpPath

                case .throat:
                    //// Head
                    //// Neck Drawing
                    let neckPath = UIBezierPath()
                    neckPath.move(to: CGPoint(x: 138.16, y: 96.5))
                    neckPath.addCurve(to: CGPoint(x: 138.66, y: 84.25), controlPoint1: CGPoint(x: 138.19, y: 92.84), controlPoint2: CGPoint(x: 138.42, y: 87.9))
                    neckPath.addLine(to: CGPoint(x: 137.02, y: 85.84))
                    neckPath.addCurve(to: CGPoint(x: 119.94, y: 93.21), controlPoint1: CGPoint(x: 137.02, y: 85.84), controlPoint2: CGPoint(x: 129.66, y: 93.21))
                    neckPath.addCurve(to: CGPoint(x: 100.95, y: 86.15), controlPoint1: CGPoint(x: 109.02, y: 93.21), controlPoint2: CGPoint(x: 100.95, y: 86.15))
                    neckPath.addLine(to: CGPoint(x: 99.36, y: 84.54))
                    neckPath.addCurve(to: CGPoint(x: 99.88, y: 96.5), controlPoint1: CGPoint(x: 99.6, y: 88.17), controlPoint2: CGPoint(x: 99.84, y: 92.87))
                    neckPath.addCurve(to: CGPoint(x: 95.46, y: 108.87), controlPoint1: CGPoint(x: 99.93, y: 101.31), controlPoint2: CGPoint(x: 99.78, y: 105.98))
                    neckPath.addCurve(to: CGPoint(x: 119.44, y: 114.89), controlPoint1: CGPoint(x: 95.46, y: 108.87), controlPoint2: CGPoint(x: 102.45, y: 114.89))
                    neckPath.addCurve(to: CGPoint(x: 144.09, y: 108.87), controlPoint1: CGPoint(x: 136.44, y: 114.89), controlPoint2: CGPoint(x: 144.09, y: 108.87))
                    neckPath.addCurve(to: CGPoint(x: 138.17, y: 96.5), controlPoint1: CGPoint(x: 139.79, y: 105.98), controlPoint2: CGPoint(x: 138.13, y: 101.3))
                    neckPath.addLine(to: CGPoint(x: 138.16, y: 96.5))
                    neckPath.close()
                    return neckPath

                case .torso, .upperBody:
                    //// Full Torso Drawing
                    let fullTorsoPath = UIBezierPath()
                    fullTorsoPath.move(to: CGPoint(x: 170.42, y: 187.58))
                    fullTorsoPath.addCurve(to: CGPoint(x: 177.15, y: 152.81), controlPoint1: CGPoint(x: 171.85, y: 181.53), controlPoint2: CGPoint(x: 174.45, y: 166.35))
                    fullTorsoPath.addLine(to: CGPoint(x: 184.8, y: 127.83))
                    fullTorsoPath.addCurve(to: CGPoint(x: 143.86, y: 109.01), controlPoint1: CGPoint(x: 181.79, y: 125.63), controlPoint2: CGPoint(x: 173.52, y: 118.01))
                    fullTorsoPath.addCurve(to: CGPoint(x: 119.93, y: 114.71), controlPoint1: CGPoint(x: 143.86, y: 109.01), controlPoint2: CGPoint(x: 136.92, y: 114.71))
                    fullTorsoPath.addCurve(to: CGPoint(x: 95.98, y: 109.02), controlPoint1: CGPoint(x: 102.94, y: 114.71), controlPoint2: CGPoint(x: 95.98, y: 109.02))
                    fullTorsoPath.addCurve(to: CGPoint(x: 55.04, y: 128.05), controlPoint1: CGPoint(x: 66.33, y: 118.01), controlPoint2: CGPoint(x: 58.05, y: 125.85))
                    fullTorsoPath.addLine(to: CGPoint(x: 62.69, y: 152.81))
                    fullTorsoPath.addCurve(to: CGPoint(x: 69.42, y: 187.58), controlPoint1: CGPoint(x: 65.39, y: 166.35), controlPoint2: CGPoint(x: 67.99, y: 181.53))
                    fullTorsoPath.addCurve(to: CGPoint(x: 72.14, y: 209.11), controlPoint1: CGPoint(x: 69.64, y: 189.73), controlPoint2: CGPoint(x: 71.09, y: 200.52))
                    fullTorsoPath.addCurve(to: CGPoint(x: 72.71, y: 219.66), controlPoint1: CGPoint(x: 72.49, y: 212.49), controlPoint2: CGPoint(x: 72.71, y: 215.89))
                    fullTorsoPath.addCurve(to: CGPoint(x: 68.31, y: 280.68), controlPoint1: CGPoint(x: 72.71, y: 223.81), controlPoint2: CGPoint(x: 71.66, y: 263.7))
                    fullTorsoPath.addCurve(to: CGPoint(x: 120.13, y: 293.55), controlPoint1: CGPoint(x: 68.31, y: 280.68), controlPoint2: CGPoint(x: 88, y: 293.55))
                    fullTorsoPath.addCurve(to: CGPoint(x: 172.02, y: 280.25), controlPoint1: CGPoint(x: 152.25, y: 293.55), controlPoint2: CGPoint(x: 172.02, y: 280.25))
                    fullTorsoPath.addCurve(to: CGPoint(x: 167.14, y: 219.66), controlPoint1: CGPoint(x: 168.75, y: 263.55), controlPoint2: CGPoint(x: 167.14, y: 223.82))
                    fullTorsoPath.addCurve(to: CGPoint(x: 167.7, y: 209.11), controlPoint1: CGPoint(x: 167.14, y: 215.9), controlPoint2: CGPoint(x: 167.36, y: 212.49))
                    fullTorsoPath.addCurve(to: CGPoint(x: 170.42, y: 187.58), controlPoint1: CGPoint(x: 168.74, y: 200.52), controlPoint2: CGPoint(x: 170.2, y: 189.73))
                    fullTorsoPath.close()
                    return fullTorsoPath

                case .rightArmPit:
                    //// Right Arm Pit Drawing
                    let rightArmPitPath = UIBezierPath()
                    rightArmPitPath.move(to: CGPoint(x: 78.16, y: 158.96))
                    rightArmPitPath.addCurve(to: CGPoint(x: 62.77, y: 152.67), controlPoint1: CGPoint(x: 71.4, y: 154.19), controlPoint2: CGPoint(x: 62.77, y: 152.69))
                    rightArmPitPath.addCurve(to: CGPoint(x: 69.5, y: 187.44), controlPoint1: CGPoint(x: 65.47, y: 166.2), controlPoint2: CGPoint(x: 68.07, y: 181.38))
                    rightArmPitPath.addCurve(to: CGPoint(x: 72.22, y: 208.97), controlPoint1: CGPoint(x: 69.72, y: 189.59), controlPoint2: CGPoint(x: 71.17, y: 200.38))
                    rightArmPitPath.addCurve(to: CGPoint(x: 83.48, y: 188.5), controlPoint1: CGPoint(x: 72.22, y: 208.97), controlPoint2: CGPoint(x: 80.73, y: 199.68))
                    rightArmPitPath.addCurve(to: CGPoint(x: 78.16, y: 158.96), controlPoint1: CGPoint(x: 86.23, y: 177.33), controlPoint2: CGPoint(x: 84.91, y: 163.73))
                    rightArmPitPath.close()

                    return rightArmPitPath

                case .leftArmPit:
                    //// Left Arm Pit Drawing
                    let leftArmPitPath = UIBezierPath()
                    leftArmPitPath.move(to: CGPoint(x: 161.84, y: 158.96))
                    leftArmPitPath.addCurve(to: CGPoint(x: 177.23, y: 152.67), controlPoint1: CGPoint(x: 168.59, y: 154.19), controlPoint2: CGPoint(x: 177.23, y: 152.69))
                    leftArmPitPath.addCurve(to: CGPoint(x: 170.5, y: 187.44), controlPoint1: CGPoint(x: 174.53, y: 166.2), controlPoint2: CGPoint(x: 171.93, y: 181.38))
                    leftArmPitPath.addCurve(to: CGPoint(x: 167.78, y: 208.97), controlPoint1: CGPoint(x: 170.28, y: 189.59), controlPoint2: CGPoint(x: 168.83, y: 200.38))
                    leftArmPitPath.addCurve(to: CGPoint(x: 156.52, y: 188.5), controlPoint1: CGPoint(x: 167.78, y: 208.97), controlPoint2: CGPoint(x: 159.27, y: 199.68))
                    leftArmPitPath.addCurve(to: CGPoint(x: 161.84, y: 158.96), controlPoint1: CGPoint(x: 153.77, y: 177.33), controlPoint2: CGPoint(x: 155.09, y: 163.73))
                    leftArmPitPath.close()

                    return leftArmPitPath.reversing()

                case .pelvisFront:
                    let pelvisFrontPath = UIBezierPath()
                    pelvisFrontPath.move(to: CGPoint(x: 66.74, y: 289.22))
                    pelvisFrontPath.addCurve(to: CGPoint(x: 60.2, y: 330.38), controlPoint1: CGPoint(x: 63.68, y: 301.12), controlPoint2: CGPoint(x: 60.82, y: 318.15))
                    pelvisFrontPath.addCurve(to: CGPoint(x: 118.41, y: 350.64), controlPoint1: CGPoint(x: 68.98, y: 350.15), controlPoint2: CGPoint(x: 118.41, y: 350.64))
                    pelvisFrontPath.addCurve(to: CGPoint(x: 120.48, y: 331.45), controlPoint1: CGPoint(x: 118.41, y: 350.64), controlPoint2: CGPoint(x: 118.59, y: 332.58))
                    pelvisFrontPath.addCurve(to: CGPoint(x: 122.29, y: 350.64), controlPoint1: CGPoint(x: 121.37, y: 331.98), controlPoint2: CGPoint(x: 122.29, y: 350.64))
                    pelvisFrontPath.addCurve(to: CGPoint(x: 180.6, y: 330.78), controlPoint1: CGPoint(x: 122.29, y: 350.64), controlPoint2: CGPoint(x: 173.73, y: 350.16))
                    pelvisFrontPath.addCurve(to: CGPoint(x: 174.23, y: 289.21), controlPoint1: CGPoint(x: 179.96, y: 318.55), controlPoint2: CGPoint(x: 177.27, y: 301.06))
                    pelvisFrontPath.addLine(to: CGPoint(x: 172.08, y: 280.09))
                    pelvisFrontPath.addCurve(to: CGPoint(x: 120.39, y: 293.31), controlPoint1: CGPoint(x: 172.08, y: 280.09), controlPoint2: CGPoint(x: 152.52, y: 293.31))
                    pelvisFrontPath.addCurve(to: CGPoint(x: 68.36, y: 280.52), controlPoint1: CGPoint(x: 88.26, y: 293.31), controlPoint2: CGPoint(x: 68.36, y: 280.52))
                    pelvisFrontPath.addLine(to: CGPoint(x: 66.75, y: 289.21))
                    pelvisFrontPath.addLine(to: CGPoint(x: 66.74, y: 289.22))
                    pelvisFrontPath.close()
                    return pelvisFrontPath

                case .leftArm:
                    let fullLeftArmPath = UIBezierPath()
                    fullLeftArmPath.move(to: CGPoint(x: 185.22, y: 128.29))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 200.62, y: 167.51), controlPoint1: CGPoint(x: 189.75, y: 132.5), controlPoint2: CGPoint(x: 197.61, y: 145.26))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 204.75, y: 211.64), controlPoint1: CGPoint(x: 203.62, y: 189.77), controlPoint2: CGPoint(x: 204.38, y: 209.37))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 207.75, y: 231.25), controlPoint1: CGPoint(x: 205.13, y: 213.9), controlPoint2: CGPoint(x: 207.75, y: 231.25))
                    fullLeftArmPath.addLine(to: CGPoint(x: 207.8, y: 231.33))
                    fullLeftArmPath.addLine(to: CGPoint(x: 211.43, y: 255.83))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 211.24, y: 255.29), controlPoint1: CGPoint(x: 211.41, y: 255.64), controlPoint2: CGPoint(x: 211.34, y: 255.46))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 211.38, y: 255.75), controlPoint1: CGPoint(x: 211.31, y: 255.44), controlPoint2: CGPoint(x: 211.36, y: 255.59))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 220.21, y: 310.01), controlPoint1: CGPoint(x: 213.99, y: 275.75), controlPoint2: CGPoint(x: 220.21, y: 310.01))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 199.26, y: 310.01), controlPoint1: CGPoint(x: 208.62, y: 304.71), controlPoint2: CGPoint(x: 199.26, y: 310.01))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 181.84, y: 256.14), controlPoint1: CGPoint(x: 196.55, y: 299.63), controlPoint2: CGPoint(x: 183.04, y: 263.36))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 181.89, y: 256), controlPoint1: CGPoint(x: 181.84, y: 256.1), controlPoint2: CGPoint(x: 181.86, y: 256.05))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 178.04, y: 232.89), controlPoint1: CGPoint(x: 181.36, y: 252.84), controlPoint2: CGPoint(x: 179.81, y: 243.6))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 177.9, y: 232.46), controlPoint1: CGPoint(x: 177.97, y: 232.75), controlPoint2: CGPoint(x: 177.92, y: 232.61))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 174.33, y: 210.34), controlPoint1: CGPoint(x: 175.42, y: 217.47), controlPoint2: CGPoint(x: 174.33, y: 210.34))
                    fullLeftArmPath.addLine(to: CGPoint(x: 170.53, y: 187.23))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 177.39, y: 153.12), controlPoint1: CGPoint(x: 171.78, y: 181.88), controlPoint2: CGPoint(x: 174.49, y: 164.7))
                    fullLeftArmPath.addCurve(to: CGPoint(x: 185.23, y: 128.3), controlPoint1: CGPoint(x: 181.22, y: 137.86), controlPoint2: CGPoint(x: 185.23, y: 128.3))
                    fullLeftArmPath.addLine(to: CGPoint(x: 185.22, y: 128.29))
                    fullLeftArmPath.close()
                    return fullLeftArmPath

                case .leftUnderArm:
                    let leftUnderArmPath = UIBezierPath()
                    leftUnderArmPath.move(to: CGPoint(x: 181.94, y: 256.07))
                    leftUnderArmPath.addCurve(to: CGPoint(x: 211.17, y: 255.84), controlPoint1: CGPoint(x: 185.44, y: 254.32), controlPoint2: CGPoint(x: 204.68, y: 253.88))
                    leftUnderArmPath.addLine(to: CGPoint(x: 211.35, y: 255.89))
                    leftUnderArmPath.addCurve(to: CGPoint(x: 220.09, y: 309.48), controlPoint1: CGPoint(x: 214.01, y: 275.97), controlPoint2: CGPoint(x: 220.09, y: 309.48))
                    leftUnderArmPath.addCurve(to: CGPoint(x: 199.14, y: 309.48), controlPoint1: CGPoint(x: 208.5, y: 304.18), controlPoint2: CGPoint(x: 199.14, y: 309.48))
                    leftUnderArmPath.addCurve(to: CGPoint(x: 181.82, y: 256.13), controlPoint1: CGPoint(x: 196.49, y: 299.32), controlPoint2: CGPoint(x: 183.49, y: 264.37))
                    leftUnderArmPath.addLine(to: CGPoint(x: 181.94, y: 256.07))
                    leftUnderArmPath.close()
                    return leftUnderArmPath

                case .leftUpperArm:
                    let leftUpperArmPath = UIBezierPath()
                    leftUpperArmPath.move(to: CGPoint(x: 177.26, y: 152.61))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 185.1, y: 127.78), controlPoint1: CGPoint(x: 181.09, y: 137.34), controlPoint2: CGPoint(x: 185.1, y: 127.78))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 200.5, y: 167.01), controlPoint1: CGPoint(x: 189.63, y: 131.99), controlPoint2: CGPoint(x: 197.49, y: 144.76))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 204.63, y: 211.13), controlPoint1: CGPoint(x: 203.5, y: 189.26), controlPoint2: CGPoint(x: 204.26, y: 208.86))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 207.57, y: 230.33), controlPoint1: CGPoint(x: 204.97, y: 213.19), controlPoint2: CGPoint(x: 207.17, y: 227.71))
                    leftUpperArmPath.addLine(to: CGPoint(x: 207.4, y: 230.45))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 178.06, y: 231.81), controlPoint1: CGPoint(x: 200.55, y: 235.32), controlPoint2: CGPoint(x: 182.42, y: 234.02))
                    leftUpperArmPath.addLine(to: CGPoint(x: 177.73, y: 231.65))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 174.2, y: 209.83), controlPoint1: CGPoint(x: 175.29, y: 216.87), controlPoint2: CGPoint(x: 174.2, y: 209.83))
                    leftUpperArmPath.addLine(to: CGPoint(x: 170.4, y: 186.71))
                    leftUpperArmPath.addCurve(to: CGPoint(x: 177.26, y: 152.61), controlPoint1: CGPoint(x: 171.65, y: 181.38), controlPoint2: CGPoint(x: 174.36, y: 164.19))
                    leftUpperArmPath.close()
                    return leftUpperArmPath

                case .leftArmFold:
                    let leftArmFoldPath = UIBezierPath()
                    leftArmFoldPath.move(to: CGPoint(x: 211.35, y: 255.89))
                    leftArmFoldPath.addCurve(to: CGPoint(x: 181.82, y: 256.13), controlPoint1: CGPoint(x: 205.04, y: 253.99), controlPoint2: CGPoint(x: 185.56, y: 254.26))
                    leftArmFoldPath.addCurve(to: CGPoint(x: 177.73, y: 231.64), controlPoint1: CGPoint(x: 181.01, y: 252.23), controlPoint2: CGPoint(x: 178.5, y: 236.26))
                    leftArmFoldPath.addCurve(to: CGPoint(x: 207.57, y: 230.32), controlPoint1: CGPoint(x: 182.3, y: 233.95), controlPoint2: CGPoint(x: 200.65, y: 235.24))
                    leftArmFoldPath.addLine(to: CGPoint(x: 211.35, y: 255.89))
                    leftArmFoldPath.close()
                    return leftArmFoldPath

                case .leftPalm:
                    let leftHandPath = UIBezierPath()
                    leftHandPath.move(to: CGPoint(x: 220.1, y: 309.48))
                    leftHandPath.addCurve(to: CGPoint(x: 230.59, y: 322.03), controlPoint1: CGPoint(x: 220.1, y: 309.48), controlPoint2: CGPoint(x: 226.7, y: 318.47))
                    leftHandPath.addCurve(to: CGPoint(x: 235.93, y: 332.18), controlPoint1: CGPoint(x: 232.4, y: 324.2), controlPoint2: CGPoint(x: 233.93, y: 328.54))
                    leftHandPath.addCurve(to: CGPoint(x: 240.07, y: 343.87), controlPoint1: CGPoint(x: 239.26, y: 338.23), controlPoint2: CGPoint(x: 241.08, y: 342.41))
                    leftHandPath.addCurve(to: CGPoint(x: 230.12, y: 335.61), controlPoint1: CGPoint(x: 239.06, y: 345.32), controlPoint2: CGPoint(x: 232.76, y: 340.53))
                    leftHandPath.addCurve(to: CGPoint(x: 233.41, y: 358.87), controlPoint1: CGPoint(x: 229.48, y: 334.42), controlPoint2: CGPoint(x: 233.41, y: 358.87))
                    leftHandPath.addCurve(to: CGPoint(x: 231.95, y: 364), controlPoint1: CGPoint(x: 233.41, y: 358.87), controlPoint2: CGPoint(x: 233.85, y: 363.44))
                    leftHandPath.addCurve(to: CGPoint(x: 228.73, y: 360.54), controlPoint1: CGPoint(x: 230.05, y: 364.56), controlPoint2: CGPoint(x: 229.28, y: 362.88))
                    leftHandPath.addCurve(to: CGPoint(x: 223.96, y: 342.72), controlPoint1: CGPoint(x: 226.99, y: 353.12), controlPoint2: CGPoint(x: 225.08, y: 342.52))
                    leftHandPath.addCurve(to: CGPoint(x: 227.02, y: 363.2), controlPoint1: CGPoint(x: 222.85, y: 342.92), controlPoint2: CGPoint(x: 227.02, y: 363.2))
                    leftHandPath.addCurve(to: CGPoint(x: 225.71, y: 367.15), controlPoint1: CGPoint(x: 227.02, y: 363.2), controlPoint2: CGPoint(x: 227.86, y: 366.65))
                    leftHandPath.addCurve(to: CGPoint(x: 222.79, y: 363.64), controlPoint1: CGPoint(x: 223.56, y: 367.66), controlPoint2: CGPoint(x: 222.79, y: 363.64))
                    leftHandPath.addCurve(to: CGPoint(x: 217.36, y: 343.5), controlPoint1: CGPoint(x: 222.79, y: 363.64), controlPoint2: CGPoint(x: 218.36, y: 343.38))
                    leftHandPath.addCurve(to: CGPoint(x: 220.03, y: 363.27), controlPoint1: CGPoint(x: 216.6, y: 343.59), controlPoint2: CGPoint(x: 219.32, y: 357.75))
                    leftHandPath.addCurve(to: CGPoint(x: 218.91, y: 366.73), controlPoint1: CGPoint(x: 220.25, y: 364.98), controlPoint2: CGPoint(x: 220.57, y: 366.25))
                    leftHandPath.addCurve(to: CGPoint(x: 216.08, y: 363.77), controlPoint1: CGPoint(x: 217.37, y: 367.17), controlPoint2: CGPoint(x: 216.66, y: 365.4))
                    leftHandPath.addCurve(to: CGPoint(x: 210.68, y: 343.75), controlPoint1: CGPoint(x: 214.06, y: 358.09), controlPoint2: CGPoint(x: 211.56, y: 343.53))
                    leftHandPath.addCurve(to: CGPoint(x: 211.67, y: 358.09), controlPoint1: CGPoint(x: 209.84, y: 343.96), controlPoint2: CGPoint(x: 210.68, y: 352.34))
                    leftHandPath.addCurve(to: CGPoint(x: 210.51, y: 363.04), controlPoint1: CGPoint(x: 212.01, y: 360.09), controlPoint2: CGPoint(x: 213.04, y: 362.65))
                    leftHandPath.addCurve(to: CGPoint(x: 207.55, y: 358.3), controlPoint1: CGPoint(x: 208.17, y: 363.4), controlPoint2: CGPoint(x: 207.55, y: 358.3))
                    leftHandPath.addCurve(to: CGPoint(x: 203.48, y: 340.95), controlPoint1: CGPoint(x: 207.55, y: 358.3), controlPoint2: CGPoint(x: 203.85, y: 343.59))
                    leftHandPath.addCurve(to: CGPoint(x: 200.12, y: 315.54), controlPoint1: CGPoint(x: 203.1, y: 338.3), controlPoint2: CGPoint(x: 199.17, y: 326.66))
                    leftHandPath.addCurve(to: CGPoint(x: 199.17, y: 309.5), controlPoint1: CGPoint(x: 200.15, y: 315.21), controlPoint2: CGPoint(x: 199.58, y: 310.95))
                    leftHandPath.addCurve(to: CGPoint(x: 220.12, y: 309.5), controlPoint1: CGPoint(x: 199.17, y: 309.5), controlPoint2: CGPoint(x: 208.44, y: 304.2))
                    leftHandPath.addLine(to: CGPoint(x: 220.1, y: 309.48))
                    leftHandPath.close()
                    return leftHandPath

                case .rightArm:
                    let fullRightArmPath = UIBezierPath()
                    fullRightArmPath.move(to: CGPoint(x: 54.9, y: 128.21))
                    fullRightArmPath.addCurve(to: CGPoint(x: 39.5, y: 167.44), controlPoint1: CGPoint(x: 50.37, y: 132.42), controlPoint2: CGPoint(x: 42.51, y: 145.18))
                    fullRightArmPath.addCurve(to: CGPoint(x: 35.37, y: 211.56), controlPoint1: CGPoint(x: 36.5, y: 189.69), controlPoint2: CGPoint(x: 35.74, y: 209.29))
                    fullRightArmPath.addCurve(to: CGPoint(x: 32.37, y: 231.17), controlPoint1: CGPoint(x: 34.99, y: 213.82), controlPoint2: CGPoint(x: 32.37, y: 231.17))
                    fullRightArmPath.addLine(to: CGPoint(x: 32.32, y: 231.25))
                    fullRightArmPath.addLine(to: CGPoint(x: 28.69, y: 255.75))
                    fullRightArmPath.addCurve(to: CGPoint(x: 28.88, y: 255.21), controlPoint1: CGPoint(x: 28.71, y: 255.56), controlPoint2: CGPoint(x: 28.78, y: 255.38))
                    fullRightArmPath.addCurve(to: CGPoint(x: 28.74, y: 255.67), controlPoint1: CGPoint(x: 28.81, y: 255.36), controlPoint2: CGPoint(x: 28.76, y: 255.51))
                    fullRightArmPath.addCurve(to: CGPoint(x: 19.91, y: 309.93), controlPoint1: CGPoint(x: 26.13, y: 275.67), controlPoint2: CGPoint(x: 19.91, y: 309.93))
                    fullRightArmPath.addCurve(to: CGPoint(x: 40.86, y: 309.93), controlPoint1: CGPoint(x: 31.5, y: 304.63), controlPoint2: CGPoint(x: 40.86, y: 309.93))
                    fullRightArmPath.addCurve(to: CGPoint(x: 58.28, y: 256.07), controlPoint1: CGPoint(x: 43.57, y: 299.55), controlPoint2: CGPoint(x: 57.08, y: 263.29))
                    fullRightArmPath.addCurve(to: CGPoint(x: 58.23, y: 255.93), controlPoint1: CGPoint(x: 58.28, y: 256.03), controlPoint2: CGPoint(x: 58.26, y: 255.98))
                    fullRightArmPath.addCurve(to: CGPoint(x: 62.08, y: 232.81), controlPoint1: CGPoint(x: 58.76, y: 252.76), controlPoint2: CGPoint(x: 60.31, y: 243.52))
                    fullRightArmPath.addCurve(to: CGPoint(x: 62.22, y: 232.38), controlPoint1: CGPoint(x: 62.15, y: 232.67), controlPoint2: CGPoint(x: 62.2, y: 232.53))
                    fullRightArmPath.addCurve(to: CGPoint(x: 65.79, y: 210.26), controlPoint1: CGPoint(x: 64.7, y: 217.39), controlPoint2: CGPoint(x: 65.79, y: 210.26))
                    fullRightArmPath.addLine(to: CGPoint(x: 69.59, y: 187.15))
                    fullRightArmPath.addCurve(to: CGPoint(x: 62.73, y: 153.05), controlPoint1: CGPoint(x: 68.34, y: 181.81), controlPoint2: CGPoint(x: 65.63, y: 164.62))
                    fullRightArmPath.addCurve(to: CGPoint(x: 54.89, y: 128.22), controlPoint1: CGPoint(x: 58.9, y: 137.78), controlPoint2: CGPoint(x: 54.89, y: 128.22))
                    fullRightArmPath.addLine(to: CGPoint(x: 54.9, y: 128.21))
                    fullRightArmPath.close()

                    return fullRightArmPath

                case .rightArmFold:
                    let rightArmfoldPath = UIBezierPath()
                    rightArmfoldPath.move(to: CGPoint(x: 28.99, y: 255.87))
                    rightArmfoldPath.addCurve(to: CGPoint(x: 58.52, y: 256.11), controlPoint1: CGPoint(x: 35.3, y: 253.97), controlPoint2: CGPoint(x: 54.78, y: 254.24))
                    rightArmfoldPath.addCurve(to: CGPoint(x: 62.61, y: 231.62), controlPoint1: CGPoint(x: 59.33, y: 252.21), controlPoint2: CGPoint(x: 61.84, y: 236.24))
                    rightArmfoldPath.addCurve(to: CGPoint(x: 32.77, y: 230.3), controlPoint1: CGPoint(x: 58.04, y: 233.93), controlPoint2: CGPoint(x: 39.69, y: 235.22))
                    rightArmfoldPath.addLine(to: CGPoint(x: 28.99, y: 255.87))
                    rightArmfoldPath.close()

                    return rightArmfoldPath

                case .rightUnderArm:
                    let rightUnderArmPath = UIBezierPath()
                    rightUnderArmPath.move(to: CGPoint(x: 58.4, y: 256.05))
                    rightUnderArmPath.addCurve(to: CGPoint(x: 29.17, y: 255.82), controlPoint1: CGPoint(x: 54.9, y: 254.3), controlPoint2: CGPoint(x: 35.66, y: 253.86))
                    rightUnderArmPath.addLine(to: CGPoint(x: 28.99, y: 255.87))
                    rightUnderArmPath.addCurve(to: CGPoint(x: 20.25, y: 309.46), controlPoint1: CGPoint(x: 26.33, y: 275.95), controlPoint2: CGPoint(x: 20.25, y: 309.46))
                    rightUnderArmPath.addCurve(to: CGPoint(x: 41.2, y: 309.46), controlPoint1: CGPoint(x: 31.84, y: 304.16), controlPoint2: CGPoint(x: 41.2, y: 309.46))
                    rightUnderArmPath.addCurve(to: CGPoint(x: 58.52, y: 256.11), controlPoint1: CGPoint(x: 43.85, y: 299.3), controlPoint2: CGPoint(x: 56.85, y: 264.35))
                    rightUnderArmPath.addLine(to: CGPoint(x: 58.4, y: 256.05))
                    rightUnderArmPath.close()

                    return rightUnderArmPath

                case .rightUpperArm:
                    let rightUpperArmPath = UIBezierPath()
                    rightUpperArmPath.move(to: CGPoint(x: 63.08, y: 152.59))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 55.24, y: 127.76), controlPoint1: CGPoint(x: 59.25, y: 137.32), controlPoint2: CGPoint(x: 55.24, y: 127.76))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 39.84, y: 166.99), controlPoint1: CGPoint(x: 50.71, y: 131.97), controlPoint2: CGPoint(x: 42.85, y: 144.74))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 35.71, y: 211.11), controlPoint1: CGPoint(x: 36.84, y: 189.24), controlPoint2: CGPoint(x: 36.08, y: 208.84))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 32.77, y: 230.31), controlPoint1: CGPoint(x: 35.37, y: 213.17), controlPoint2: CGPoint(x: 33.17, y: 227.69))
                    rightUpperArmPath.addLine(to: CGPoint(x: 32.94, y: 230.43))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 62.28, y: 231.79), controlPoint1: CGPoint(x: 39.79, y: 235.3), controlPoint2: CGPoint(x: 57.92, y: 234))
                    rightUpperArmPath.addLine(to: CGPoint(x: 62.61, y: 231.63))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 66.14, y: 209.81), controlPoint1: CGPoint(x: 65.05, y: 216.85), controlPoint2: CGPoint(x: 66.14, y: 209.81))
                    rightUpperArmPath.addLine(to: CGPoint(x: 69.94, y: 186.69))
                    rightUpperArmPath.addCurve(to: CGPoint(x: 63.08, y: 152.59), controlPoint1: CGPoint(x: 68.69, y: 181.36), controlPoint2: CGPoint(x: 65.98, y: 164.17))
                    rightUpperArmPath.close()

                    return rightUpperArmPath

                case .rightPalm:
                    let rightHandPath = UIBezierPath()
                    rightHandPath.move(to: CGPoint(x: 20.25, y: 309.51))
                    rightHandPath.addCurve(to: CGPoint(x: 9.76, y: 322.06), controlPoint1: CGPoint(x: 20.25, y: 309.51), controlPoint2: CGPoint(x: 13.65, y: 318.5))
                    rightHandPath.addCurve(to: CGPoint(x: 4.42, y: 332.21), controlPoint1: CGPoint(x: 7.95, y: 324.23), controlPoint2: CGPoint(x: 6.42, y: 328.57))
                    rightHandPath.addCurve(to: CGPoint(x: 0.28, y: 343.9), controlPoint1: CGPoint(x: 1.09, y: 338.26), controlPoint2: CGPoint(x: -0.73, y: 342.44))
                    rightHandPath.addCurve(to: CGPoint(x: 10.23, y: 335.64), controlPoint1: CGPoint(x: 1.29, y: 345.35), controlPoint2: CGPoint(x: 7.59, y: 340.56))
                    rightHandPath.addCurve(to: CGPoint(x: 6.94, y: 358.9), controlPoint1: CGPoint(x: 10.87, y: 334.45), controlPoint2: CGPoint(x: 6.94, y: 358.9))
                    rightHandPath.addCurve(to: CGPoint(x: 8.4, y: 364.03), controlPoint1: CGPoint(x: 6.94, y: 358.9), controlPoint2: CGPoint(x: 6.5, y: 363.47))
                    rightHandPath.addCurve(to: CGPoint(x: 11.62, y: 360.57), controlPoint1: CGPoint(x: 10.3, y: 364.59), controlPoint2: CGPoint(x: 11.07, y: 362.91))
                    rightHandPath.addCurve(to: CGPoint(x: 16.39, y: 342.75), controlPoint1: CGPoint(x: 13.36, y: 353.15), controlPoint2: CGPoint(x: 15.27, y: 342.55))
                    rightHandPath.addCurve(to: CGPoint(x: 13.33, y: 363.23), controlPoint1: CGPoint(x: 17.5, y: 342.95), controlPoint2: CGPoint(x: 13.33, y: 363.23))
                    rightHandPath.addCurve(to: CGPoint(x: 14.64, y: 367.18), controlPoint1: CGPoint(x: 13.33, y: 363.23), controlPoint2: CGPoint(x: 12.49, y: 366.68))
                    rightHandPath.addCurve(to: CGPoint(x: 17.56, y: 363.67), controlPoint1: CGPoint(x: 16.79, y: 367.69), controlPoint2: CGPoint(x: 17.56, y: 363.67))
                    rightHandPath.addCurve(to: CGPoint(x: 22.99, y: 343.53), controlPoint1: CGPoint(x: 17.56, y: 363.67), controlPoint2: CGPoint(x: 21.99, y: 343.41))
                    rightHandPath.addCurve(to: CGPoint(x: 20.32, y: 363.3), controlPoint1: CGPoint(x: 23.75, y: 343.62), controlPoint2: CGPoint(x: 21.03, y: 357.78))
                    rightHandPath.addCurve(to: CGPoint(x: 21.44, y: 366.76), controlPoint1: CGPoint(x: 20.1, y: 365.01), controlPoint2: CGPoint(x: 19.78, y: 366.28))
                    rightHandPath.addCurve(to: CGPoint(x: 24.27, y: 363.8), controlPoint1: CGPoint(x: 22.98, y: 367.2), controlPoint2: CGPoint(x: 23.69, y: 365.43))
                    rightHandPath.addCurve(to: CGPoint(x: 29.67, y: 343.78), controlPoint1: CGPoint(x: 26.29, y: 358.12), controlPoint2: CGPoint(x: 28.79, y: 343.56))
                    rightHandPath.addCurve(to: CGPoint(x: 28.68, y: 358.12), controlPoint1: CGPoint(x: 30.51, y: 343.99), controlPoint2: CGPoint(x: 29.67, y: 352.37))
                    rightHandPath.addCurve(to: CGPoint(x: 29.84, y: 363.07), controlPoint1: CGPoint(x: 28.34, y: 360.12), controlPoint2: CGPoint(x: 27.31, y: 362.68))
                    rightHandPath.addCurve(to: CGPoint(x: 32.8, y: 358.33), controlPoint1: CGPoint(x: 32.18, y: 363.43), controlPoint2: CGPoint(x: 32.8, y: 358.33))
                    rightHandPath.addCurve(to: CGPoint(x: 36.87, y: 340.98), controlPoint1: CGPoint(x: 32.8, y: 358.33), controlPoint2: CGPoint(x: 36.5, y: 343.62))
                    rightHandPath.addCurve(to: CGPoint(x: 40.23, y: 315.57), controlPoint1: CGPoint(x: 37.25, y: 338.33), controlPoint2: CGPoint(x: 41.18, y: 326.69))
                    rightHandPath.addCurve(to: CGPoint(x: 41.18, y: 309.53), controlPoint1: CGPoint(x: 40.2, y: 315.24), controlPoint2: CGPoint(x: 40.77, y: 310.98))
                    rightHandPath.addCurve(to: CGPoint(x: 20.23, y: 309.53), controlPoint1: CGPoint(x: 41.18, y: 309.53), controlPoint2: CGPoint(x: 31.91, y: 304.23))
                    rightHandPath.addLine(to: CGPoint(x: 20.25, y: 309.51))
                    rightHandPath.close()

                    return rightHandPath

                case .rightLeg:
                    let fullRightLegPath = UIBezierPath()
                    fullRightLegPath.move(to: CGPoint(x: 113.06, y: 475.37))
                    fullRightLegPath.addCurve(to: CGPoint(x: 113.23, y: 450.47), controlPoint1: CGPoint(x: 112.54, y: 470.07), controlPoint2: CGPoint(x: 113.23, y: 450.47))
                    fullRightLegPath.addCurve(to: CGPoint(x: 113.28, y: 450.43), controlPoint1: CGPoint(x: 113.25, y: 450.46), controlPoint2: CGPoint(x: 113.26, y: 450.45))
                    fullRightLegPath.addCurve(to: CGPoint(x: 117.98, y: 349.29), controlPoint1: CGPoint(x: 113.28, y: 450.43), controlPoint2: CGPoint(x: 116.37, y: 368.17))
                    fullRightLegPath.addCurve(to: CGPoint(x: 60.7, y: 329.78), controlPoint1: CGPoint(x: 117.98, y: 349.29), controlPoint2: CGPoint(x: 66.04, y: 347.6))
                    fullRightLegPath.addCurve(to: CGPoint(x: 64.46, y: 399.11), controlPoint1: CGPoint(x: 58.31, y: 321.8), controlPoint2: CGPoint(x: 61.64, y: 387.63))
                    fullRightLegPath.addCurve(to: CGPoint(x: 74.06, y: 451.52), controlPoint1: CGPoint(x: 67, y: 409.48), controlPoint2: CGPoint(x: 74.06, y: 451.52))
                    fullRightLegPath.addCurve(to: CGPoint(x: 74.1, y: 451.55), controlPoint1: CGPoint(x: 74.07, y: 451.53), controlPoint2: CGPoint(x: 74.09, y: 451.54))
                    fullRightLegPath.addCurve(to: CGPoint(x: 76.84, y: 469.29), controlPoint1: CGPoint(x: 75.72, y: 461.51), controlPoint2: CGPoint(x: 76.63, y: 466.73))
                    fullRightLegPath.addCurve(to: CGPoint(x: 74.94, y: 487.82), controlPoint1: CGPoint(x: 77.05, y: 471.85), controlPoint2: CGPoint(x: 75.83, y: 478.29))
                    fullRightLegPath.addCurve(to: CGPoint(x: 74.99, y: 487.74), controlPoint1: CGPoint(x: 74.95, y: 487.79), controlPoint2: CGPoint(x: 74.97, y: 487.77))
                    fullRightLegPath.addCurve(to: CGPoint(x: 73.89, y: 513.64), controlPoint1: CGPoint(x: 74.79, y: 488.17), controlPoint2: CGPoint(x: 73.3, y: 509.95))
                    fullRightLegPath.addCurve(to: CGPoint(x: 94, y: 603.17), controlPoint1: CGPoint(x: 74.81, y: 531.68), controlPoint2: CGPoint(x: 93.56, y: 583.92))
                    fullRightLegPath.addCurve(to: CGPoint(x: 92.87, y: 609.57), controlPoint1: CGPoint(x: 93.76, y: 605.38), controlPoint2: CGPoint(x: 93.38, y: 607.52))
                    fullRightLegPath.addCurve(to: CGPoint(x: 92.62, y: 610.79), controlPoint1: CGPoint(x: 92.77, y: 609.98), controlPoint2: CGPoint(x: 92.62, y: 610.79))
                    fullRightLegPath.addCurve(to: CGPoint(x: 112.23, y: 610.79), controlPoint1: CGPoint(x: 103.07, y: 616.31), controlPoint2: CGPoint(x: 112.23, y: 610.79))
                    fullRightLegPath.addCurve(to: CGPoint(x: 113.06, y: 475.36), controlPoint1: CGPoint(x: 113.09, y: 586.65), controlPoint2: CGPoint(x: 114.86, y: 493.72))
                    fullRightLegPath.addLine(to: CGPoint(x: 113.06, y: 475.37))
                    fullRightLegPath.close()

                    return fullRightLegPath.reversing()

                case .rightThigh:
                    let rightThighPath = UIBezierPath()
                    rightThighPath.move(to: CGPoint(x: 60.58, y: 330.21))
                    rightThighPath.addCurve(to: CGPoint(x: 117.86, y: 349.72), controlPoint1: CGPoint(x: 65.93, y: 348.03), controlPoint2: CGPoint(x: 117.86, y: 349.72))
                    rightThighPath.addCurve(to: CGPoint(x: 113.09, y: 451.48), controlPoint1: CGPoint(x: 116.25, y: 368.59), controlPoint2: CGPoint(x: 113.11, y: 451.11))
                    rightThighPath.addCurve(to: CGPoint(x: 74.02, y: 452.29), controlPoint1: CGPoint(x: 102.3, y: 457.05), controlPoint2: CGPoint(x: 85.16, y: 457.56))
                    rightThighPath.addCurve(to: CGPoint(x: 64.32, y: 399.54), controlPoint1: CGPoint(x: 74, y: 452.19), controlPoint2: CGPoint(x: 66.87, y: 409.91))
                    rightThighPath.addCurve(to: CGPoint(x: 60.56, y: 330.21), controlPoint1: CGPoint(x: 61.51, y: 388.05), controlPoint2: CGPoint(x: 58.17, y: 322.22))
                    rightThighPath.addLine(to: CGPoint(x: 60.58, y: 330.21))
                    rightThighPath.close()

                    return rightThighPath

                case .rightKnee:
                    let rightKneePath = UIBezierPath()
                    rightKneePath.move(to: CGPoint(x: 74.03, y: 452.29))
                    rightKneePath.addCurve(to: CGPoint(x: 113.1, y: 451.48), controlPoint1: CGPoint(x: 85.17, y: 457.56), controlPoint2: CGPoint(x: 102.3, y: 457.06))
                    rightKneePath.addCurve(to: CGPoint(x: 112.95, y: 475.79), controlPoint1: CGPoint(x: 113.1, y: 451.48), controlPoint2: CGPoint(x: 112.43, y: 470.51))
                    rightKneePath.addLine(to: CGPoint(x: 113.53, y: 488.71))
                    rightKneePath.addCurve(to: CGPoint(x: 74.93, y: 487.15), controlPoint1: CGPoint(x: 105.96, y: 487.18), controlPoint2: CGPoint(x: 82.47, y: 485.48))
                    rightKneePath.addCurve(to: CGPoint(x: 76.73, y: 469.71), controlPoint1: CGPoint(x: 75.81, y: 478.22), controlPoint2: CGPoint(x: 76.94, y: 472.17))
                    rightKneePath.addLine(to: CGPoint(x: 74.04, y: 452.28))
                    rightKneePath.addLine(to: CGPoint(x: 74.03, y: 452.29))
                    rightKneePath.close()

                    return rightKneePath

                case .rightCalf:
                    let rightCalfPath = UIBezierPath()
                    rightCalfPath.move(to: CGPoint(x: 74.82, y: 488.24))
                    rightCalfPath.addCurve(to: CGPoint(x: 74.92, y: 487.17), controlPoint1: CGPoint(x: 74.85, y: 487.87), controlPoint2: CGPoint(x: 74.89, y: 487.52))
                    rightCalfPath.addCurve(to: CGPoint(x: 113.52, y: 488.73), controlPoint1: CGPoint(x: 82.46, y: 485.5), controlPoint2: CGPoint(x: 105.95, y: 487.19))
                    rightCalfPath.addCurve(to: CGPoint(x: 112.1, y: 611.22), controlPoint1: CGPoint(x: 114.21, y: 520.67), controlPoint2: CGPoint(x: 112.83, y: 590.74))
                    rightCalfPath.addCurve(to: CGPoint(x: 92.49, y: 611.22), controlPoint1: CGPoint(x: 112.1, y: 611.22), controlPoint2: CGPoint(x: 102.94, y: 616.75))
                    rightCalfPath.addCurve(to: CGPoint(x: 92.74, y: 610.01), controlPoint1: CGPoint(x: 92.49, y: 611.22), controlPoint2: CGPoint(x: 92.64, y: 610.42))
                    rightCalfPath.addCurve(to: CGPoint(x: 93.87, y: 603.61), controlPoint1: CGPoint(x: 93.25, y: 607.94), controlPoint2: CGPoint(x: 93.63, y: 605.81))
                    rightCalfPath.addCurve(to: CGPoint(x: 73.76, y: 514.08), controlPoint1: CGPoint(x: 93.43, y: 584.35), controlPoint2: CGPoint(x: 74.68, y: 532.12))
                    rightCalfPath.addCurve(to: CGPoint(x: 74.86, y: 488.17), controlPoint1: CGPoint(x: 73.17, y: 510.39), controlPoint2: CGPoint(x: 74.66, y: 488.6))
                    rightCalfPath.addCurve(to: CGPoint(x: 74.81, y: 488.25), controlPoint1: CGPoint(x: 74.85, y: 488.2), controlPoint2: CGPoint(x: 74.83, y: 488.22))
                    rightCalfPath.addLine(to: CGPoint(x: 74.82, y: 488.24))
                    rightCalfPath.close()

                    return rightCalfPath

                case .rightFoot:
                    let rightFootPath = UIBezierPath()
                    rightFootPath.move(to: CGPoint(x: 112.1, y: 611.54))
                    rightFootPath.addCurve(to: CGPoint(x: 103, y: 613.98), controlPoint1: CGPoint(x: 112.1, y: 611.54), controlPoint2: CGPoint(x: 108.4, y: 613.67))
                    rightFootPath.addCurve(to: CGPoint(x: 92.49, y: 611.54), controlPoint1: CGPoint(x: 97.66, y: 614.28), controlPoint2: CGPoint(x: 92.49, y: 611.54))
                    rightFootPath.addCurve(to: CGPoint(x: 90.7, y: 621.44), controlPoint1: CGPoint(x: 91.84, y: 615.12), controlPoint2: CGPoint(x: 92.12, y: 618.33))
                    rightFootPath.addCurve(to: CGPoint(x: 73.12, y: 637.05), controlPoint1: CGPoint(x: 87.69, y: 628), controlPoint2: CGPoint(x: 74.42, y: 635.93))
                    rightFootPath.addCurve(to: CGPoint(x: 66.9, y: 643.29), controlPoint1: CGPoint(x: 72.41, y: 637.66), controlPoint2: CGPoint(x: 67.36, y: 641.71))
                    rightFootPath.addCurve(to: CGPoint(x: 67.47, y: 648.08), controlPoint1: CGPoint(x: 66.38, y: 645.06), controlPoint2: CGPoint(x: 66.5, y: 648.08))
                    rightFootPath.addCurve(to: CGPoint(x: 68.28, y: 648), controlPoint1: CGPoint(x: 67.95, y: 648.08), controlPoint2: CGPoint(x: 67.96, y: 648.25))
                    rightFootPath.addCurve(to: CGPoint(x: 67.87, y: 648.99), controlPoint1: CGPoint(x: 68.09, y: 648.29), controlPoint2: CGPoint(x: 67.92, y: 648.64))
                    rightFootPath.addCurve(to: CGPoint(x: 69.24, y: 652.75), controlPoint1: CGPoint(x: 67.52, y: 651.35), controlPoint2: CGPoint(x: 68.3, y: 652.61))
                    rightFootPath.addCurve(to: CGPoint(x: 71.52, y: 652.09), controlPoint1: CGPoint(x: 70.26, y: 652.91), controlPoint2: CGPoint(x: 71.01, y: 652.54))
                    rightFootPath.addCurve(to: CGPoint(x: 71.04, y: 653.95), controlPoint1: CGPoint(x: 71.25, y: 652.59), controlPoint2: CGPoint(x: 71.02, y: 653.22))
                    rightFootPath.addCurve(to: CGPoint(x: 73.02, y: 656.24), controlPoint1: CGPoint(x: 71.07, y: 655.01), controlPoint2: CGPoint(x: 71.74, y: 655.94))
                    rightFootPath.addCurve(to: CGPoint(x: 74.96, y: 655.24), controlPoint1: CGPoint(x: 73.49, y: 656.35), controlPoint2: CGPoint(x: 74.22, y: 655.9))
                    rightFootPath.addCurve(to: CGPoint(x: 74.01, y: 657.13), controlPoint1: CGPoint(x: 74.35, y: 656.13), controlPoint2: CGPoint(x: 73.91, y: 656.9))
                    rightFootPath.addCurve(to: CGPoint(x: 76.59, y: 659.52), controlPoint1: CGPoint(x: 74.53, y: 658.39), controlPoint2: CGPoint(x: 75.39, y: 659.18))
                    rightFootPath.addCurve(to: CGPoint(x: 80.36, y: 658.93), controlPoint1: CGPoint(x: 78.11, y: 659.94), controlPoint2: CGPoint(x: 79.18, y: 659.63))
                    rightFootPath.addCurve(to: CGPoint(x: 84.62, y: 652.96), controlPoint1: CGPoint(x: 81.63, y: 658.16), controlPoint2: CGPoint(x: 83.71, y: 654.87))
                    rightFootPath.addCurve(to: CGPoint(x: 87.46, y: 649.98), controlPoint1: CGPoint(x: 86, y: 650.07), controlPoint2: CGPoint(x: 86.76, y: 649.85))
                    rightFootPath.addCurve(to: CGPoint(x: 85.14, y: 657.21), controlPoint1: CGPoint(x: 88.22, y: 650.12), controlPoint2: CGPoint(x: 85.37, y: 654.2))
                    rightFootPath.addCurve(to: CGPoint(x: 89.19, y: 661.61), controlPoint1: CGPoint(x: 85.03, y: 658.6), controlPoint2: CGPoint(x: 87.13, y: 661.18))
                    rightFootPath.addCurve(to: CGPoint(x: 97.2, y: 659.07), controlPoint1: CGPoint(x: 91.23, y: 662.05), controlPoint2: CGPoint(x: 95.7, y: 660.95))
                    rightFootPath.addCurve(to: CGPoint(x: 101.78, y: 648.87), controlPoint1: CGPoint(x: 98.7, y: 657.18), controlPoint2: CGPoint(x: 100.94, y: 650.97))
                    rightFootPath.addCurve(to: CGPoint(x: 107.32, y: 635.97), controlPoint1: CGPoint(x: 101.92, y: 648.51), controlPoint2: CGPoint(x: 103.86, y: 642.03))
                    rightFootPath.addCurve(to: CGPoint(x: 112.28, y: 630.99), controlPoint1: CGPoint(x: 108.39, y: 634.1), controlPoint2: CGPoint(x: 111.75, y: 633.43))
                    rightFootPath.addCurve(to: CGPoint(x: 111.81, y: 616.93), controlPoint1: CGPoint(x: 113.5, y: 625.35), controlPoint2: CGPoint(x: 110.93, y: 621.7))
                    rightFootPath.addCurve(to: CGPoint(x: 112.11, y: 611.56), controlPoint1: CGPoint(x: 111.91, y: 616.41), controlPoint2: CGPoint(x: 112.01, y: 614.51))
                    rightFootPath.addLine(to: CGPoint(x: 112.1, y: 611.54))
                    rightFootPath.close()

                    return rightFootPath

                case .leftLeg:
                    let fullLeftLegPath = UIBezierPath()
                    fullLeftLegPath.move(to: CGPoint(x: 127.68, y: 475.37))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 127.51, y: 450.47), controlPoint1: CGPoint(x: 128.2, y: 470.07), controlPoint2: CGPoint(x: 127.51, y: 450.47))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 127.46, y: 450.43), controlPoint1: CGPoint(x: 127.49, y: 450.46), controlPoint2: CGPoint(x: 127.48, y: 450.45))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 122.76, y: 349.29), controlPoint1: CGPoint(x: 127.46, y: 450.43), controlPoint2: CGPoint(x: 124.37, y: 368.17))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 180.04, y: 329.78), controlPoint1: CGPoint(x: 122.76, y: 349.29), controlPoint2: CGPoint(x: 174.7, y: 347.6))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 176.28, y: 399.11), controlPoint1: CGPoint(x: 182.43, y: 321.8), controlPoint2: CGPoint(x: 179.1, y: 387.63))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 166.68, y: 451.52), controlPoint1: CGPoint(x: 173.74, y: 409.48), controlPoint2: CGPoint(x: 166.68, y: 451.52))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 166.64, y: 451.55), controlPoint1: CGPoint(x: 166.67, y: 451.53), controlPoint2: CGPoint(x: 166.65, y: 451.54))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 163.9, y: 469.29), controlPoint1: CGPoint(x: 165.02, y: 461.51), controlPoint2: CGPoint(x: 164.11, y: 466.73))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 165.8, y: 487.82), controlPoint1: CGPoint(x: 163.69, y: 471.85), controlPoint2: CGPoint(x: 164.91, y: 478.29))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 165.75, y: 487.74), controlPoint1: CGPoint(x: 165.79, y: 487.79), controlPoint2: CGPoint(x: 165.77, y: 487.77))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 166.85, y: 513.64), controlPoint1: CGPoint(x: 165.95, y: 488.17), controlPoint2: CGPoint(x: 167.44, y: 509.95))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 146.74, y: 603.17), controlPoint1: CGPoint(x: 165.93, y: 531.68), controlPoint2: CGPoint(x: 147.18, y: 583.92))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 147.87, y: 609.57), controlPoint1: CGPoint(x: 146.98, y: 605.38), controlPoint2: CGPoint(x: 147.36, y: 607.52))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 148.12, y: 610.79), controlPoint1: CGPoint(x: 147.97, y: 609.98), controlPoint2: CGPoint(x: 148.12, y: 610.79))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 128.51, y: 610.79), controlPoint1: CGPoint(x: 137.67, y: 616.31), controlPoint2: CGPoint(x: 128.51, y: 610.79))
                    fullLeftLegPath.addCurve(to: CGPoint(x: 127.68, y: 475.36), controlPoint1: CGPoint(x: 127.65, y: 586.65), controlPoint2: CGPoint(x: 125.88, y: 493.72))
                    fullLeftLegPath.addLine(to: CGPoint(x: 127.68, y: 475.37))
                    fullLeftLegPath.close()


                    return fullLeftLegPath.reversing()

                case .leftThigh:
                    let leftThighPath = UIBezierPath()
                    leftThighPath.move(to: CGPoint(x: 180.04, y: 330.21))
                    leftThighPath.addCurve(to: CGPoint(x: 122.76, y: 349.72), controlPoint1: CGPoint(x: 174.69, y: 348.03), controlPoint2: CGPoint(x: 122.76, y: 349.72))
                    leftThighPath.addCurve(to: CGPoint(x: 127.53, y: 451.48), controlPoint1: CGPoint(x: 124.37, y: 368.59), controlPoint2: CGPoint(x: 127.51, y: 451.11))
                    leftThighPath.addCurve(to: CGPoint(x: 166.6, y: 452.29), controlPoint1: CGPoint(x: 138.32, y: 457.05), controlPoint2: CGPoint(x: 155.46, y: 457.56))
                    leftThighPath.addCurve(to: CGPoint(x: 176.3, y: 399.54), controlPoint1: CGPoint(x: 166.62, y: 452.19), controlPoint2: CGPoint(x: 173.75, y: 409.91))
                    leftThighPath.addCurve(to: CGPoint(x: 180.06, y: 330.21), controlPoint1: CGPoint(x: 179.11, y: 388.05), controlPoint2: CGPoint(x: 182.45, y: 322.22))
                    leftThighPath.addLine(to: CGPoint(x: 180.04, y: 330.21))
                    leftThighPath.close()
                    return leftThighPath

                case .leftKnee:
                    let leftKneePath = UIBezierPath()
                    leftKneePath.move(to: CGPoint(x: 166.59, y: 452.29))
                    leftKneePath.addCurve(to: CGPoint(x: 127.52, y: 451.48), controlPoint1: CGPoint(x: 155.45, y: 457.56), controlPoint2: CGPoint(x: 138.32, y: 457.06))
                    leftKneePath.addCurve(to: CGPoint(x: 127.67, y: 475.79), controlPoint1: CGPoint(x: 127.52, y: 451.48), controlPoint2: CGPoint(x: 128.19, y: 470.51))
                    leftKneePath.addLine(to: CGPoint(x: 127.09, y: 488.71))
                    leftKneePath.addCurve(to: CGPoint(x: 165.69, y: 487.15), controlPoint1: CGPoint(x: 134.66, y: 487.18), controlPoint2: CGPoint(x: 158.15, y: 485.48))
                    leftKneePath.addCurve(to: CGPoint(x: 163.89, y: 469.71), controlPoint1: CGPoint(x: 164.81, y: 478.22), controlPoint2: CGPoint(x: 163.68, y: 472.17))
                    leftKneePath.addLine(to: CGPoint(x: 166.58, y: 452.28))
                    leftKneePath.addLine(to: CGPoint(x: 166.59, y: 452.29))
                    leftKneePath.close()
                    return leftKneePath

                case .leftCalf:
                    let leftCalfPath = UIBezierPath()
                    leftCalfPath.move(to: CGPoint(x: 165.8, y: 488.24))
                    leftCalfPath.addCurve(to: CGPoint(x: 165.7, y: 487.17), controlPoint1: CGPoint(x: 165.77, y: 487.87), controlPoint2: CGPoint(x: 165.73, y: 487.52))
                    leftCalfPath.addCurve(to: CGPoint(x: 127.1, y: 488.73), controlPoint1: CGPoint(x: 158.16, y: 485.5), controlPoint2: CGPoint(x: 134.67, y: 487.19))
                    leftCalfPath.addCurve(to: CGPoint(x: 128.52, y: 611.22), controlPoint1: CGPoint(x: 126.41, y: 520.67), controlPoint2: CGPoint(x: 127.79, y: 590.74))
                    leftCalfPath.addCurve(to: CGPoint(x: 148.13, y: 611.22), controlPoint1: CGPoint(x: 128.52, y: 611.22), controlPoint2: CGPoint(x: 137.68, y: 616.75))
                    leftCalfPath.addCurve(to: CGPoint(x: 147.88, y: 610.01), controlPoint1: CGPoint(x: 148.13, y: 611.22), controlPoint2: CGPoint(x: 147.98, y: 610.42))
                    leftCalfPath.addCurve(to: CGPoint(x: 146.75, y: 603.61), controlPoint1: CGPoint(x: 147.37, y: 607.94), controlPoint2: CGPoint(x: 146.99, y: 605.81))
                    leftCalfPath.addCurve(to: CGPoint(x: 166.86, y: 514.08), controlPoint1: CGPoint(x: 147.19, y: 584.35), controlPoint2: CGPoint(x: 165.94, y: 532.12))
                    leftCalfPath.addCurve(to: CGPoint(x: 165.76, y: 488.17), controlPoint1: CGPoint(x: 167.45, y: 510.39), controlPoint2: CGPoint(x: 165.96, y: 488.6))
                    leftCalfPath.addCurve(to: CGPoint(x: 165.81, y: 488.25), controlPoint1: CGPoint(x: 165.77, y: 488.2), controlPoint2: CGPoint(x: 165.79, y: 488.22))
                    leftCalfPath.addLine(to: CGPoint(x: 165.8, y: 488.24))
                    leftCalfPath.close()
                    return leftCalfPath

                case .leftFoot:
                    let leftFootPath = UIBezierPath()
                    leftFootPath.move(to: CGPoint(x: 128.46, y: 611.54))
                    leftFootPath.addCurve(to: CGPoint(x: 137.56, y: 613.98), controlPoint1: CGPoint(x: 128.46, y: 611.54), controlPoint2: CGPoint(x: 132.16, y: 613.67))
                    leftFootPath.addCurve(to: CGPoint(x: 148.07, y: 611.54), controlPoint1: CGPoint(x: 142.9, y: 614.28), controlPoint2: CGPoint(x: 148.07, y: 611.54))
                    leftFootPath.addCurve(to: CGPoint(x: 149.86, y: 621.44), controlPoint1: CGPoint(x: 148.72, y: 615.12), controlPoint2: CGPoint(x: 148.44, y: 618.33))
                    leftFootPath.addCurve(to: CGPoint(x: 167.44, y: 637.05), controlPoint1: CGPoint(x: 152.87, y: 628), controlPoint2: CGPoint(x: 166.14, y: 635.93))
                    leftFootPath.addCurve(to: CGPoint(x: 173.66, y: 643.29), controlPoint1: CGPoint(x: 168.15, y: 637.66), controlPoint2: CGPoint(x: 173.2, y: 641.71))
                    leftFootPath.addCurve(to: CGPoint(x: 173.09, y: 648.08), controlPoint1: CGPoint(x: 174.18, y: 645.06), controlPoint2: CGPoint(x: 174.06, y: 648.08))
                    leftFootPath.addCurve(to: CGPoint(x: 172.28, y: 648), controlPoint1: CGPoint(x: 172.61, y: 648.08), controlPoint2: CGPoint(x: 172.6, y: 648.25))
                    leftFootPath.addCurve(to: CGPoint(x: 172.69, y: 648.99), controlPoint1: CGPoint(x: 172.47, y: 648.29), controlPoint2: CGPoint(x: 172.64, y: 648.64))
                    leftFootPath.addCurve(to: CGPoint(x: 171.32, y: 652.75), controlPoint1: CGPoint(x: 173.04, y: 651.35), controlPoint2: CGPoint(x: 172.26, y: 652.61))
                    leftFootPath.addCurve(to: CGPoint(x: 169.04, y: 652.09), controlPoint1: CGPoint(x: 170.3, y: 652.91), controlPoint2: CGPoint(x: 169.55, y: 652.54))
                    leftFootPath.addCurve(to: CGPoint(x: 169.52, y: 653.95), controlPoint1: CGPoint(x: 169.31, y: 652.59), controlPoint2: CGPoint(x: 169.54, y: 653.22))
                    leftFootPath.addCurve(to: CGPoint(x: 167.54, y: 656.24), controlPoint1: CGPoint(x: 169.49, y: 655.01), controlPoint2: CGPoint(x: 168.82, y: 655.94))
                    leftFootPath.addCurve(to: CGPoint(x: 165.6, y: 655.24), controlPoint1: CGPoint(x: 167.07, y: 656.35), controlPoint2: CGPoint(x: 166.34, y: 655.9))
                    leftFootPath.addCurve(to: CGPoint(x: 166.55, y: 657.13), controlPoint1: CGPoint(x: 166.21, y: 656.13), controlPoint2: CGPoint(x: 166.65, y: 656.9))
                    leftFootPath.addCurve(to: CGPoint(x: 163.97, y: 659.52), controlPoint1: CGPoint(x: 166.02, y: 658.39), controlPoint2: CGPoint(x: 165.16, y: 659.18))
                    leftFootPath.addCurve(to: CGPoint(x: 160.2, y: 658.93), controlPoint1: CGPoint(x: 162.45, y: 659.94), controlPoint2: CGPoint(x: 161.38, y: 659.63))
                    leftFootPath.addCurve(to: CGPoint(x: 155.94, y: 652.96), controlPoint1: CGPoint(x: 158.93, y: 658.16), controlPoint2: CGPoint(x: 156.85, y: 654.87))
                    leftFootPath.addCurve(to: CGPoint(x: 153.1, y: 649.98), controlPoint1: CGPoint(x: 154.56, y: 650.07), controlPoint2: CGPoint(x: 153.8, y: 649.85))
                    leftFootPath.addCurve(to: CGPoint(x: 155.42, y: 657.21), controlPoint1: CGPoint(x: 152.34, y: 650.12), controlPoint2: CGPoint(x: 155.19, y: 654.2))
                    leftFootPath.addCurve(to: CGPoint(x: 151.37, y: 661.61), controlPoint1: CGPoint(x: 155.53, y: 658.6), controlPoint2: CGPoint(x: 153.43, y: 661.18))
                    leftFootPath.addCurve(to: CGPoint(x: 143.36, y: 659.07), controlPoint1: CGPoint(x: 149.33, y: 662.05), controlPoint2: CGPoint(x: 144.86, y: 660.95))
                    leftFootPath.addCurve(to: CGPoint(x: 138.78, y: 648.87), controlPoint1: CGPoint(x: 141.86, y: 657.18), controlPoint2: CGPoint(x: 139.62, y: 650.97))
                    leftFootPath.addCurve(to: CGPoint(x: 133.24, y: 635.97), controlPoint1: CGPoint(x: 138.64, y: 648.51), controlPoint2: CGPoint(x: 136.7, y: 642.03))
                    leftFootPath.addCurve(to: CGPoint(x: 128.28, y: 630.99), controlPoint1: CGPoint(x: 132.17, y: 634.1), controlPoint2: CGPoint(x: 128.81, y: 633.43))
                    leftFootPath.addCurve(to: CGPoint(x: 128.75, y: 616.93), controlPoint1: CGPoint(x: 127.06, y: 625.35), controlPoint2: CGPoint(x: 129.63, y: 621.7))
                    leftFootPath.addCurve(to: CGPoint(x: 128.45, y: 611.56), controlPoint1: CGPoint(x: 128.65, y: 616.41), controlPoint2: CGPoint(x: 128.55, y: 614.51))
                    leftFootPath.addLine(to: CGPoint(x: 128.46, y: 611.54))
                    leftFootPath.close()

                    return leftFootPath
            }
        }

    }
}
