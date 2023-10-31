//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit

class HomeScene: RoutingUtilityScene {
        
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        loadSelectedPlayer()
        
        let isSoundOn = UserDefaults.standard.bool(for: .isSoundOn)
        
        if !isSoundOn {
            let currAudio = childNode(withName: "Audio Node") as? SKAudioNode
            currAudio?.isPaused = true
            currAudio?.removeAllActions()
            currAudio?.removeFromParent()
        }
    }
    
    
    private func loadSelectedPlayer() {
        guard let pendingNode = childNode(withName: "Animated Bird1") else {
            return
        }
        
        let playableCharacter = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
        
        let assetName = playableCharacter.getAssetName()
        let characterDimensions = CGSize(width: 200, height: 200)
        
        switch playableCharacter {
            
        case .bird:
            let stavvyBirdNode = PhysicsBirdNode(timeIntervalForDrawingFrames: 0.1, withTextureAtlas: assetName, size: characterDimensions)
            stavvyBirdNode.isHeavy = false
            stavvyBirdNode.position = pendingNode.position
            stavvyBirdNode.zPosition = pendingNode.zPosition
            scene?.addChild(stavvyBirdNode)
            
        case .stavvyGold, .stavvyRat, .stavvyPig, .eldyBird, .stavvyRaven:
            let myCurrPlayerNode = TheOriginalAnimatedNodes(animatedGif: assetName, correctAspectRatioFor: characterDimensions.width)
            myCurrPlayerNode.xScale = 1.0
            myCurrPlayerNode.yScale = 1.0
            
            myCurrPlayerNode.isHeavy = false
            myCurrPlayerNode.position = pendingNode.position
            myCurrPlayerNode.zPosition = pendingNode.zPosition
            scene?.addChild(myCurrPlayerNode)
        }
        
        pendingNode.removeFromParent()
    }
}


class AtmosphereScene: RoutingUtilityScene, ToggleButtonNodeResponderType, TriggleButtonNodeResponderType {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let buttonNodeMusic =
            scene?.childNode(withName: "Sound") as? ToggleButtonNode
        buttonNodeMusic?.isOn =
            UserDefaults.standard.bool(for: .isSoundOn)
        
        let buttonForDifficulty = scene?.childNode(withName: "Difficulty") as? TriggleButtonNode
        let difficultyLevel = UserDefaults.standard.getDifficultyLevel()
        let difficultyState = TriggleButtonNode.TriggleState.convert(from: difficultyLevel)
        buttonForDifficulty?.triggle = .init(state: difficultyState)
    }
        
    func toggleButtonTriggered(toggle: ToggleButtonNode) {
        UserDefaults.standard.set(toggle.isOn, for: .isSoundOn)
    }
        
    func triggleButtonTriggered(triggle: TriggleButtonNode) {
        debugPrint("trigger button node")
        let currDifficulty = triggle.triggle.toDifficultyLevel()
        UserDefaults.standard.set(difficultyLevel: currDifficulty)
    }
    
}

//  SounioTechnologies LLC
//  StavvyBird
//revisit

import SpriteKit
import GameplayKit
import GameKit


//Game
class PlayScene: SKScene {

    static var viewportSize: CGSize = .zero

    lazy var instanceGKSM: GKStateMachine = 
    GKStateMachine(states:
        [InGameState(gameConfiguration: currConfigForGame!), GameOverState(scene: currConfigForGame!), PausedState(scene: self, gameConfiguration: currConfigForGame!)])
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var precedingMoment : TimeInterval = 0
    let maximumUpdateDeltaTime: TimeInterval = 1.0 / 60.0

    var currConfigForGame: ConfigForScenes?
    let selection = UISelectionFeedbackGenerator()
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        self.precedingMoment = 0
        currConfigForGame = ConfigForScenes(with: self)
        currConfigForGame?.myGkStateMach = instanceGKSM
        currConfigForGame?.myGkStateMach?.enter(InGameState.self)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        PlayScene.viewportSize = view.bounds.size
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        currConfigForGame?.tangibles.forEach({ touchable in
            touchable.touchesBegan(touches, with: event)
        })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        currConfigForGame?.tangibles.forEach { touchable in
            touchable.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currConfigForGame?.tangibles.forEach { touchable in
            touchable.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currConfigForGame?.tangibles.forEach { touchable in
            touchable.touchesCancelled(touches, with: event)
        }
    }
        
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        guard view != nil else { return }
        var deltaTime = currentTime - precedingMoment
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        precedingMoment = currentTime
        if self.isPaused { return }
        instanceGKSM.update(deltaTime: deltaTime)
        currConfigForGame?.modernizers.filter({ return $0.willRelive }).forEach({ (activeUpdatable) in
            activeUpdatable.update(currentTime)
        })
    }
    
}

extension PlayScene: ButtonNodeResponderType {
    
    func buttonTriggered(button: ButtonNode) {
        guard let identifier = button.buttonIdentifier else {
            return
        }
        selection.selectionChanged()
        
        switch identifier {
        
        case .pause:
            currConfigForGame?.myGkStateMach?.enter(PausedState.self) //showLeaderBoard();
        case .resume:
            currConfigForGame?.myGkStateMach?.enter(InGameState.self)
        case .home:
            let sceneId = Scenes.title.getName()
            guard let gameScene = PlayScene(fileNamed: sceneId) else {
                return
            }
            gameScene.scaleMode = RoutingUtilityScene.sceneScaleMode
            let transition = SKTransition.fade(withDuration: 1.0)
            transition.pausesIncomingScene = false
            transition.pausesOutgoingScene = false
            self.view?.presentScene(gameScene, transition: transition)
        case .retry:
            currConfigForGame?.myGkStateMach?.enter(InGameState.self)
        default:
            debugPrint("Unable to invoke")
            
        }
    }
}


func *(lhs: CGSize, value: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * value, height: lhs.height * value)
}

//Scene
class GameOverlay {
        
    let myCurrBackground: SKSpriteNode  //change these skArray
    let myCurrSpritNod: SKSpriteNode
    
    
    init(overlaySceneFileName currFileName: String, zPosition: CGFloat) {
        let overlayScene = SKScene(fileNamed: currFileName)!
        let outterTemplateNode = overlayScene.childNode(withName: "Overlay") as! SKSpriteNode
        
        myCurrBackground = SKSpriteNode(color: outterTemplateNode.color, size: outterTemplateNode.size * UIScreen.main.scale)
        myCurrBackground.zPosition = zPosition

        // Copy the template node into the background node.
        myCurrSpritNod = outterTemplateNode.copy() as! SKSpriteNode
        myCurrSpritNod.position = .zero
        myCurrBackground.addChild(myCurrSpritNod)
        
        // Set the content node to a clear color to allow the background node to be seen through it.
        myCurrSpritNod.color = .clear
    }

}





