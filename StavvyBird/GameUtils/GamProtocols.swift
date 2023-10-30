//  SounioTechnologies LLC
//  StavvyBird
import SpriteKit
import UIKit
import Foundation
import SpriteKit
import CoreGraphics
protocol Updatable: AnyObject {
    
    var delta: TimeInterval { get }
    var previousTiming: TimeInterval { get }
    var willRenew: Bool { get set }
    
    func update(_ currentTime: TimeInterval)
}


extension Updatable {
    func computeUpdatable(currentTime: TimeInterval) -> (delta: TimeInterval, previousTiming: TimeInterval) {
        let currDelta = (self.previousTiming == 0.0) ? 0.0 : currentTime - self.previousTiming
        let previousMarkTime = currentTime
        return (delta: currDelta, previousTiming: previousMarkTime)
    }
}


protocol Touchable: AnyObject {
        
    var shouldAcceptTouches: Bool { get set }
    
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    /*
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
     */
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    
    
}

extension Touchable {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    /*
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    */
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
}



protocol PlaySceneProtocol {
    var updatables: [Updatable] { get }
    var touchables: [Touchable] { get }
    
    var scene: SKScene? { get }
    init?(with scene: SKScene)
    
}



protocol Playable: AnyObject {
    var size: CGSize { get set }

    var isAffectedByGravity: Bool { get set }
}


protocol PhysicsContactable {
    var collisionBitMask: UInt32 { get }
    var shouldEnablePhysics: Bool { get set }
}
