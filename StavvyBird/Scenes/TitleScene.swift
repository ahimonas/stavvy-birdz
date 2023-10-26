//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit

class TitleScene: RoutingUtilityScene {
        
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
        guard let pendingNode = childNode(withName: "Animated Bird") else {
            return
        }
        
        let playableCharacter = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
        
        let assetName = playableCharacter.getAssetName()
        let playerSize = CGSize(width: 200, height: 200)
        
        switch playableCharacter {
            
        case .bird:
            let stavvyBirdNode = BirdNode(animationTimeInterval: 0.1, withTextureAtlas: assetName, size: playerSize)
            stavvyBirdNode.isAffectedByGravity = false
            stavvyBirdNode.position = pendingNode.position
            stavvyBirdNode.zPosition = pendingNode.zPosition
            scene?.addChild(stavvyBirdNode)
        case .stavvyGold, .stavvyRat, .stavvyPig, .eldyBird, .stavvyRaven:
            let myCurrPlayerNode = NyancatNode(animatedGif: assetName, correctAspectRatioFor: playerSize.width)
            myCurrPlayerNode.xScale = 1.0
            myCurrPlayerNode.yScale = 1.0
            
            myCurrPlayerNode.isAffectedByGravity = false
            myCurrPlayerNode.position = pendingNode.position
            myCurrPlayerNode.zPosition = pendingNode.zPosition
            scene?.addChild(myCurrPlayerNode)
        }
        
        pendingNode.removeFromParent()
    }
}
