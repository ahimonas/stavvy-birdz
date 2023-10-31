//  SounioTechnologies LLC
//  StavvyBird
// revisit


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
            
            if let overlay = overlay, let scene = scene {
                debugPrint(#function + "scene add the overly")
                overlay.myCurrBackground.removeFromParent()
                scene.addChild(overlay.myCurrBackground)
                
                overlay.myCurrBackground.alpha = 1.0
                overlay.myCurrBackground.run(SKAction.fadeIn(withDuration: actionFadeTime))
                
                listOfNodes = scene.getAllButtons()
            }
        }
    }
    
    private var _isHUDHidden: Bool = false
    var isHUDHidden: Bool {
        get {
            return _isHUDHidden
        }
        set(newValue) {
            _isHUDHidden = newValue
            
            if let world = self.scene?.childNode(withName: "world") {
                world.childNode(withName: "Score Node")?.isHidden = newValue
                world.childNode(withName: "Pause")?.isHidden = newValue
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
    
    func removePipes() {
        var skArray = [SKNode]()
        
        infiniteBackgroundNode?.children.forEach({ node in
            let nodeName = node.name
            if let doesContainNodeName = nodeName?.contains("pipe"), doesContainNodeName { skArray += [node] }
        })
        skArray.forEach { node in
            node.removeAllActions()
            node.removeAllChildren()
            node.removeFromParent()
        }
        skArray.removeAll()
    }
    
    private func prepareWorld(for scene: SKScene) {
        scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: forceOfGravity)
        let rect = CGRect(x: 0, y: seperationFromBottom, width: scene.size.width, height: scene.size.height - seperationFromBottom)
        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        
        let boundary: BondaryMapping = .boundary
        let player: BondaryMapping = .player
        
        scene.physicsBody?.categoryBitMask = boundary.rawValue
        scene.physicsBody?.collisionBitMask = player.rawValue
        
        scene.physicsWorld.contactDelegate = self
    }
    
    private func prepareInfiniteBackgroundScroller(for scene: SKScene) {
        let scaleFactor = NodeScale.gameBackgroundScale.getValue()
        
        infiniteBackgroundNode = ContinuousBackground(fileName: namedPngFile, scaleFactor: CGPoint(x: scaleFactor, y: scaleFactor))
        infiniteBackgroundNode!.zPosition = 0
        
        scene.addChild(infiniteBackgroundNode!)
        modernizers.append(infiniteBackgroundNode!)
    }
    
    func advanceSnowEmitter(for duration: TimeInterval) {
        let snowParticleEmitter = scene?.childNode(withName: "Snow Particle Emitter") as? SKEmitterNode
        snowParticleEmitter?.safeAdvanceSimulationTime(duration)
    }
    
}

extension ConfigForScenes: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
        let player = BondaryMapping.player.rawValue
        
        if collision == (player | BondaryMapping.gap.rawValue) {
            score += 1
            scoreLabel?.text = "\(score)"
            
            if isSoundOn { scene?.run(pointAddedNoise) }
            
            notification.notificationOccurred(.success)
        }
        
        //bird hit pipe
        if collision == (player | BondaryMapping.pipe.rawValue) {
            handleDeadState()
        }
        //bird hit boundary
        if collision == (player | BondaryMapping.boundary.rawValue) {
            handleDeadState()
        }
    }
        
    private func handleDeadState() {
        debugPrint("Bird Has Fallen")
        deadState()
        hit()
    }
    
    private func deadState() {
        if myGkStateMach?.currentState is GameOverState { return }
        myGkStateMach?.enter(GameOverState.self)
    }
    
    private func hit() {
        impact.impactOccurred()
        if isSoundOn { scene?.run(crashNoise) }
    }
}
