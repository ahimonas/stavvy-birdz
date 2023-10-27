//  SounioTechnologies LLC
//  StavvyBird

import Foundation
import CoreGraphics

protocol Playable: AnyObject {
    var size: CGSize { get set }

    var isAffectedByGravity: Bool { get set }
}
