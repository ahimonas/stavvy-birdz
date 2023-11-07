//  SounioTechnologies LLC
//  StavvyBird



import SpriteKit
import UIKit


//complete
class PhysicsBirdNode: SKSpriteNode, Updatable, Playable, PhysicsContactable {
    let zero = 0;
    var delta: TimeInterval = 0; var previousTime: TimeInterval = 0
    var skyPatternsForFlight: [SKTexture]? = nil //c
    var willRelive: Bool = true {didSet {if willRelive {animate(with: timeIntervalForDrawingFrames)} else {self.removeAllActions()}}}
    var isHeavy: Bool = true {didSet {self.physicsBody?.affectedByGravity = isHeavy}}
    var isInteractable: Bool = true {didSet {self.isUserInteractionEnabled = isInteractable}}
    var shouldEnablePhysics: Bool = true {didSet {physicsBody?.collisionBitMask = shouldEnablePhysics ? collisionBitMask : 0}}
    var collisionBitMask: UInt32 = EdgeMapping.block.rawValue | EdgeMapping.edges.rawValue  | EdgeMapping.bouncer.rawValue
    private(set) var timeIntervalForDrawingFrames: TimeInterval = 0
    let impact = UIImpactFeedbackGenerator(style: .medium)
    convenience init(timeIntervalForDrawingFrames: TimeInterval, withTextureAtlas named: String, size: CGSize) {
        
        var arrayOfSKT = [SKTexture]()
        
        do { arrayOfSKT = try SKTextureAtlas.upload(named: named, beginIndex: 1) { name, index -> String in
                return "c_sb\(index)" }
        } catch { debugPrint(#function + "wip - unable to render atlas ", error) }
        
        self.init(texture: arrayOfSKT.first, color: .clear, size: size); self.timeIntervalForDrawingFrames = timeIntervalForDrawingFrames
        initPhysicsBoundary()
        self.skyPatternsForFlight = arrayOfSKT; self.texture = arrayOfSKT.first; self.animate(with: timeIntervalForDrawingFrames)
    }
    
     func initPhysicsBoundary() {
         
         //skPhysicsBody was writting by Apple
         physicsBody = SKPhysicsBody(circleOfRadius: size.width / 3.5) //CHANGE THE SIZE OF THE BODY
        physicsBody?.categoryBitMask = EdgeMapping.characterX.rawValue
        physicsBody?.contactTestBitMask = EdgeMapping.block.rawValue | EdgeMapping.breaker.rawValue | EdgeMapping.edges.rawValue | EdgeMapping.bouncer.rawValue
        physicsBody?.collisionBitMask = EdgeMapping.block.rawValue | EdgeMapping.edges.rawValue | EdgeMapping.bouncer.rawValue
        physicsBody?.allowsRotation = false
         physicsBody?.restitution = 0.98
    }
    
     func animate(with timing: TimeInterval) {
        guard let walkTextures = skyPatternsForFlight else { return }
        let bumpMove = SKAction.animate(with: walkTextures, timePerFrame: timing, resize: false, restore: true)
         let threadAction = SKAction.repeatForever(bumpMove); self.run(threadAction)
    }
    var resetX: CGFloat = 0
    func update(_ timeInterval: CFTimeInterval) {
        if resetX == 0 {
            resetX = self.position.x
        }
        let defaultZero = 0.0
        delta = previousTime == defaultZero ? defaultZero : timeInterval - previousTime; previousTime = timeInterval
        guard let currPhysElem = physicsBody else { return }
        
        let dxVeloc = currPhysElem.velocity.dx;  let dyVeloc = currPhysElem.velocity.dy;  let myCurrThresh: CGFloat = 370
        if dyVeloc > myCurrThresh { self.physicsBody?.velocity = CGVector(dx: dxVeloc, dy: myCurrThresh) }
        let threshA = 0.006; let threshB = 0.0037; let velocityValue = dyVeloc * (dyVeloc < 0 ? threshA : threshB);
        let backRotation = -0.33; let forwardRotation = 0.99; zRotation = velocityValue.clamp(min: backRotation, max: forwardRotation)

        //move bird to reset x position
        if self.position.x != resetX {
            self.position.x = resetX
        }

    }
}
extension PhysicsBirdNode: Touchable {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isInteractable { return }
        //bounce force for applied impulse
        let bumpForward = 0; let bumpVerticle = 133; impact.impactOccurred(); isHeavy = true; physicsBody?.applyImpulse(CGVector(dx: bumpForward, dy: bumpVerticle))
    }
}
