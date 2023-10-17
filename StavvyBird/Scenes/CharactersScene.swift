//
//  CharactersScene.swift
//  StavvyBird
//


//

import SpriteKit

class CharactersScene: RoutingUtilityScene {
    //@IBOutlet weak var EldyBird: UIButton!

    
    private var boughtEldy = false
    // MARK: - Properties
    
    private var selectNode: SKShapeNode?
    private var playableCharacters: [PlayableCharacter : SKNode] = [:]
    
    // MARK: - Overrides
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
       // EldyBird.isHidden = true
       // let defaults = UserDefaults.standard
       // defaults.dictionaryRepresentation().map{print("\($0.key): \($0.value)")}
        
        func preparePlayableCharacters() {
            let birdNode = childNode(withName: PlayableCharacter.bird.rawValue) as? SKSpriteNode
            playableCharacters[.bird] = birdNode
            
            let scale = CGPoint(x: 0.6, y: 0.6)
            
            let gameCat = childNode(withName: PlayableCharacter.gamecat.rawValue) as? NyancatNode
            gameCat?.xScale = scale.x
            gameCat?.yScale = scale.y
            playableCharacters[.gamecat] = gameCat
            
            let coinCat = childNode(withName: PlayableCharacter.coinCat.rawValue) as? NyancatNode
            coinCat?.xScale = scale.x
            coinCat?.yScale = scale.y
            playableCharacters[.coinCat] = coinCat
            
            let hipCat = childNode(withName: PlayableCharacter.hipCat.rawValue) as? NyancatNode
            hipCat?.xScale = scale.x
            hipCat?.yScale = scale.y
            playableCharacters[.hipCat] = hipCat
            
            let jazzCat = childNode(withName: PlayableCharacter.jazzCat.rawValue) as? NyancatNode
            jazzCat?.xScale = scale.x
            jazzCat?.yScale = scale.y
            playableCharacters[.jazzCat] = jazzCat
            // ravens position 5
            let lifelopeCat = childNode(withName: PlayableCharacter.lifelopeCat.rawValue) as? NyancatNode
            lifelopeCat?.xScale = scale.x
            lifelopeCat?.yScale = scale.y
            playableCharacters[.lifelopeCat] = lifelopeCat
             
        }
        
        selectNode = childNode(withName: "Select Node") as? SKShapeNode
        preparePlayableCharacters()
      
        func loadSelectedChacter() {
            let playableCharacter = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
            print(playableCharacter)
            select(playableCharacter: playableCharacter, animated: false)
        }
        loadSelectedChacter()
    }
    
    // MARK: - Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)
        let touchedNodes = self.nodes(at: location)
        
        guard let firstTouchedNode = touchedNodes.first else {
            return
        }
        
        guard let name = firstTouchedNode.name, let selectedPlayableCharacter = PlayableCharacter(rawValue: name) else {
            return
        }
        
        //print(event ?? <#default value#>)
        lazy var beam = self.childNode(withName: "EldyBird") as! SKSpriteNode
        beam.isHidden = true;
        debugPrint(beam)
        
        debugPrint(selectedPlayableCharacter)
        debugPrint(selectedPlayableCharacter.rawValue)

        if(selectedPlayableCharacter.rawValue.replacingOccurrences(of: "\"", with: "") == "jazzCat"){
            print("UserDefaults.standard.bool(forKey: removeEldyLock");
            print(UserDefaults.standard.bool(forKey: "removeEldyLock"));
            if(UserDefaults.standard.bool(forKey: "removeEldyLock")){
                select(playableCharacter: selectedPlayableCharacter, animated: true)
                UserDefaults.standard.set(selectedPlayableCharacter, for: .character)
                debugPrint("jazzcat str-eldy was paid for ")

                lazy var beam = { return self.childNode(withName: "EldyBird") as! SKSpriteNode}()
                beam.isHidden = true;
                debugPrint(beam)


                /*
                if let controller = self.view?.window?.rootViewController as? GameViewController {
                    controller.removeAd()
                }
                 */

            }
            debugPrint("jazzcat str-eldy not available ")
        }
        if(selectedPlayableCharacter.rawValue.replacingOccurrences(of: "\"", with: "") == "lifelopeCat"){
            print("UserDefaults.standard.bool(forKey: removeRavensLock");
            print(UserDefaults.standard.bool(forKey: "removeRavensLock"));
            if(UserDefaults.standard.bool(forKey: "removeRavensLock")){
                select(playableCharacter: selectedPlayableCharacter, animated: true)
                UserDefaults.standard.set(selectedPlayableCharacter, for: .character)
                debugPrint("lifelopeCat ravens birg was paid for ")
                /*
                if let controller = self.view?.window?.rootViewController as? GameViewController {
                    controller.removeAd()
                }
                 */

            }
            debugPrint("jazzcat str-eldy not available ")
        }
        else{
            select(playableCharacter: selectedPlayableCharacter, animated: true)
            UserDefaults.standard.set(selectedPlayableCharacter, for: .character)
        }
    }
    
    // MARK: - Selection Utils
    
    private func select(playableCharacter: PlayableCharacter, animated: Bool) {
        guard let playableCharacterNode = playableCharacters[playableCharacter] else {
            return
        }
        
        if animated {
            let hide = SKAction.fadeOut(withDuration: 0.15)
            let unhide = SKAction.fadeIn(withDuration: 0.15)
            let move = SKAction.move(to: playableCharacterNode.position, duration: 0.0)
            let sequece = SKAction.sequence([hide, move, unhide])
            selectNode?.run(sequece)
        } else {
            selectNode?.position = playableCharacterNode.position
        }
    }
    
}
