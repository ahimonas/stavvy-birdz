//  SounioTechnologies LLC
//  StavvyBird
// revisit


//Not done!!!!!
import SpriteKit
import GameplayKit

extension SKScene {
    
    func getAllButtons() -> [ButtonNode] {
        return ButtonIdentifier.allButtonIdentifiers.compactMap { buttonIdentifier in
            childNode(withName: "//\(buttonIdentifier.rawValue)") as? ButtonNode
        }
    }
}

class ConfigForScenes: NSObject,
                       PlaySceneProtocol {
    var score: Int = 0

var namedPngFile = "game-play-screen", actionFadeTime: TimeInterval = 0.24, seperationFromBottom: CGFloat = 0, characterDimensions = CGSize(width: 101, height: 101), forceOfGravity: CGFloat = -5.1
    
    var isSoundOn: Bool = {return UserDefaults.standard.bool(for: .isSoundOn)}(), scoreLabel: SKLabelNode?, pointAddedNoise = SKAction.playSoundFileNamed("points-noise.wav", waitForCompletion: false), crashNoise = SKAction.playSoundFileNamed("game-over-noise.wav", waitForCompletion: false)
    
//    var bird: BirdNode?
    typealias PlayableCharacter = (PhysicsContactable & Updatable & Touchable & Playable & SKNode)
    var playerCharacter: PlayableCharacter?
    
    private(set) lazy var menuAudio: SKAudioNode = {
        let gameAudio = SKAudioNode(fileNamed: "home-audio.wav")
        gameAudio.autoplayLooped = true
        gameAudio.name = "manu audio"
        return gameAudio
    }()
    
    private(set) lazy var playingAudio: SKAudioNode = {
        let gameAudio = SKAudioNode(fileNamed: "in-game-audio.wav")
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
                
                listOfNodes = scene.getAllButtons()
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

    
    
    private(set) var infiniteBackgroundNode: ContinuousBackground?
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
        
        prepareWorld(for: scene)
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
        
        infiniteBackgroundNode?.children.forEach({ node in
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
    
     func prepareWorld(for scene: SKScene) {
        scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: forceOfGravity)
        let rect = CGRect(x: 0, y: seperationFromBottom, width: scene.size.width, height: scene.size.height - seperationFromBottom)
        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        
        let edges: EdgeMapping = .edges
        let characterX: EdgeMapping = .characterX
        
        scene.physicsBody?.categoryBitMask = edges.rawValue
        scene.physicsBody?.collisionBitMask = characterX.rawValue
        
        scene.physicsWorld.contactDelegate = self
    }
    
     func prepareInfiniteBackgroundScroller(for scene: SKScene) {
        let nodeFactorSize = NodeScale.gameBackgroundScale.getValue()
        
        infiniteBackgroundNode = ContinuousBackground(fileName: namedPngFile, scaleFactor: CGPoint(x: nodeFactorSize, y: nodeFactorSize))
        infiniteBackgroundNode!.zPosition = 0
        scene.addChild(infiniteBackgroundNode!)
        modernizers.append(infiniteBackgroundNode!)
    }
    
    func greekShapeRaining
    (for currRate: TimeInterval) {
        var greekPartsRain = scene?.childNode(withName: "greekPartsRain")
        as? SKEmitterNode; greekPartsRain?.safeAdvanceSimulationTime(currRate)
    }
    
}

extension ConfigForScenes: SKPhysicsContactDelegate {
    private func handleDeadState() {
        debugPrint("Bird Has Fallen"); initialCollisionGameOver();  debugPrint("Bird is dead "); impactCollision();  debugPrint("Bird hit assets");
    }
    
    private func initialCollisionGameOver() {
        if myGkStateMach?.currentState is GameOverState { return }
        myGkStateMach?.enter(GameOverState.self)
    }
    
    private func impactCollision() {
        impact.impactOccurred()
        if isSoundOn { scene?.run(crashNoise) }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let pointOfImpact:UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
        let currBird = EdgeMapping.characterX.rawValue
        if pointOfImpact == (currBird | EdgeMapping.breaker.rawValue) {
            score += 1; scoreLabel?.text = "\(score)"
            if isSoundOn { scene?.run(pointAddedNoise) }
            notification.notificationOccurred(.success)
        }
        
        //bird hit block
        if pointOfImpact == (currBird | EdgeMapping.block.rawValue) {
            handleDeadState()
        }
        //bird hit edges
        if pointOfImpact == (currBird | EdgeMapping.edges.rawValue) {
            handleDeadState()
        }
    }
    
    
}
