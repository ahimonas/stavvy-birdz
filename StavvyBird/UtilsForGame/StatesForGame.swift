//  SounioTechnologies LLC
//  StavvyBird
// revisit


import GameplayKit
import SpriteKit

class InGameState: GKState {
        
    unowned var inGameConf: ConfigForScenes
    
    let sizeOfCharacter = CGPoint(x: 0.4, y: 0.4)
    let greekRainParticleEmtterTiming: TimeInterval = 15
    let timeIntervalForDrawingFrames: TimeInterval = 0.1
    
    private(set) var skyBoxInfiniteGenerate: SKAction! = nil
    let skyBoxInfiniteGenerateKey = "skybox action"
        
    init(inGameConf: ConfigForScenes) {
        self.inGameConf = inGameConf
        super.init()
        
        guard let scene = inGameConf.scene else { return }
        preparePlayer(for: scene)
        if let scene = inGameConf.scene, let target = inGameConf.continuousBackgroundInstance {
            skyBoxInfiniteGenerate = ColumnFactory.launch(for: scene, targetNode: target)
        }
        
        inGameConf.greekShapeRaining(for: greekRainParticleEmtterTiming)
    }
        
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        inGameConf.currBirdCharForGame?.isHeavy = false
        inGameConf.scene?.run(skyBoxInfiniteGenerate, withKey: skyBoxInfiniteGenerateKey)
        
        if inGameConf.isSoundOn {
            inGameConf.scene?.addChild(inGameConf.playingAudio)
            SKAction.play()
        }
        
        if previousState is PausedState {
            return
        }
        
        guard let scene = inGameConf.scene, let characterX = inGameConf.currBirdCharForGame else {
            return
        }
        
        
        if inGameConf.isSoundOn {
            if let menuAudio = scene.childNode(withName: inGameConf.menuAudio.name!) {
                menuAudio.removeFromParent()
            }
        }
                
        let character = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
        position(characterX: character, in: scene)
        characterX.willRelive = true
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        if inGameConf.isSoundOn {
            inGameConf.playingAudio.removeFromParent()
        }

        if nextState is GameOverState {
            inGameConf.scene?.removeAction(forKey: skyBoxInfiniteGenerateKey)
            inGameConf.destroyColumns()
            inGameConf.resetScores()
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    
    private func preparePlayer(for scene: SKScene) {
        let character = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
        let getBirdName = character.getBirdCharacterName()
        
        switch character {
        case .stavvyGold, .stavvyRat, .stavvyPig, .stavvyRaven:
            let characterX = TheOriginalAnimatedNodes(
                animatedGif: getBirdName,
                correctAspectRatioFor: inGameConf.characterDimensions.width)
            characterX.xScale = sizeOfCharacter.x
            characterX.yScale = sizeOfCharacter.y
            inGameConf.currBirdCharForGame = characterX
            
        case .eldyBird:
            let characterX = EldyBirdPhysics(
                animatedGif: getBirdName,
                correctAspectRatioFor: inGameConf.characterDimensions.width)
            characterX.xScale = sizeOfCharacter.x
            characterX.yScale = sizeOfCharacter.y
            inGameConf.currBirdCharForGame = characterX
            
        case .bird:
            inGameConf.currBirdCharForGame = PhysicsBirdNode(
                timeIntervalForDrawingFrames: timeIntervalForDrawingFrames,
                withTextureAtlas: getBirdName,
                size: inGameConf.characterDimensions)
        }
        
        //cant change playable character
        guard let myCurrBirdChar = inGameConf.currBirdCharForGame else {
            debugPrint(#function + " Stavvy Bird failed")
            return
        }
        position(characterX: character, in: scene)
        scene.addChild(myCurrBirdChar)
        
        inGameConf.modernizers.append(myCurrBirdChar)
        inGameConf.tangibles.append(myCurrBirdChar)
    }
    
    private func position(characterX: PlayableCharacter, in scene: SKScene) {
        guard let playerNode = inGameConf.currBirdCharForGame else {
            return
        }
        
        let twosCompany = 2; let twentysCompany = 20; let fiftysCompany = 50; let tensCompany = 10;
        switch characterX {

        case .stavvyGold, .stavvyRat, .stavvyPig, .eldyBird, .stavvyRaven:
            let twosCompany: CGFloat = 2;
            let twentysCompany: CGFloat = 20;
            playerNode.position = CGPoint(x: (playerNode.size.width / twosCompany) - twentysCompany, y: scene.size.height / twosCompany)
        case .bird:
            let twosCompany: CGFloat = 2;
            let twentysCompany: CGFloat = 20;
            let fiftysCompany: CGFloat = 50;
            let tensCompany: CGFloat = 10;
            playerNode.position = CGPoint(x: playerNode.size.width / twosCompany + fiftysCompany, y: scene.size.height / twosCompany)
            playerNode.zPosition = tensCompany
        }
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
            levelScene.destroyColumns()
        }
        
        levelScene.currBirdCharForGame?.isInteractable = false
        
        updateScores()
        
        updasteOverlayPresentation()
        
        levelScene.overlay = overlay
        levelScene.isHUDHidden = true
        
        levelScene.currBirdCharForGame?.willRelive = false
        
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
            levelScene.currBirdCharForGame?.isInteractable = true
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
    unowned var inGameConf: ConfigForScenes
    var overlay: GameOverlay!
        
    init(scene: SKScene, inGameConf: ConfigForScenes) {
        self.levelScene = scene
        self.inGameConf = inGameConf
        super.init()
        overlay = GameOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: 1000)
    }
        
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        levelScene.isPaused = true
        inGameConf.overlay = overlay
        inGameConf.isHUDHidden = true
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        levelScene.isPaused = false
        inGameConf.overlay = nil
        inGameConf.isHUDHidden = false
    }
        
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
}





