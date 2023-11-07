//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit

class HomeScene: RoutingUtilityScene, ToggleButtonNodeResponderType {
        
    override func sceneDidLoad() {
        super.sceneDidLoad()
        

        let buttonNodeMusic =
            scene?.childNode(withName: "Sound") as? ToggleButtonNode
        
        let isSoundOn = UserDefaults.standard.bool(for: .isSoundOn)

        if  !isSoundOn {
            /*
            let currAudio = childNode(withName: "Audio Node") as? SKAudioNode
            currAudio?.isPaused = true
            currAudio?.isPaused = true;
            currAudio?.removeAllActions()
            currAudio?.removeFromParent()
            */
            
            buttonNodeMusic?.isOn =
                UserDefaults.standard.bool(for: .isSoundOn)
             
            
        }
        

    }
    /*
    private(set) lazy var menuAudio: SKAudioNode = {
        let gameAudio = SKAudioNode(fileNamed: "home-audio.wav")
        gameAudio.autoplayLooped = true
        gameAudio.name = "manu audio"
        return gameAudio
    }()
     */
    
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let isSoundOn = UserDefaults.standard.bool(for: .isSoundOn)

        
        if  isSoundOn {

            /*
            
            buttonNodeMusic?.isOn =
                UserDefaults.standard.bool(for: .isSoundOn)
             */
            
            
        }
        
        loadSelectedPlayer()



       // let buttonForDifficulty = scene?.childNode(withName: "Difficulty") as? TriggleButtonNode
     //   let difficultyLevel = UserDefaults.standard.rateOfBlocksInSky()
 //       let difficultyState = TriggleButtonNode.TriggleState.convert(from: difficultyLevel)
  //      buttonForDifficulty?.triggle = .init(state: difficultyState)
    }

    func toggleButtonTriggered(toggle: ToggleButtonNode) {
        UserDefaults.standard.set(toggle.isOn, for: .isSoundOn)
    }
    
    
    private func loadSelectedPlayer() {
        guard let pendingNode = childNode(withName: "Animated Bird1") else {
            return
        }
        
        let playableCharacter = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
        
        let getBirdName = playableCharacter.getBirdCharacterName()
        let characterDimensions = CGSize(width: 199, height: 199)
        
        //This resizes the players to a reasonable size
        switch playableCharacter {
            
        case .bird:
            let stavvyBirdNode = PhysicsBirdNode(timeIntervalForDrawingFrames: 0.1, withTextureAtlas: getBirdName, size: characterDimensions)
            stavvyBirdNode.isHeavy = false
            stavvyBirdNode.position = pendingNode.position
            stavvyBirdNode.zPosition = pendingNode.zPosition
            scene?.addChild(stavvyBirdNode)
            let me2 = SKAction.scale(by: 2, duration: 0.1)
            let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.2)
            let sequence2 = SKAction.sequence([moveUp, moveUp.reversed(), moveUp, moveUp.reversed(), moveUp, moveUp.reversed()])
            let boxRepeat = SKAction.repeatForever(sequence2)
            stavvyBirdNode.run(boxRepeat)
            
        case .stavvyRat, .stavvyPig, .stavvyRaven:
            let myCurrPlayerNode = TheOriginalAnimatedNodes(animatedGif: getBirdName, correctAspectRatioFor: characterDimensions.width)
            myCurrPlayerNode.xScale = 1.0; myCurrPlayerNode.yScale = 1.0
            myCurrPlayerNode.isHeavy = false
            myCurrPlayerNode.position = pendingNode.position; myCurrPlayerNode.zPosition = pendingNode.zPosition
            scene?.addChild(myCurrPlayerNode)
            
        case .stavvyGold:
            let myCurrPlayerNode = GoldBirdPhysics(animatedGif: getBirdName, correctAspectRatioFor: characterDimensions.width)
            myCurrPlayerNode.xScale = 1.0; myCurrPlayerNode.yScale = 1.0
            myCurrPlayerNode.isHeavy = false
            myCurrPlayerNode.position = pendingNode.position; myCurrPlayerNode.zPosition = pendingNode.zPosition
            scene?.addChild(myCurrPlayerNode)
            
            let me2 = SKAction.scale(by: 2, duration: 0.1)
            let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.2)
            let sequence2 = SKAction.sequence([moveUp, moveUp.reversed(), moveUp, moveUp.reversed(), moveUp, moveUp.reversed()])
            let boxRepeat = SKAction.repeatForever(sequence2)
            myCurrPlayerNode.run(boxRepeat)
            
            
        case .eldyBird:
            let myCurrPlayerNode = EldyBirdPhysics(animatedGif: getBirdName, correctAspectRatioFor: characterDimensions.width)
            myCurrPlayerNode.xScale = 1.0; myCurrPlayerNode.yScale = 1.0
            myCurrPlayerNode.isHeavy = false
            myCurrPlayerNode.position = pendingNode.position; myCurrPlayerNode.zPosition = pendingNode.zPosition
            scene?.addChild(myCurrPlayerNode)
            
        }
        
        

    
    
        
        pendingNode.removeFromParent()
    }
    
    private func processEldyPlayerScale(myCurrPlayerNode: EldyBirdPhysics){
        guard let pendingNode = childNode(withName: "Animated Bird1") else {
            return
        }
        
        myCurrPlayerNode.xScale = 1.0
        myCurrPlayerNode.yScale = 1.0
        
        myCurrPlayerNode.isHeavy = false
        myCurrPlayerNode.position = pendingNode.position
        myCurrPlayerNode.zPosition = pendingNode.zPosition
        scene?.addChild(myCurrPlayerNode)
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

    static var sizeOfScreen: CGSize = .zero

    lazy var instanceGKSM: GKStateMachine = 
    GKStateMachine(states:
        [InGameState(inGameConf: currConfigForGame!), GameOverState(scene: currConfigForGame!), PausedState(scene: self, inGameConf: currConfigForGame!)])
        
    private var precedingMoment : TimeInterval = 0
    let maximumUpdateDeltaTime: TimeInterval = 1.0 / 60.0

    var currConfigForGame: ConfigForScenes?
    let selection = UISelectionFeedbackGenerator()
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        self.precedingMoment = 0
        currConfigForGame = ConfigForScenes(with: self)
        currConfigForGame?.playScene = self  // Set the playScene property
        currConfigForGame?.myGkStateMach = instanceGKSM
        currConfigForGame?.myGkStateMach?.enter(InGameState.self)
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

    //  Camera properties
    var cameraNode: SKCameraNode!
    var originalCameraPosition: CGPoint = .zero

    // override func didMove(to view: SKView) {
    //     // Initialize the camera
    //     cameraNode = SKCameraNode()
    //     self.camera = cameraNode
    //     self.addChild(cameraNode)
    // }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        PlayScene.sizeOfScreen = view.bounds.size
        //added
        // self.scaleMode = .aspectFit

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
         // Initialize the camera
        cameraNode = SKCameraNode()
        // cameraNode.position = CGPoint(x: PlayScene.sizeOfScreen.width, y: PlayScene.sizeOfScreen.height / 1.15)
        cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        // cameraNode.position = CGPoint(x: size.width * anchorPoint.x, y: size.height * anchorPoint.y)
        originalCameraPosition = cameraNode.position
        self.addChild(cameraNode)
        self.camera = cameraNode
    }

    func addColorFilterToCamera() {
        // remove any existing filter nodes
        cameraNode.removeAllChildren()
        let filterNode = SKSpriteNode(color: .clear, size: self.size)
        filterNode.position = CGPoint.zero
        filterNode.zPosition = 100 // Ensure it's above everything else
        filterNode.colorBlendFactor = 0.5 // Set the color blend factor to 0.5 to make it semi-transparent
        filterNode.alpha = 0.1 // Set the alpha to 0.0 to make it invisible
        
        // Add the filter node to the camera
        cameraNode.addChild(filterNode)
        
        // Create a color action sequence
        let colorAction = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.1, duration: 0.05),
            SKAction.colorize(with: .green, colorBlendFactor: 0.1, duration: 0.05),
            SKAction.colorize(with: .blue, colorBlendFactor: 0.1, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1),// Fade to clear
            // Remove the filter node from the camera
            SKAction.run { filterNode.removeFromParent() }
        ])
        
        // Run the color animation on the filter node
        filterNode.run(colorAction)
    }

     // Create a method for the shake and zoom effects
    func shakeAndZoomCamera(intensity: String = "low") {
    debugPrint("Shake and Zoom Camera")

    // Define the shake and zoom actions
    var shakeAction: SKAction
    let zoomInAction = SKAction.scale(to: 0.8, duration: 0.1)  // Zoom in
    let zoomOutAction = SKAction.scale(to: 1.0, duration: 0.2) // Zoom out

    // Define the shake action based on intensity
    if intensity == "low" {
        shakeAction = SKAction.sequence([
            SKAction.moveBy(x: -5, y: -5, duration: 0.1),
            SKAction.moveBy(x: 10, y: 10, duration: 0.1),
            SKAction.moveBy(x: -10, y: -10, duration: 0.1),
            SKAction.moveBy(x: 5, y: 5, duration: 0.1)
        ])
    } else {
        shakeAction = SKAction.sequence([
            SKAction.moveBy(x: -10, y: -10, duration: 0.1),
            SKAction.moveBy(x: 20, y: 20, duration: 0.1),
            SKAction.moveBy(x: -20, y: -20, duration: 0.1),
            SKAction.moveBy(x: 10, y: 10, duration: 0.1)
        ])
    }

    // Check if the main character node exists and proceed with the camera effect
    if let mainCharacter = currConfigForGame?.currBirdCharForGame as? SKNode {
        // debugPrint("Main Character Node Exists")
        // Move the camera to the bird's position gradually
          // Calculate the constrained position
        let originalPosition = originalCameraPosition
        var newPosition = mainCharacter.position
        let maxDistance: CGFloat = 75

        // Calculate the distance vector
        let distanceVector = CGVector(dx: newPosition.x - originalPosition.x, dy: newPosition.y - originalPosition.y)
        let distanceMagnitude = sqrt(distanceVector.dx * distanceVector.dx + distanceVector.dy * distanceVector.dy)

        // If the distance is greater than the maxDistance, scale the distance vector down to the maxDistance
        if distanceMagnitude > maxDistance {
            let scalingFactor = maxDistance / distanceMagnitude
            newPosition.x = originalPosition.x + distanceVector.dx * scalingFactor
            newPosition.y = originalPosition.y + distanceVector.dy * scalingFactor
        }
        addColorFilterToCamera()
        // Create the move action with the constrained position
        let moveAction = SKAction.move(to: newPosition, duration: 0.25)
        let moveBackAction = SKAction.move(to: originalPosition, duration: 0.1)
        
        // Run the move action with the zoom in action simultaneously
        let groupInAction = SKAction.group([moveAction, zoomInAction, shakeAction])
        let groupOutAction = SKAction.group([moveBackAction, zoomOutAction])
        
        // After zooming in, zoom out to the original scale
        let sequenceAction = SKAction.sequence([groupInAction, groupOutAction])

        cameraNode.run(sequenceAction)

        
    }
}
    
}

extension PlayScene: ButtonNodeResponderType {
    
    func buttonTriggered(button: ButtonNode) {
        guard let identifier = button.myCurrButId else {
            return
        }
        selection.selectionChanged()
        switch identifier {
            /*
        case .pause:
            currConfigForGame?.myGkStateMach?.enter(PausedState.self) //showLeaderBoard();
             */
        case .resume:
            currConfigForGame?.myGkStateMach?.enter(InGameState.self)
        case .home:
            let slectedView = Scenes.title.getName()
            guard let gameScene = PlayScene(fileNamed: slectedView) else {
                return
            }
            gameScene.scaleMode = RoutingUtilityScene.aspectRatioTypeMode
            let transition = SKTransition.fade(withDuration: 1.0)
            transition.pausesIncomingScene = false
            transition.pausesOutgoingScene = false
            self.view?.presentScene(gameScene, transition: transition)
        case .home22:
            let slectedView = Scenes.title.getName()
            guard let gameScene = PlayScene(fileNamed: slectedView) else {
                return
            }
            gameScene.scaleMode = RoutingUtilityScene.aspectRatioTypeMode
            let transition = SKTransition.fade(withDuration: 1.0)
            transition.pausesIncomingScene = false
            transition.pausesOutgoingScene = false
            self.view?.presentScene(gameScene, transition: transition)
        case .retry:
            currConfigForGame?.myGkStateMach?.enter(InGameState.self)
        case .retry22:
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





