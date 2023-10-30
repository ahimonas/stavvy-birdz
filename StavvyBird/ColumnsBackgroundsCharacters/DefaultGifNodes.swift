//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit
import Foundation

class DefaultGifNodes: SKNode, Updatable, Playable, PhysicsContactable {
    

    var size: CGSize
    
    
    var delta: TimeInterval = 0
    var precedingMoment: TimeInterval = 0
    var willRenew: Bool = true
    
    var weighedDownByForce: Bool = true {
        didSet {
            physicsBody?.affectedByGravity = weighedDownByForce
        }
    }
    
    var isInteractable: Bool = true {
        didSet {
            self.isUserInteractionEnabled = isInteractable
        }
    }

    var shouldEnablePhysics: Bool = true {
        didSet {
            // Set the specified collision bit mask or 0 which basically disables all the collision testing
            physicsBody?.collisionBitMask = shouldEnablePhysics ? collisionBitMask : 0
        }
    }
    
    var collisionBitMask: UInt32 = PhysicsCategories.pipe.rawValue | PhysicsCategories.boundary.rawValue

    
    private let impact = UIImpactFeedbackGenerator(style: .medium)
    private var animatedGifNode: SKSpriteNode
    
    
    init(animatedGif name: String, correctAspectRatioFor width: CGFloat) {
        animatedGifNode = SKSpriteNode(withAnimatedGif: name, correctAspectRatioFor: width)
        size = animatedGifNode.size
        
        super.init()
        
        preparePlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        size = .zero
        animatedGifNode = SKSpriteNode(texture: nil, color: .clear, size: .zero)
        
        super.init(coder: aDecoder)
        
        guard let assetName = userData!["assetName"] as? String else {
            fatalError(#function + " asset name was not specified")
        }
        animatedGifNode = SKSpriteNode(withAnimatedGif: assetName, correctAspectRatioFor: 100)
        size = animatedGifNode.size
        
        preparePlayer()
    }
    
    
    private func preparePlayer() {
        animatedGifNode.name = self.name
        animatedGifNode.position = .zero
        animatedGifNode.zPosition = 50
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width - 32, height: size.height - 32))
        physicsBody?.categoryBitMask = PhysicsCategories.player.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategories.pipe.rawValue | PhysicsCategories.gap.rawValue | PhysicsCategories.boundary.rawValue
        physicsBody?.collisionBitMask = collisionBitMask
        
        physicsBody?.mass /= 7
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.0
        
        self.addChild(animatedGifNode)
    }
    
    
    func update(_ timeInterval: CFTimeInterval) {
        delta = precedingMoment == 0.0 ? 0.0 : timeInterval - precedingMoment
        precedingMoment = timeInterval

        guard let physicsBody = physicsBody else {return}
        let dyVeloc = physicsBody.velocity.dy

        let dxVeloc = physicsBody.velocity.dx
        let myCurrThresh: CGFloat = 300
        
        if dyVeloc > myCurrThresh {
            physicsBody.velocity = CGVector(dx: dxVeloc, dy: myCurrThresh)
        }
        
        let velocityValue = dyVeloc * (dyVeloc < 0 ? 0.0044 : 0.0022)
        zRotation = velocityValue.clamp(min: -0.33, max: 0.99)
    }
    
}


extension DefaultGifNodes: Touchable {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isInteractable { return }
        
        impact.impactOccurred()
        
        weighedDownByForce = true
        // Apply an impulse to the DY value of the physics body of the bird
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
    }
}
