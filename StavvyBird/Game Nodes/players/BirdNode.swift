//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit
import UIKit

class BirdNode: SKSpriteNode, Updatable, Playable, PhysicsContactable {
        
    var delta: TimeInterval = 0
    var previousTiming: TimeInterval = 0
    var willRenew: Bool = true {
        didSet {
            if willRenew {
                animate(with: animationTimeInterval)
            } else {
                self.removeAllActions()
            }
        }
    }
    
    var isAffectedByGravity: Bool = true {
        didSet {
            self.physicsBody?.affectedByGravity = isAffectedByGravity
        }
    }
    
    var shouldAcceptTouches: Bool = true {
        didSet {
            self.isUserInteractionEnabled = shouldAcceptTouches
        }
    }
    
    var shouldEnablePhysics: Bool = true {
        didSet {
            // Set the specified collision bit mask or 0 which basically disables all the collision testing
            physicsBody?.collisionBitMask = shouldEnablePhysics ? collisionBitMask : 0
        }
    }
    
    var collisionBitMask: UInt32 = GamePhysics.pipe.rawValue | GamePhysics.boundary.rawValue
        
    var flyTextures: [SKTexture]? = nil
    private(set) var animationTimeInterval: TimeInterval = 0
    private let impact = UIImpactFeedbackGenerator(style: .medium)
        
    convenience init(animationTimeInterval: TimeInterval, withTextureAtlas named: String, size: CGSize) {
        
        var textures = [SKTexture]()
        
        do {
            textures = try SKTextureAtlas.upload(named: named, beginIndex: 1) { name, index -> String in
                return "r_player\(index)"
            }
        } catch {
            debugPrint(#function + " Texture unabe to render: ", error)
        }
        
        self.init(texture: textures.first, color: .clear, size: size)
        self.animationTimeInterval = animationTimeInterval

        initPhysicsBoundary()
                self.flyTextures = textures
        self.texture = textures.first
        self.animate(with: animationTimeInterval)
    }
    
    // MARK: - Methods

    fileprivate func initPhysicsBoundary() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.7)
        physicsBody?.categoryBitMask = GamePhysics.player.rawValue
        physicsBody?.contactTestBitMask = GamePhysics.pipe.rawValue | GamePhysics.gap.rawValue | GamePhysics.boundary.rawValue
        
        physicsBody?.collisionBitMask = GamePhysics.pipe.rawValue | GamePhysics.boundary.rawValue
        
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.0
    }
    
    fileprivate func animate(with timing: TimeInterval) {
        guard let walkTextures = flyTextures else {
            return
        }
        
        let bumpMove = SKAction.animate(with: walkTextures, timePerFrame: timing, resize: false, restore: true)
        let threadAction = SKAction.repeatForever(bumpMove)
        self.run(threadAction)
    }
    
    
    func update(_ timeInterval: CFTimeInterval) {
        delta = previousTiming == 0.0 ? 0.0 : timeInterval - previousTiming
        previousTiming = timeInterval
        
        guard let physicsBody = physicsBody else {
            return
        }
        
        let dxVeloc = physicsBody.velocity.dx
        let dyVeloc = physicsBody.velocity.dy
        let myCurrThresh: CGFloat = 370 //amount of overall gravtiy 0 is heavy 500 is light
        
        
        if dyVeloc > myCurrThresh {
            self.physicsBody?.velocity = CGVector(dx: dxVeloc, dy: myCurrThresh)
        }

        let velocityValue = dyVeloc * (dyVeloc < 0 ? 0.006 : 0.0037)
        zRotation = velocityValue.clamp(min: -0.33, max: 0.99)
    }
    
}

extension BirdNode: Touchable {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !shouldAcceptTouches { return }
        impact.impactOccurred()
        isAffectedByGravity = true
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 133)) //the bounce force
    }
}
