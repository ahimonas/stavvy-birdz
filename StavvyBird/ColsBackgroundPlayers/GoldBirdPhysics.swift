//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit
import Foundation

//complete
class GoldBirdPhysics: SKNode, Updatable, Playable, PhysicsContactable {
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
        let dirtydoo:CGFloat = 64 - 32 + 1
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width - dirtydoo, height: size.height - dirtydoo))
        physicsBody?.categoryBitMask = EdgeMapping.characterX.rawValue
        physicsBody?.contactTestBitMask = EdgeMapping.block.rawValue | EdgeMapping.breaker.rawValue | EdgeMapping.edges.rawValue
        physicsBody?.collisionBitMask = collisionBitMask
        let sv:CGFloat = 5 + 3 + 3 - 1
        physicsBody?.mass /= sv
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.2 * 0.0
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

        let randomRotate1 = CGFloat.range(min: -0.4, max: -0.1)
        let randomRotate2 = CGFloat.range(min: -0.22, max: 2.2)

        
        let velocityValue = dyVeloc * (dyVeloc < 0 ? fofo : dodo)
        //debugPrint(velocityValue)
        zRotation = velocityValue.clamp(min: -20, max: 0.99)
    }

    func update(_ timeInterval: CFTimeInterval) {
        updateTime(timeInterval)
        updateVelocities()
        updateRotation()
    }
}

extension GoldBirdPhysics: Touchable {
    //funcs for bi
    func checkInteractable() -> Bool { if !isInteractable
        { return false }
        return true }

    func createImpact() { 
        faceSlap.impactOccurred();
        debugPrint("hhhhhhh");
    }
    
    //apply imlpulse from SK
    func applyImpulse() {
        isHeavy = true
        let noty = 25 * 20 * 30 * 20 * 50 * 100// 150
        let weee = physicsBody?.node?.position.x.sign.rawValue;
        debugPrint("hhhhh")

        //let hi: double =  physicsBody?.node?.position.x.sign.rawValue + 0.1
        
       // let randomRotate1 =
       // CGFloat.range(min: 0, max: physicsBody?.node?.position.x.sign.rawValue + 1)
        guard var myVal22 = physicsBody?.node?.position.x.sign.rawValue else {return}

        guard var myVal = physicsBody?.velocity.dx else {return}

        
       debugPrint("myyyyyyy", myVal)
        
        
       debugPrint("myyyyyyy", myVal)
        
        if(myVal <= 10 && myVal >= 5 || myVal == 0)
        {
            myVal = myVal + 2
        }
        
        if(myVal > 10 )
        {
            myVal = myVal - 1
        }
        
        
        if(myVal < 0)
        {
            myVal = 10

        }
        
        debugPrint("weee",physicsBody?.node?.position.x.sign.rawValue )
        
       // let shifter: Int? = Int(myVal)
        var myIntValue = Int(myVal)
        var ader = Int(1)
        var neut = Int(0)

        if(myIntValue > 10 )
        {
            myIntValue = myIntValue - 1
        }
        
        else if(myVal < 2 )
        {
            myIntValue = myIntValue + 1
        }
        
        else {
            myIntValue = 0
        }
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: noty))
    }
    
    
    
    func applyForward(myF: Int) {
        isHeavy = true
        let noty = 25 * 20 * 30 * 20 * 50 * 100// 150
        let weee = physicsBody?.node?.position.x.sign.rawValue;
        

        physicsBody?.applyImpulse(CGVector(dx: myF, dy: noty))
    }
    
    func applyBackwards(myF: Int) {
        isHeavy = true
        let noty = 25 * 20 * 30 * 20 * 50 * 100// 150
        let weee = physicsBody?.node?.position.x.sign.rawValue;
        

        physicsBody?.applyImpulse(CGVector(dx: myF, dy: noty))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !checkInteractable() { return }
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            debugPrint("fppppp", currentPoint.x);
            
            createImpact(); applyImpulse();
            /*

            
            if(currentPoint.x > 400){
                debugPrint("x > 4000", currentPoint.x);

                createImpact(); applyForward(myF: 10)
            }
            
            if(currentPoint.x > 0 && currentPoint.x < 100){
                createImpact(); applyBackwards(myF: -10)
            }
            
            else{
                createImpact(); applyBackwards(myF: 0)
                debugPrint("x > 4000", currentPoint.x);


            }
            // do something with your currentPoint
             */
        }
        
        
        func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first {
                let currentPoint = touch.location(in: self)
                debugPrint("cpppp", currentPoint);

                // do something with your currentPoint
            }
        }
        
        debugPrint(event);
    }
}
