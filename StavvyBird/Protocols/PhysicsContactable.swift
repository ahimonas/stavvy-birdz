//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit

protocol PhysicsContactable {
    var collisionBitMask: UInt32 { get }
    var shouldEnablePhysics: Bool { get set }
}
