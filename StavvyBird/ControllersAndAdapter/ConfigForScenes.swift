//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit
import GameplayKit

extension SKScene {
    
    func allOfTheGameButtons() -> [ButtonNode] {
        return myButtonIdentifier.allOfTheGameButtonss.compactMap { buttonIdentifier in
            childNode(withName: "//\(buttonIdentifier.rawValue)") as? ButtonNode
        }
    }
}

class ConfigForScenes: NSObject,
                       PlaySceneProtocol {
    
    weak var playScene: PlayScene?

    var score: Int = 0
    var namedPngFile = "game-play-screen", actionFadeTime: TimeInterval = 0.24, seperationFromBottom: CGFloat = 0, characterDimensions = CGSize(width: 101, height: 101), forceOfGravity: CGFloat = -5.3
    
    var isSoundOn: Bool = {return UserDefaults.standard.bool(for: .isSoundOn)}(), scoreLabel: SKLabelNode?, pointAddedNoise = SKAction.playSoundFileNamed("points-noise.wav", waitForCompletion: false), crashNoise = SKAction.playSoundFileNamed("game-over-noise.wav", waitForCompletion: false)
    
//    var bird: BirdNode?
    typealias PlayableCharacter = (Updatable & PhysicsContactable & Touchable & Playable & SKNode)
    var currBirdCharForGame: PlayableCharacter?
    
    private(set) lazy var menuAudio: SKAudioNode = {
        let gameAudio = SKAudioNode(fileNamed: "home-audio.wav")
        gameAudio.autoplayLooped = true
        gameAudio.name = "manu audio"
        return gameAudio
    }()
    
    private(set) lazy var playingAudio: SKAudioNode = {
        // let gameAudio = SKAudioNode(fileNamed: "in-game-audio.wav")
        let gameAudio = SKAudioNode(fileNamed: "Blast(Edited).wav")
        // lower volume in 4 seconds
        gameAudio.run(SKAction.changeVolume(to: 0.5, duration: 0.1))
        gameAudio.autoplayLooped = true
        gameAudio.name = "playing audio"
        return gameAudio
    }()
    
    var myGkStateMach: GKStateMachine?
    weak var scene: SKScene?

    var (modernizers, tangibles, listOfNodes) = ([Updatable](), [Touchable](), [ButtonNode]())

    
    var overlay: GameOverlay? {
        didSet {
            listOfNodes = []
            oldValue?.myCurrBackground.run(SKAction.fadeOut(withDuration: actionFadeTime)) {
                debugPrint(#function + " change background")
                oldValue?.myCurrBackground.removeFromParent()
            }
            
            if let myCurrLayer = overlay, let scene = scene {
                let backAlph = 1.0
                myCurrLayer.myCurrBackground.removeFromParent()
                scene.addChild(myCurrLayer.myCurrBackground)
                debugPrint(#function + "---the overlay layer with scene add the overly---")
                myCurrLayer.myCurrBackground.alpha = backAlph
                myCurrLayer.myCurrBackground.run(SKAction.fadeIn(withDuration: actionFadeTime))
                
                listOfNodes = scene.allOfTheGameButtons()
            }
        }
    }
    
    

    private var _isHUDHidden: Bool = false
        var isHUDHidden: Bool { get {return _isHUDHidden}
        set(newValue) {_isHUDHidden = newValue
            if let myCurrGame = self.scene?.childNode(withName: "world") {
                myCurrGame.childNode(withName: "Score Node")?.isHidden = newValue
                myCurrGame.childNode(withName: "Pause")?.isHidden = newValue
            }
        }
    }

    private(set) var continuousBackgroundInstance: ContinuousBackground?
    private let notification = UINotificationFeedbackGenerator()
    private let impact = UIImpactFeedbackGenerator(style: .heavy)
    
    required init?(with scene: SKScene) {
        
        self.scene = scene
        
        guard let scene = self.scene else {
            debugPrint(#function + "The scene failed")
            return nil
        }
        
        if let scoreNode = scene.childNode(withName: "world")?.childNode(withName: "Score Node") {
            scoreLabel = scoreNode.childNode(withName: "Score Label") as? SKLabelNode
        }
        
        super.init()
        setUpGame(for: scene)
        prepareInfiniteBackgroundScroller(for: scene)
    }
    
    convenience init?(with scene: SKScene, instanceGKSM: GKStateMachine) {
        self.init(with: scene)
        self.myGkStateMach = instanceGKSM
    }
    
    func resetScores() {
        scoreLabel?.text = "0"
    }
    
    func destroyColumns() {
        var skArray = [SKNode]()
        
        continuousBackgroundInstance?.children.forEach({ node in
            let nameOfAsset = node.name
            if let doesContainNodeName = nameOfAsset?.contains("column"), doesContainNodeName { skArray += [node] }
        })
        skArray.forEach { node in
            node.removeAllActions()
            node.removeAllChildren()
            node.removeFromParent()
        }
        skArray.removeAll()
    }
    
     func setUpGame(for scene: SKScene) {
        scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: forceOfGravity)
        let currCgRec = CGRect(x: 0, y: seperationFromBottom, width: scene.size.width, height: scene.size.height - seperationFromBottom)
        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: currCgRec)
        
         let edges: EdgeMapping = .edges; let characterX: EdgeMapping = .characterX
        scene.physicsBody?.categoryBitMask = edges.rawValue
        scene.physicsBody?.collisionBitMask = characterX.rawValue
        scene.physicsWorld.contactDelegate = self
    }
    
     func prepareInfiniteBackgroundScroller(for scene: SKScene) {
        let nodeFactorSize = NodeScale.nodeScaleOfContinuousBackground.getValue()
        continuousBackgroundInstance = ContinuousBackground(fileName: namedPngFile, scaleFactor: CGPoint(x: nodeFactorSize, y: nodeFactorSize))
        continuousBackgroundInstance!.zPosition = 0
        scene.addChild(continuousBackgroundInstance!)
        modernizers.append(continuousBackgroundInstance!)
    }
    
    func greekShapeRaining
    (for currRate: TimeInterval) { var greekPartsRain = scene?.childNode(withName: "greekPartsRain")
        as? SKEmitterNode; greekPartsRain?.safeAdvanceSimulationTime(currRate)
    }
    
}
extension ConfigForScenes: SKPhysicsContactDelegate {
    private func handleDeadState() {
        debugPrint("Bird Has Fallen"); initialCollisionGameOver();  debugPrint("Bird is dead "); impactCollision();  debugPrint("Bird hit assets");
    }
    
    private func initialCollisionGameOver() {
        if myGkStateMach?.currentState is GameOverState { return }
        debugPrint("---------Game Over--------------");
        myGkStateMach?.enter(GameOverState.self)
    }
    
    private func impactCollision() {
        impact.impactOccurred()
        debugPrint("---------Impact of Block--------------");
        if isSoundOn { scene?.run(crashNoise) }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let pointOfImpact:UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
        let currBird = EdgeMapping.characterX.rawValue
        if pointOfImpact == (currBird | EdgeMapping.bouncer.rawValue) {
            score += 1; scoreLabel?.text = "Bounces: \(score)"
            if isSoundOn { scene?.run(pointAddedNoise) }
            notification.notificationOccurred(.success)
        }
        if pointOfImpact == (currBird | EdgeMapping.bouncer.rawValue) {
            debugPrint("bounce")
            playScene?.shakeAndZoomCamera(intensity: "low")
            //playScene?.shakeAndZoomCamera(intensity: "high")  // Cast the scene to PlayScene and call the method
            // playScene?.shakeAndZoomCamera(intensity: "high")  // Cast the scene to PlayScene and call the method
            //handleDeadState()
        }

        //bird hit block
        if pointOfImpact == (currBird | EdgeMapping.block.rawValue) {
            debugPrint("zeeee")
            handleDeadState()
        }
        //bird hit edges
        if pointOfImpact == (currBird | EdgeMapping.edges.rawValue) {
            debugPrint("top")
<<<<<<< HEAD
          handleDeadState()
            //playScene?.shakeAndZoomCamera(intensity: "low")
=======
            playScene?.shakeAndZoomCamera(intensity: "low")
>>>>>>> remotes/origin/main
          //  handleDeadState()
        }
    }
    
    
}
