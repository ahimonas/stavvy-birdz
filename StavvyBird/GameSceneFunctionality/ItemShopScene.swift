//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit

//ItemShopCharacters
class ItemShopScene: RoutingUtilityScene {
    private var boughtEldy = false
    private var characterSelector: SKShapeNode?
    private var playableCharacters: [PlayableCharacter : SKNode] = [:]
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
            let currGkPoint=CGPoint(x: 0.6, y: 0.6)
            let currGkPointEldy=CGPoint(x: 0.4, y: 0.4)

            let stavvyBird =
            childNode(withName: PlayableCharacter.bird.rawValue) as? SKSpriteNode; playableCharacters[.bird] = stavvyBird
            
            let stavvyRat =
            childNode(withName: PlayableCharacter.stavvyRat.rawValue) as? TheOriginalAnimatedNodes
            stavvyRat?.xScale = currGkPoint.x; stavvyRat?.yScale = currGkPoint.y; playableCharacters[.stavvyRat] = stavvyRat
            
            let stavvyGold =
            childNode(withName: PlayableCharacter.stavvyGold.rawValue) as? GoldBirdPhysics
            stavvyGold?.xScale = currGkPoint.x; stavvyGold?.yScale = currGkPoint.y; playableCharacters[.stavvyGold] = stavvyGold
            
            let stavvyPig =
            childNode(withName: PlayableCharacter.stavvyPig.rawValue) as? TheOriginalAnimatedNodes
            stavvyPig?.xScale = currGkPoint.x; stavvyPig?.yScale = currGkPoint.y; playableCharacters[.stavvyPig] = stavvyPig
            
            let eldyBird =
            childNode(withName: PlayableCharacter.eldyBird.rawValue) as? EldyBirdPhysics
            eldyBird?.xScale = currGkPointEldy.x; eldyBird?.yScale = currGkPointEldy.y; playableCharacters[.eldyBird] = eldyBird
            
            let stavvyRaven =
            childNode(withName: PlayableCharacter.stavvyRaven.rawValue) as? TheOriginalAnimatedNodes
            stavvyRaven?.xScale = currGkPoint.x; stavvyRaven?.yScale = currGkPoint.y; playableCharacters[.stavvyRaven] = stavvyRaven
        }
        
        characterSelector = childNode(withName: "Charcter Selection") as? SKShapeNode
        preparePlayableCharacters()
      
        func loadSelectedChacter() {
            let playableCharacter = UserDefaults.standard.playableCharacter(for: .character) ?? .bird
            print(playableCharacter)
            select(playableCharacter: playableCharacter, animated: true)
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
                if let controller = self.view?.window?.rootViewController as? MainUiGameView {
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
                
                if let controller = self.view?.window?.rootViewController as? MainUiGameView {
                    controller.removeAd()
                }
                 

            }
            debugPrint("eldy birf not available ")
        }
        else{
            
            let character = UserDefaults.standard.playableCharacter(for: .character) ?? .bird

            
            debugPrint("character" , character)
            debugPrint("selectedPlayableCharacter" , selectedPlayableCharacter)

            select(playableCharacter: selectedPlayableCharacter, animated: true)
            unselect(playableCharacter: character)
            UserDefaults.standard.set(selectedPlayableCharacter, for: .character)
        }
    }
    
    
    private var previousCharacter: [PlayableCharacter : SKNode] = [:]

    
    private func select(playableCharacter: PlayableCharacter, animated: Bool) {
        
        debugPrint("selected",playableCharacter)
        guard let playableCharacterNode = playableCharacters[playableCharacter] else {
            return
        }
        
        //let hide = SKAction.fadeOut(withDuration: 0.12)
        let me2 = SKAction.scale(by: 2, duration: 0.1)
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.2)

        let sequence2 = SKAction.sequence([moveUp, moveUp.reversed(), moveUp, moveUp.reversed(), moveUp, moveUp.reversed()])
        
        
        //let me = SKAction.scale(by: 0.9, duration: 0.5)
        //let unhide = SKAction.fadeIn(withDuration: 0.7)
        //let move = SKAction.move(to: playableCharacterNode.position, duration: 0.0)
        let sequece = SKAction.sequence([ me2, sequence2])
        
       // playableCharacterNode.run(sequece)
        
        playableCharacterNode.run(sequece)

        debugPrint("selected after previous", previousCharacter)
        debugPrint("selected after previous", playableCharacter)
        
        /*
        if !animated {
            let hide = SKAction.fadeOut(withDuration: 0.12)
            let me2 = SKAction.scale(by: 1.8, duration: 0.2)

            let me = SKAction.scale(by: 0.9, duration: 0.5)
            let unhide = SKAction.fadeIn(withDuration: 0.7)
            let move = SKAction.move(to: playableCharacterNode.position, duration: 0.0)
            let sequece = SKAction.sequence([ move, me2, me])
            
            playableCharacterNode.run(sequece)
            }
        
        else {
            guard let previousCharacter = playableCharacters[playableCharacter] else {
                return
            }
            
            //let hide = SKAction.fadeOut(withDuration: 0.12)
            let me2 = SKAction.scale(by: 1.2, duration: 0.2)

            //let me = SKAction.scale(by: 0.9, duration: 0.5)
            //let unhide = SKAction.fadeIn(withDuration: 0.7)
            //let move = SKAction.move(to: playableCharacterNode.position, duration: 0.0)
            let sequece = SKAction.sequence([ me2])
            
           // playableCharacterNode.run(sequece)
            
            playableCharacterNode.run(sequece)

            debugPrint("selected after previous", previousCharacter)
            debugPrint("selected after previous", playableCharacter)

        }
         */
     
        /*
        else {
            guard let previousCharacter = playableCharacters[playableCharacter] else {
            return
        }
        
            let me2 = SKAction.scale(by: 1.1, duration: 0.2)

            let me = SKAction.scale(by: 0.9, duration: 0.5)
            let unhide = SKAction.fadeIn(withDuration: 0.7)
            let move = SKAction.move(to: playableCharacterNode.position, duration: 0.0)
            let sequece = SKAction.sequence([ move, me2])
            
            playableCharacterNode.run(sequece)
            
                characterSelector?.position = playableCharacterNode.position
            }

        
*/
    }
    
    private func unselect(playableCharacter: PlayableCharacter) {
        
        debugPrint("selected",playableCharacter)
        guard let playableCharacterNode = playableCharacters[playableCharacter] else {
            return
        }
        
        
            //let hide = SKAction.fadeOut(withDuration: 0.12)
            //let me2 = SKAction.scale(by: 1.8, duration: 0.2)

            let me = SKAction.scale(by: 0.5, duration: 0.2)
            //let unhide = SKAction.fadeIn(withDuration: 0.7)
            //let move = SKAction.move(to: playableCharacterNode.position, duration: 0.0)
            let sequece = SKAction.sequence([me])
            
            playableCharacterNode.run(sequece)
        }
        
        /*
        else {
            guard let previousCharacter = playableCharacters[playableCharacter] else {
            return
        }
        
            let me2 = SKAction.scale(by: 1.1, duration: 0.2)

            let me = SKAction.scale(by: 0.9, duration: 0.5)
            let unhide = SKAction.fadeIn(withDuration: 0.7)
            let move = SKAction.move(to: playableCharacterNode.position, duration: 0.0)
            let sequece = SKAction.sequence([ move, me2])
            
            playableCharacterNode.run(sequece)
            
                characterSelector?.position = playableCharacterNode.position
            }

        
*/
    
}
