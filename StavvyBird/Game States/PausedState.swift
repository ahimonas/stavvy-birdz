//  SounioTechnologies LLC
//  StavvyBird
//revisit

import GameplayKit
import SpriteKit

class PausedState: GKState {
        
    var overlaySceneFileName: String {
        return Scenes.pause.getName()
    }
    
    unowned var levelScene: SKScene
    unowned var adapter: GameSceneAdapter
    var overlay: SceneOverlay!
        
    init(scene: SKScene, adapter: GameSceneAdapter) {
        self.levelScene = scene
        self.adapter = adapter
        super.init()
        overlay = SceneOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: 1000)
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
    
    // MARK: Convenience
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
}
