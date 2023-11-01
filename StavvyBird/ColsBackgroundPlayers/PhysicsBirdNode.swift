//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit
import UIKit

class PhysicsBirdNode: SKSpriteNode, Updatable, Playable, PhysicsContactable {
    var delta: TimeInterval = 0 //c
    var previousTime: TimeInterval = 0
    var flyTextures: [SKTexture]? = nil //c
    
    var willRelive: Bool = true {didSet {if willRelive {animate(with: timeIntervalForDrawingFrames)} else {self.removeAllActions()}}}
    var isHeavy: Bool = true {didSet {self.physicsBody?.affectedByGravity = isHeavy}}
    var isInteractable: Bool = true {didSet {self.isUserInteractionEnabled = isInteractable}}
    var shouldEnablePhysics: Bool = true {didSet {physicsBody?.collisionBitMask = shouldEnablePhysics ? collisionBitMask : 0}}
    var collisionBitMask: UInt32 = BondaryMapping.pipe.rawValue | BondaryMapping.boundary.rawValue
        
    private(set) var timeIntervalForDrawingFrames: TimeInterval = 0
    private let impact = UIImpactFeedbackGenerator(style: .medium)
        
    convenience init(timeIntervalForDrawingFrames: TimeInterval, withTextureAtlas named: String, size: CGSize) {
        
        var textures = [SKTexture]()
        
        do {
            textures = try SKTextureAtlas.upload(named: named, beginIndex: 1) { name, index -> String in
                return "r_player\(index)"
            }
        } catch {
            debugPrint(#function + " Texture unabe to render: ", error)
        }
        
        self.init(texture: textures.first, color: .clear, size: size)
        self.timeIntervalForDrawingFrames = timeIntervalForDrawingFrames

        initPhysicsBoundary()
                self.flyTextures = textures
        self.texture = textures.first
        self.animate(with: timeIntervalForDrawingFrames)
    }
    
     func initPhysicsBoundary() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 20) //CHANGE THE SIZE OF THE BODY
        physicsBody?.categoryBitMask = BondaryMapping.player.rawValue
        physicsBody?.contactTestBitMask = BondaryMapping.pipe.rawValue | BondaryMapping.gap.rawValue | BondaryMapping.boundary.rawValue
        
        physicsBody?.collisionBitMask = BondaryMapping.pipe.rawValue | BondaryMapping.boundary.rawValue
        
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.0
    }
    
     func animate(with timing: TimeInterval) {
        guard let walkTextures = flyTextures else {
            return
        }
        
        let bumpMove = SKAction.animate(with: walkTextures, timePerFrame: timing, resize: false, restore: true)
        let threadAction = SKAction.repeatForever(bumpMove)
        self.run(threadAction)
    }
    
    
    func update(_ timeInterval: CFTimeInterval) {
        delta = previousTime == 0.0 ? 0.0 : timeInterval - previousTime
        previousTime = timeInterval
        
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
        isHeavy = true
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 133)) //the bounce force
    }
}
