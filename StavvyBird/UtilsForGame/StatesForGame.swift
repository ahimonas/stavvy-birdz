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
        inGameConf.isSoundOn = true
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
        
        debugPrint("inGameConf.isSoundOn", inGameConf.isSoundOn)
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
            debugPrint("WHAT SCENE ", scene.name, inGameConf.menuAudio.name)
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
        case .stavvyRat, .stavvyPig, .stavvyRaven:
            let characterX = TheOriginalAnimatedNodes(
                animatedGif: getBirdName,
                correctAspectRatioFor: inGameConf.characterDimensions.width)
            characterX.xScale = sizeOfCharacter.x
            characterX.yScale = sizeOfCharacter.y
            inGameConf.currBirdCharForGame = characterX
         
        case .stavvyGold:
            let characterX = GoldBirdPhysics(
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
    
    unowned var myConfigForScene: ConfigForScenes
    var overlay: GameOverlay!
    
    
    private(set) var scoreForCurrentSessionLabel: SKLabelNode?
        
    init(scene: ConfigForScenes) {
        self.myConfigForScene = scene
        super.init()
     
        overlay = GameOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: 99)
        scoreForCurrentSessionLabel = overlay.myCurrSpritNod.childNode(withName: "Session Score") as? SKLabelNode
    }
       
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        if previousState is InGameState {
            myConfigForScene.destroyColumns()
        }
        
        myConfigForScene.currBirdCharForGame?.isInteractable = false
        
        updateScores()
        
        updasteOverlayPresentation()
        
        myConfigForScene.overlay = overlay
        myConfigForScene.isHUDHidden = true
        
        myConfigForScene.currBirdCharForGame?.willRelive = false
        
        myConfigForScene.scene?.removeAllActions()
        
        myConfigForScene.score = 0
        
        if myConfigForScene.isSoundOn {
            if let playingAudioNodeName = myConfigForScene.playingAudio.name {
                myConfigForScene.scene?.childNode(withName: playingAudioNodeName)?.removeFromParent()
            }
            if myConfigForScene.scene?.childNode(withName: myConfigForScene.menuAudio.name!) == nil {
                myConfigForScene.scene?.addChild(myConfigForScene.menuAudio)
                SKAction.play()
            }
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        if nextState is InGameState {
            myConfigForScene.overlay = nil
            myConfigForScene.isHUDHidden = false
            myConfigForScene.currBirdCharForGame?.isInteractable = true
        }
    }
        
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
}

extension GameOverState {
    fileprivate func updateScores() {
        let highestScoreAchieved = UserDefaults.standard.integer(for: .highestScoreAchieved)
        let scoreForCurrentSession = myConfigForScene.score
        
        if scoreForCurrentSession > highestScoreAchieved {
            UserDefaults.standard.set(scoreForCurrentSession, for: .highestScoreAchieved)
            let utilityScene = RoutingUtilityScene()
            utilityScene.saveScore(score: scoreForCurrentSession)
        }
        UserDefaults.standard.set(scoreForCurrentSession, for: .lastScore)
    }
    
    fileprivate func updasteOverlayPresentation() {
        let myCurrSpritNod = overlay.myCurrSpritNod
        
        if let highestScoreAchievedLabel = myCurrSpritNod.childNode(withName: "Highest Score") as? SKLabelNode {
            let highestScoreAchieved = UserDefaults.standard.integer(for: .highestScoreAchieved)
            highestScoreAchievedLabel.text = "Most Bounces: \(highestScoreAchieved)"
        }
        
        if let scoreForCurrentSession = myCurrSpritNod.childNode(withName: "Session Score") as? SKLabelNode {
            scoreForCurrentSession.text = "Bounces: \(myConfigForScene.score)"
        }
    }
}

class PausedState: GKState {
        
    var overlaySceneFileName: String {
        return Scenes.pause.getName()
    }
    
    unowned var myConfigForScene: SKScene
    unowned var inGameConf: ConfigForScenes
    var overlay: GameOverlay!
        
    init(scene: SKScene, inGameConf: ConfigForScenes) {
        self.myConfigForScene = scene
        self.inGameConf = inGameConf
        super.init()
        overlay = GameOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: 999)
    }
        
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        myConfigForScene.isPaused = true
        inGameConf.overlay = overlay
        inGameConf.isHUDHidden = true
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        myConfigForScene.isPaused = false
        inGameConf.overlay = nil
        inGameConf.isHUDHidden = false
    }
        
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
}





