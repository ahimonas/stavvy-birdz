//  SounioTechnologies LLC
//  StavvyBird
// revisit


import GameplayKit
import SpriteKit

class PlayingState: GKState {
        
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
            infinitePipeProducer = PipeFactory.launch(for: scene, targetNode: target)
        }
        
        adapter.advanceSnowEmitter(for: snowEmitterAdvancementInSeconds)
    }
        
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        adapter.playerCharacter?.isAffectedByGravity = false
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
            adapter.playerCharacter = BirdNode(
                animationTimeInterval: animationTimeInterval,
                withTextureAtlas: assetName,
                size: adapter.playerSize)
        case .coinCat, .gamecat, .hipCat, .jazzCat, .lifelopeCat:
            let player = NyancatNode(
                animatedGif: assetName,
                correctAspectRatioFor: adapter.playerSize.width)
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
        case .coinCat, .gamecat, .hipCat, .jazzCat, .lifelopeCat:
            playerNode.position = CGPoint(x: (playerNode.size.width / 2) - 20, y: scene.size.height / 2)
        }
        playerNode.zPosition = 10

    }
   
}
