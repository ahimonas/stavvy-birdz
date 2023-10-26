//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit

//characters
class ItemShopScene: RoutingUtilityScene {
    //@IBOutlet weak var EldyBird: UIButton!

    private var boughtEldy = false
    // MARK: - Properties
    
    private var selectNode: SKShapeNode?
    private var playableCharacters: [PlayableCharacter : SKNode] = [:]
    
    // MARK: - Overrides
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        

        //hides the purchase button for raven if it is set to purchased when transitioning to scene
        if(UserDefaults.standard.bool(forKey: "removeRavensLock")){
            lazy var beam = { return self.childNode(withName: "RavensBird") as! SKSpriteNode}()
            beam.isHidden = true;
        }
        /*
         debugPrint("huh")
         var hi = UserDefaults.standard.bool(forKey: "removeEldyLock");
         debugPrint(hi)
        if(UserDefaults.standard.bool(forKey: "removeEldyLock")){
            debugPrint("huh")

            lazy var beam = { return self.childNode(withName: "EldyBird") as! SKSpriteNode}()
            beam.isHidden = true;
            debugPrint(beam)
        }
         */
       // EldyBird.isHidden = true
       // let defaults = UserDefaults.standard
       // defaults.dictionaryRepresentation().map{print("\($0.key): \($0.value)")}
        
        func preparePlayableCharacters() {
            let stavvyBird = childNode(withName: PlayableCharacter.bird.rawValue) as? SKSpriteNode
            playableCharacters[.bird] = stavvyBird
            
            let scale = CGPoint(x: 0.6, y: 0.6)
            
            let stavvyRat = childNode(withName: PlayableCharacter.stavvyRat.rawValue) as? NyancatNode
            stavvyRat?.xScale = scale.x
            stavvyRat?.yScale = scale.y
            playableCharacters[.stavvyRat] = stavvyRat
            
            let stavvyGold = childNode(withName: PlayableCharacter.stavvyGold.rawValue) as? NyancatNode
            stavvyGold?.xScale = scale.x
            stavvyGold?.yScale = scale.y
            playableCharacters[.stavvyGold] = stavvyGold
            
            let stavvyPig = childNode(withName: PlayableCharacter.stavvyPig.rawValue) as? NyancatNode
            stavvyPig?.xScale = scale.x
            stavvyPig?.yScale = scale.y
            playableCharacters[.stavvyPig] = stavvyPig
            
            let eldyBird = childNode(withName: PlayableCharacter.eldyBird.rawValue) as? NyancatNode
            eldyBird?.xScale = scale.x
            eldyBird?.yScale = scale.y
            playableCharacters[.eldyBird] = eldyBird
            // ravens position 5
            let stavvyRaven = childNode(withName: PlayableCharacter.stavvyRaven.rawValue) as? NyancatNode
            stavvyRaven?.xScale = scale.x
            stavvyRaven?.yScale = scale.y
            playableCharacters[.stavvyRaven] = stavvyRaven
             
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

        
        if(selectedPlayableCharacter.rawValue.replacingOccurrences(of: "\"", with: "") == "eldyBird"){ //thsi is eldy
            //print("UserDefaults.standard.bool(forKey: removeEldyLock");
            print(UserDefaults.standard.bool(forKey: "removeEldyLock"));
            let hi2 = UserDefaults.standard.bool(forKey: "removeEldyLock");
            debugPrint(hi2)
            if(UserDefaults.standard.bool(forKey: "removeEldyLock")){
                select(playableCharacter: selectedPlayableCharacter, animated: true)
                UserDefaults.standard.set(selectedPlayableCharacter, for: .character)
                debugPrint("eldyBird str-eldy was paid for ")

                lazy var beam = { return self.childNode(withName: "EldyBird") as! SKSpriteNode}()
                beam.isHidden = true;
                debugPrint(beam)


                /*
                if let controller = self.view?.window?.rootViewController as? GameViewController {
                    controller.removeAd()
                }
                 */

            }
            debugPrint("eldyBird str-eldy not available ")
        }
        
        //remove lock after selecting character from payment for ravens bird, should transition back to scene ?
        if(selectedPlayableCharacter.rawValue.replacingOccurrences(of: "\"", with: "") == "stavvyRaven"){ //raven
            print("UserDefaults.standard.bool(forKey: removeRavensLock", UserDefaults.standard.bool(forKey: "removeRavensLock"));

            if(UserDefaults.standard.bool(forKey: "removeRavensLock")){
                
                //I think this is an extra hide I dont need,
                lazy var beam = { return self.childNode(withName: "RavensBird") as! SKSpriteNode}()
                beam.isHidden = true;
                
                select(playableCharacter: selectedPlayableCharacter, animated: true)
                UserDefaults.standard.set(selectedPlayableCharacter, for: .character)
                debugPrint(" ravens bird was paid for ")
                
                if let controller = self.view?.window?.rootViewController as? GameViewController {
                    controller.removeAd()
                }
                 

            }
            debugPrint("eldy birf not available ")
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
            let hide = SKAction.fadeOut(withDuration: 0.14)
            let unhide = SKAction.fadeIn(withDuration: 0.14)
            let move = SKAction.move(to: playableCharacterNode.position, duration: 0.0)
            let sequece = SKAction.sequence([hide, move, unhide])
            selectNode?.run(sequece)
        } else {
            selectNode?.position = playableCharacterNode.position
        }
    }
    
}
