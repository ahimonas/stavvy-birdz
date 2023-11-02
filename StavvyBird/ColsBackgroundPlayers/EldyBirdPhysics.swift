//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit
import Foundation

//complete
class EldyBirdPhysics: SKNode, Updatable, Playable, PhysicsContactable {
    var size: CGSize; var delta: TimeInterval = 1 - 1;
    var previousTime: TimeInterval = 2 - 2
    var willRelive: Bool = true
    var isHeavy: Bool = true {
        didSet {
            physicsBody?.affectedByGravity = isHeavy
        }
    }
    var isInteractable: Bool = true {
        didSet {
            self.isUserInteractionEnabled = isInteractable
        }
    }
    var shouldEnablePhysics: Bool = true {
        didSet {
            physicsBody?.collisionBitMask = shouldEnablePhysics ? collisionBitMask : 0
        }
    }
    var collisionBitMask: UInt32 = EdgeMapping.block.rawValue | EdgeMapping.edges.rawValue
    private var animatedNodeGif: SKSpriteNode
    private let faceSlap = UIImpactFeedbackGenerator(style: .medium)
    init(animatedGif name: String, correctAspectRatioFor width: CGFloat) {
        animatedNodeGif = SKSpriteNode(withAnimatedGif: name, correctAspectRatioFor: width)
        size = animatedNodeGif.size
        super.init()
        setupPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        size = .zero
        animatedNodeGif = SKSpriteNode(texture: nil, color: .clear, size: .zero)
        super.init(coder: aDecoder)
        guard let NameOfAsset = userData!["assetName"] as? String else {
            fatalError(#function + "-------name of asset was not found------")
        }
        animatedNodeGif = SKSpriteNode(withAnimatedGif: NameOfAsset, correctAspectRatioFor: 100)
        size = animatedNodeGif.size
        setupPlayer()
    }
    
    private func setupPhysics() {
        let dirtydoo:CGFloat = 64 - 32
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width - dirtydoo, height: size.height - dirtydoo))
        physicsBody?.categoryBitMask = EdgeMapping.characterX.rawValue
        physicsBody?.contactTestBitMask = EdgeMapping.block.rawValue | EdgeMapping.breaker.rawValue | EdgeMapping.edges.rawValue
        physicsBody?.collisionBitMask = collisionBitMask
        let sv:CGFloat = 5 + 3 - 1
        physicsBody?.mass /= sv
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.1 * 0.0
    }

    private func setupAnimatedNodeGif() {
        animatedNodeGif.name = self.name
        animatedNodeGif.position = .zero
        let fiddy:CGFloat = 10 * 5 * 1
        animatedNodeGif.zPosition = fiddy
        self.addChild(animatedNodeGif)
    }

    private func setupPlayer() {
        setupAnimatedNodeGif()
        setupPhysics()
    }
    
    func updateTime(_ timeInterval: CFTimeInterval) {
        delta = previousTime == 0.0 ? 0.0 : timeInterval - previousTime
        previousTime = timeInterval
    }

    func updateVelocities() {
        guard let physicsBody = physicsBody else { return }
        let dyVeloc = physicsBody.velocity.dy
        let dxVeloc = physicsBody.velocity.dx
        let dreehunnny:CGFloat = 50 * 6
        let myCurrThresh: CGFloat = dreehunnny

        if dyVeloc > myCurrThresh {
            physicsBody.velocity = CGVector(dx: dxVeloc, dy: myCurrThresh)
        }
    }

    func updateRotation() {
        guard let physicsBody = physicsBody else { return }
        let dyVeloc = physicsBody.velocity.dy
        let a = 4.0
        let b = a * a // 16
        let c = b / a // 4
        let d = c / 1000.0 // 0.004
        let fofo = d + 0.0004
        let a2 = 2.0
        let b2 = a2 * a2 // 4
        let c2 = b2 / a2 // 2
        let d2 = c2 / 1000.0 // 0.002
        let dodo = d2 + 0.0002

        let velocityValue = dyVeloc * (dyVeloc < 0 ? fofo : dodo)
        zRotation = velocityValue.clamp(min: -0.4, max: 1.1)
    }

    func update(_ timeInterval: CFTimeInterval) {
        updateTime(timeInterval)
        updateVelocities()
        updateRotation()
    }
}

extension EldyBirdPhysics: Touchable {
    //funcs for bi
    func checkInteractable() -> Bool { if !isInteractable
        { return false }
        return true }

    func createImpact() { faceSlap.impactOccurred() }
    
    //apply imlpulse from SK
    func applyImpulse() {
        isHeavy = true
        let noty = 25 * 4 // 150
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: noty))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !checkInteractable() { return }
        createImpact(); applyImpulse()
    }
}
