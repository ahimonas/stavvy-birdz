//  SounioTechnologies LLC
//  StavvyBird
//revisit

import SpriteKit
import GameplayKit
import GameKit


//Game
class PlayScene: SKScene {

    static var viewportSize: CGSize = .zero
        
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
        InGameState(adapter: sceneAdapeter!),
        GameOverState(scene: sceneAdapeter!),
        PausedState(scene: self, adapter: sceneAdapeter!)
        ])
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var previousTiming : TimeInterval = 0
    let maximumUpdateDeltaTime: TimeInterval = 1.0 / 60.0

    var sceneAdapeter: GameSceneAdapter?
    let selection = UISelectionFeedbackGenerator()
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        self.previousTiming = 0
        sceneAdapeter = GameSceneAdapter(with: self)
        sceneAdapeter?.myGkStateMach = stateMachine
        sceneAdapeter?.myGkStateMach?.enter(InGameState.self)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        PlayScene.viewportSize = view.bounds.size
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneAdapeter?.touchables.forEach({ touchable in
            touchable.touchesBegan(touches, with: event)
        })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneAdapeter?.touchables.forEach { touchable in
            touchable.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneAdapeter?.touchables.forEach { touchable in
            touchable.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneAdapeter?.touchables.forEach { touchable in
            touchable.touchesCancelled(touches, with: event)
        }
    }
        
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        guard view != nil else { return }
        var deltaTime = currentTime - previousTiming
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        previousTiming = currentTime
        if self.isPaused { return }
        stateMachine.update(deltaTime: deltaTime)
        sceneAdapeter?.updatables.filter({ return $0.willRenew }).forEach({ (activeUpdatable) in
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
            sceneAdapeter?.myGkStateMach?.enter(PausedState.self) //showLeaderBoard();
        case .resume:
            sceneAdapeter?.myGkStateMach?.enter(InGameState.self)
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
            sceneAdapeter?.myGkStateMach?.enter(InGameState.self)
        default:
            debugPrint("Unable to invoke")
            
        }
    }
}
