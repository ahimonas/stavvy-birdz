//  SounioTechnologies LLC
//  StavvyBird
// revisit

import GameplayKit
import SpriteKit

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
