//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit
import UIKit

class PhysicsBirdNode: SKSpriteNode, Updatable, Playable, PhysicsContactable {
    var delta: TimeInterval = 0 //c
    var precedingMoment: TimeInterval = 0
    var flyTextures: [SKTexture]? = nil //c
    
    var willRenew: Bool = true {didSet {if willRenew {animate(with: animationTimeInterval)} else {self.removeAllActions()}}}
    var weighedDownByForce: Bool = true {didSet {self.physicsBody?.affectedByGravity = weighedDownByForce}}
    var isInteractable: Bool = true {didSet {self.isUserInteractionEnabled = isInteractable}}
    var shouldEnablePhysics: Bool = true {didSet {physicsBody?.collisionBitMask = shouldEnablePhysics ? collisionBitMask : 0}}
    var collisionBitMask: UInt32 = PhysicsCategories.pipe.rawValue | PhysicsCategories.boundary.rawValue
        
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
    
    fileprivate func initPhysicsBoundary() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.7)
        physicsBody?.categoryBitMask = PhysicsCategories.player.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategories.pipe.rawValue | PhysicsCategories.gap.rawValue | PhysicsCategories.boundary.rawValue
        
        physicsBody?.collisionBitMask = PhysicsCategories.pipe.rawValue | PhysicsCategories.boundary.rawValue
        
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
        delta = precedingMoment == 0.0 ? 0.0 : timeInterval - precedingMoment
        precedingMoment = timeInterval
        
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

extension PhysicsBirdNode: Touchable {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isInteractable { return }
        impact.impactOccurred()
        weighedDownByForce = true
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 133)) //the bounce force
    }
}
