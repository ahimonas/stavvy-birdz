//  SounioTechnologies LLC
//  StavvyBird
// revisit


import GameplayKit
import SpriteKit

class InGameState: GKState {
        
    unowned var adapter: GameSceneAdapter
    
    private let playerScale = CGPoint(x: 0.4, y: 0.4)
    private let snowEmitterAdvancementInSeconds: TimeInterval = 15
    private let animationTimeInterval: TimeInterval = 0.1
    
    private(set) var infinitePipeProducer: SKAction! = nil
    let infinitePipeProducerKey = "Pipe Action"
        
    init(adapter: GameSceneAdapter) {
        self.adapter = adapter
        super.init()
        
        guard let scene = adapter.scene else {
            return
        }
        preparePlayer(for: scene)
        
        if let scene = adapter.scene, let target = adapter.infiniteBackgroundNode {
            infinitePipeProducer = ColumnFactory.launch(for: scene, targetNode: target)
        }
        
        adapter.advanceSnowEmitter(for: snowEmitterAdvancementInSeconds)
    }
        
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        adapter.playerCharacter?.weighedDownByForce = false
        adapter.scene?.run(infinitePipeProducer, withKey: infinitePipeProducerKey)
        
        if adapter.isSoundOn {
            adapter.scene?.addChild(adapter.playingAudio)
            SKAction.play()
        }
        
        if previousState is PausedState {
            return
        }
        
        guard let scene = adapter.scene, let player = adapter.playerCharacter else {
            return
        }
        
        
        if adapter.isSoundOn {
            if let menuAudio = scene.childNode(withName: adapter.menuAudio.name!) {
                menuAudio.removeFromParent()
            }
        }
                
        let character = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
        position(player: character, in: scene)
        player.willRenew = true
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        if adapter.isSoundOn {
            adapter.playingAudio.removeFromParent()
        }

        if nextState is GameOverState {
            adapter.scene?.removeAction(forKey: infinitePipeProducerKey)
            adapter.removePipes()
            adapter.resetScores()
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
            adapter.playerCharacter = PhysicsBirdNode(
                animationTimeInterval: animationTimeInterval,
                withTextureAtlas: assetName,
                size: adapter.characterDimensions)
        case .stavvyGold, .stavvyRat, .stavvyPig, .eldyBird, .stavvyRaven:
            let player = DefaultGifNodes(
                animatedGif: assetName,
                correctAspectRatioFor: adapter.characterDimensions.width)
            player.xScale = playerScale.x
            player.yScale = playerScale.y
            adapter.playerCharacter = player
        }
        
        guard let playableCharacter = adapter.playerCharacter else {
            debugPrint(#function + " Stavvy Bird failed")
            return
        }
        position(player: character, in: scene)
        scene.addChild(playableCharacter)
        
        adapter.updatables.append(playableCharacter)
        adapter.touchables.append(playableCharacter)
    }
    
    private func position(player: PlayableCharacter, in scene: SKScene) {
        guard let playerNode = adapter.playerCharacter else {
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
    
    unowned var levelScene: GameSceneAdapter
    var overlay: GameOverlay!
    
    
    private(set) var currentScoreLabel: SKLabelNode?
        
    init(scene: GameSceneAdapter) {
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
        
        levelScene.playerCharacter?.shouldAcceptTouches = false
        
        updateScores()
        
        updasteOverlayPresentation()
        
        levelScene.overlay = overlay
        levelScene.isHUDHidden = true
        
        levelScene.playerCharacter?.willRenew = false
        
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
            levelScene.playerCharacter?.shouldAcceptTouches = true
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
    unowned var adapter: GameSceneAdapter
    var overlay: GameOverlay!
        
    init(scene: SKScene, adapter: GameSceneAdapter) {
        self.levelScene = scene
        self.adapter = adapter
        super.init()
        overlay = GameOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: 1000)
    }
        
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        levelScene.isPaused = true
        adapter.overlay = overlay
        adapter.isHUDHidden = true
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        levelScene.isPaused = false
        adapter.overlay = nil
        adapter.isHUDHidden = false
    }
        
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
}





