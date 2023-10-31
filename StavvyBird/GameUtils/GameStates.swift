//  SounioTechnologies LLC
//  StavvyBird
// revisit


import GameplayKit
import SpriteKit

class InGameState: GKState {
        
    unowned var gameConfiguration: ConfigForScenes
    let sizeOfCharacter = CGPoint(x: 0.4, y: 0.4)
    let snowEmitterAdvancementInSeconds: TimeInterval = 15
    let timeIntervalForDrawingFrames: TimeInterval = 0.1
    
    private(set) var infinitePipeProducer: SKAction! = nil
    let infinitePipeProducerKey = "Pipe Action"
        
    init(gameConfiguration: ConfigForScenes) {
        self.gameConfiguration = gameConfiguration
        super.init()
        
        guard let scene = gameConfiguration.scene else {
            return
        }
        preparePlayer(for: scene)
        
        if let scene = gameConfiguration.scene, let target = gameConfiguration.infiniteBackgroundNode {
            infinitePipeProducer = ColumnFactory.launch(for: scene, targetNode: target)
        }
        
        gameConfiguration.advanceSnowEmitter(for: snowEmitterAdvancementInSeconds)
    }
        
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        gameConfiguration.playerCharacter?.isHeavy = false
        gameConfiguration.scene?.run(infinitePipeProducer, withKey: infinitePipeProducerKey)
        
        if gameConfiguration.isSoundOn {
            gameConfiguration.scene?.addChild(gameConfiguration.playingAudio)
            SKAction.play()
        }
        
        if previousState is PausedState {
            return
        }
        
        guard let scene = gameConfiguration.scene, let player = gameConfiguration.playerCharacter else {
            return
        }
        
        
        if gameConfiguration.isSoundOn {
            if let menuAudio = scene.childNode(withName: gameConfiguration.menuAudio.name!) {
                menuAudio.removeFromParent()
            }
        }
                
        let character = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
        position(player: character, in: scene)
        player.willRelive = true
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        if gameConfiguration.isSoundOn {
            gameConfiguration.playingAudio.removeFromParent()
        }

        if nextState is GameOverState {
            gameConfiguration.scene?.removeAction(forKey: infinitePipeProducerKey)
            gameConfiguration.removePipes()
            gameConfiguration.resetScores()
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    
    private func preparePlayer(for scene: SKScene) {
        let character = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
        let assetName = character.getAssetName()
        
        switch character {
        case .bird:
            gameConfiguration.playerCharacter = PhysicsBirdNode(
                timeIntervalForDrawingFrames: timeIntervalForDrawingFrames,
                withTextureAtlas: assetName,
                size: gameConfiguration.characterDimensions)
        case .stavvyGold, .stavvyRat, .stavvyPig, .eldyBird, .stavvyRaven:
            let player = TheOriginalAnimatedNodes(
                animatedGif: assetName,
                correctAspectRatioFor: gameConfiguration.characterDimensions.width)
            player.xScale = sizeOfCharacter.x
            player.yScale = sizeOfCharacter.y
            gameConfiguration.playerCharacter = player
        }
        
        guard let playableCharacter = gameConfiguration.playerCharacter else {
            debugPrint(#function + " Stavvy Bird failed")
            return
        }
        position(player: character, in: scene)
        scene.addChild(playableCharacter)
        
        gameConfiguration.updatables.append(playableCharacter)
        gameConfiguration.touchables.append(playableCharacter)
    }
    
    private func position(player: PlayableCharacter, in scene: SKScene) {
        guard let playerNode = gameConfiguration.playerCharacter else {
            return
        }
        
        switch player {
        case .bird:
            playerNode.position = CGPoint(x: playerNode.size.width / 2 + 50, y: scene.size.height / 2)
        case .stavvyGold, .stavvyRat, .stavvyPig, .eldyBird, .stavvyRaven:
            playerNode.position = CGPoint(x: (playerNode.size.width / 2) - 20, y: scene.size.height / 2)
        }
        playerNode.zPosition = 10

    }
   
}


class GameOverState: GKState {

    var gcEnabled = Bool()
    var gcDefaultLeaderboard = String()
    var leaderboardID = "stavvyboard22"
    
    var overlaySceneFileName: String {
        return Scenes.failed.getName()
    }
    
    unowned var levelScene: ConfigForScenes
    var overlay: GameOverlay!
    
    
    private(set) var currentScoreLabel: SKLabelNode?
        
    init(scene: ConfigForScenes) {
        self.levelScene = scene
        super.init()
     
        overlay = GameOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: 100)
        currentScoreLabel = overlay.myCurrSpritNod.childNode(withName: "Current Score") as? SKLabelNode
    }
       
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        if previousState is InGameState {
            levelScene.removePipes()
        }
        
        levelScene.playerCharacter?.isInteractable = false
        
        updateScores()
        
        updasteOverlayPresentation()
        
        levelScene.overlay = overlay
        levelScene.isHUDHidden = true
        
        levelScene.playerCharacter?.willRelive = false
        
        levelScene.scene?.removeAllActions()
        
        levelScene.score = 0
        
        if levelScene.isSoundOn {
            if let playingAudioNodeName = levelScene.playingAudio.name {
                levelScene.scene?.childNode(withName: playingAudioNodeName)?.removeFromParent()
            }
            if levelScene.scene?.childNode(withName: levelScene.menuAudio.name!) == nil {
                levelScene.scene?.addChild(levelScene.menuAudio)
                SKAction.play()
            }
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        if nextState is InGameState {
            levelScene.overlay = nil
            levelScene.isHUDHidden = false
            levelScene.playerCharacter?.isInteractable = true
        }
    }
        
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
}

extension GameOverState {
    
    fileprivate func updateScores() {
        let bestScore = UserDefaults.standard.integer(for: .bestScore)
        let currentScore = levelScene.score
        
        if currentScore > bestScore {
            UserDefaults.standard.set(currentScore, for: .bestScore)
            let utilityScene = RoutingUtilityScene()
            utilityScene.saveScore(score: currentScore)
        }
        UserDefaults.standard.set(currentScore, for: .lastScore)
    }
    
    fileprivate func updasteOverlayPresentation() {
        let myCurrSpritNod = overlay.myCurrSpritNod
        
        if let bestScoreLabel = myCurrSpritNod.childNode(withName: "Best Score") as? SKLabelNode {
            let bestScore = UserDefaults.standard.integer(for: .bestScore)
            bestScoreLabel.text = "Best Score: \(bestScore)"
        }
        
        if let currentScore = myCurrSpritNod.childNode(withName: "Current Score") as? SKLabelNode {
            currentScore.text = "Current Score: \(levelScene.score)"
        }
    }
}

class PausedState: GKState {
        
    var overlaySceneFileName: String {
        return Scenes.pause.getName()
    }
    
    unowned var levelScene: SKScene
    unowned var gameConfiguration: ConfigForScenes
    var overlay: GameOverlay!
        
    init(scene: SKScene, gameConfiguration: ConfigForScenes) {
        self.levelScene = scene
        self.gameConfiguration = gameConfiguration
        super.init()
        overlay = GameOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: 1000)
    }
        
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        levelScene.isPaused = true
        gameConfiguration.overlay = overlay
        gameConfiguration.isHUDHidden = true
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        levelScene.isPaused = false
        gameConfiguration.overlay = nil
        gameConfiguration.isHUDHidden = false
    }
        
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
}





