//  SounioTechnologies LLC
//  StavvyBird


import Foundation

// THIS HAS SHOW SCOREBOARD, THIS ALSO HAS ALL BUTTON ACTIONS FOR SKSCENES, transition scenes based on buttons.

import SpriteKit
import GameKit
import UIKit
import StoreKit

class RoutingUtilityScene: SKScene, ButtonNodeResponderType, GKGameCenterControllerDelegate,  SKPaymentTransactionObserver, SKProductsRequestDelegate  {
    var request : SKProductsRequest!
    var products : [SKProduct] = []
    var noAdsPurchased = false
    //var _gameScene: GameSCNScene!
    var gcEnabled = Bool()
    var gcDefaultLeaderboard = String()
    var leaderboardID = "stavvyboard22"
    
    
    var myLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var jumpBtn: SKSpriteNode!
    var playBtn: SKSpriteNode!
    var noAdsBtn:SKSpriteNode!
    var scoreboard :SKSpriteNode!

    func authenticateLocalPlayer() {
        let localPlayer : GKLocalPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler = { (viewController, error) -> Void in
            if viewController != nil {
                let vc = self.view?.window?.rootViewController
                vc?.present(viewController!, animated: true, completion: nil)
                // self.initInAppPurchases()
            } else if localPlayer.isAuthenticated {
                print("player is already authenticated")
                self.gcEnabled = true
                // self.initInAppPurchases()    <--- needs to be authed in game center before we make in app purchase?
                // Get the default leaerboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: ({(leaderboardIdentifer, error) -> Void in
                    if error != nil {
                        // Expression implicitly coerced from 'String?' to 'Any'
                        print(error!.localizedDescription)
                    } else {
                        self.gcDefaultLeaderboard = leaderboardIdentifer!
                    }
                })
                
                )
            }
        }
    }

    
    //++++++++++++++++++++++++++++++
    //++++++ inApp purhchase ++++++
    //++++++++++++++++++++++++++++++
    
    var productInstances = 0;

    
    func inAppPurchase(){
        if(products.count > 0){
            let alert = UIAlertController(title: "In App Purchases", message: "", preferredStyle: UIAlertController.Style.alert)
            /*
             let image = UIImage(named: "airadventurelevel1")
             let action = UIAlertAction(title: "title", style: .default, handler: nil)
             action.setValue(image, forKey: "image")
             alert.addAction(action)
             */
            
            for i in 0 ..< products.count{
                
                productInstances = products.count
                let currentProduct = products[i]
                /*
                print("productIdentifier", currentProduct.productIdentifier)
                print("currentProduct", currentProduct)
                print("currentProduct - localizedTitle", currentProduct.localizedTitle)
                print("currentProduct -  localized price", currentProduct.priceLocale)
                */
                
                if(currentProduct.productIdentifier == "stavvy.bird1.product" && !UserDefaults.standard.bool(forKey: "stavvyBirdLock")){
                    
                    print("stavvy bird found")
                    print(currentProduct.productIdentifier);
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .currency
                    numberFormatter.locale = currentProduct.priceLocale
                    
                    alert.addAction(UIAlertAction(title:currentProduct.localizedTitle + " : " + numberFormatter.string(from:           currentProduct.price)!,style:UIAlertAction.Style.default){_ in
                        self.buyProduct(product: currentProduct)
                        
                    })
                }
                
                if(currentProduct.productIdentifier == "stavvy.bird.raven.prod" && !UserDefaults.standard.bool(forKey: "removeRavensLock")){
                    
                    print("ravens bird found")
                    print(currentProduct.productIdentifier);
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .currency
                    numberFormatter.locale = currentProduct.priceLocale
                    
                    alert.addAction(UIAlertAction(title:currentProduct.localizedTitle + " : " + numberFormatter.string(from:           currentProduct.price)!,style:UIAlertAction.Style.default){_ in
                        
                        self.buyProduct(product: currentProduct)
                        
                    })
                }
                
                if(currentProduct.productIdentifier == "stavvy.birds.eldy.product" && !UserDefaults.standard.bool(forKey: "removeEldyLock")){
                    
                    print("eldy bird found")
                    print(currentProduct.productIdentifier);
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .currency
                    numberFormatter.locale = currentProduct.priceLocale
                    
                    alert.addAction(UIAlertAction(title:currentProduct.localizedTitle + " : " + numberFormatter.string(from:           currentProduct.price)!,style:UIAlertAction.Style.default){_ in
                        
                        self.buyProduct(product: currentProduct)
                        
                    })
                }
                
                
                
                
            }
            
            if(!UserDefaults.standard.bool(forKey: "removeEldyLock")){
                alert.addAction(UIAlertAction(title:"Restore", style:UIAlertAction.Style.default){_ in
                    self.restorePurchaseProducts()
                })
            }
            
            
            alert.addAction(UIAlertAction(title:"Cancel",style:UIAlertAction.Style.default){_ in
                print("cancelled purchase")
            })
            
            
            
            //_gameScene.scnView?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            
            
            
            let vc = self.view?.window?.rootViewController
            if vc?.presentedViewController == nil {
                vc!.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    // Buy the product
    func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    

    //Called when processing the purchase
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch(transaction.transactionState){
                
            case .purchasing:
                print("Transaction State: Purchasing")
                
            case .purchased:
                if transaction.payment.productIdentifier == "stavvy.bird.raven.prod"  && !UserDefaults.standard.bool(forKey: "removeRavensLock") {
                    print("Transaction State: Purchased - racent bird" )
                    //set remove lock to true and hide purchase button after purchase
                    UserDefaults.standard.set(true, forKey: "removeRavensLock")
                    lazy var beam = self.childNode(withName: "RavensBird") as! SKSpriteNode
                    beam.isHidden = true;
                    //remove adds from ad sense
                    if let controller = self.view?.window?.rootViewController as? MainUiGameView {
                        controller.removeAd()
                    }
                                        
                }
                
                queue.finishTransaction(transaction)
            
            case .failed:
                print("Payment Error: %@", transaction.error!)
                queue.finishTransaction(transaction)
                
            case .restored:
                
                print("restored product identifiers", transaction.payment.productIdentifier)
                //restore state for ravens if product ID is passed in Restored state
                if transaction.payment.productIdentifier == "stavvy.bird.raven.prod" {
                    print("Transaction State: Restored - ravens")
                    UserDefaults.standard.set(true, forKey: "removeRavensLock")
                    lazy var beam = self.childNode(withName: "RavensBird") as! SKSpriteNode
                    beam.isHidden = true;
                    if let controller = self.view?.window?.rootViewController as? MainUiGameView {
                        controller.removeAd()
                    }
                    
                    print("Transaction State: Restored")
                }
                queue.finishTransaction(transaction)

            case .deferred:
                /*
                if transaction.payment.productIdentifier == "stavvy.birds.eldy.product" {
                    print("Transaction State: Purchased")
                    UserDefaults.standard.set(true, forKey: "removeEldyLock")
                    handleNoAdsPurchased()
                }
                 */
                
                print("Transaction State: %@", transaction.transactionState)


            }//switch
        }//for loop
    }//payment queue
    

    
    func handleNoAdsPurchased(){
        noAdsPurchased = true
    
        //noAdsBtn.isHidden = true
        
        UserDefaults.standard.set(true, forKey: "removeAdsKey")
        /*
        var currentScore = 100 //change that to the players current score.
        let highScore  = UserDefaults.standard.integer(forKey: "highScore") //Get the users high score from last time.

        if(currentScore > highScore){// check and see if currentScore is greater than highScore.
            UserDefaults.standard.set(currentScore, forKey: "highScore")//if currentScore is greater than highScore, set it in UserDefualts.
        }
         */

       

    }
    
    
    
    //Called when appstore responds and populates the products array
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("products request received")
        self.products = response.products
        self.request = nil
        print("products count: ", products.count)
        print("SKProduct ", products)
        //print("SKProduct1 ", products.first?.localizedTitle)
        //print("SKProduct2 ", products.last?.localizedTitle)
        if(response.invalidProductIdentifiers.count != 0){
            print(" *** products request not received ***")
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    //Restore purchases
    func restorePurchaseProducts() {
        debugPrint("restoring")
        //SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()

        //SKPaymentQueue.default().restoreCompletedTransactions()
        
        //SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //Called when an error happens in communication
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error)
        self.request = nil
    }
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // ...
        debugPrint("paymentQueueRestoreCompletedTransactionsFinished")
        
    }
    
    
    /**
     Initializes in-app purchases and retrieves the list of possible purchases.
     
     - Parameters: None
     - Returns: None
     */
    func initInAppPurchases() {

        print("In App Purchases Initialized")
        SKPaymentQueue.default().add(self)
        // Get the list of possible purchases
        if self.request == nil {
            self.request = SKProductsRequest(productIdentifiers: Set(["stavvy.bird.raven.prod"]))
            // self.request = SKProductsRequest(productIdentifiers: Set(["stavvy.bird1.product", "stavvy.bird.raven.prod", //"stavvy.birds.eldy.product"]))
            self.request.delegate = self
            self.request.start()
        }
    }
    /*
    func initInAppPurchases() {
        print("In App Purchases Initialized")
        SKPaymentQueue.default().add(self)
        // Get the list of possible purchases
        if self.request == nil {
           
           // self.request = SKProductsRequest(productIdentifiers: Set(["stavvy.bird1.product", "stavvy.bird.raven.prod", //"stavvy.birds.eldy.product"]))
            
            self.request = SKProductsRequest(productIdentifiers: Set(["stavvy.bird.raven.prod"]))
            self.request.delegate = self
            self.request.start()
        }
    }
    */

    func  printDefaults(){
        print(UserDefaults.standard.dictionaryRepresentation())
        print(UserDefaults.standard.dictionaryRepresentation().keys)
        print(UserDefaults.standard.dictionaryRepresentation().values)
    }
    
    // ++++++++++++++++++++++++++++++
    // ++++++++ Gamecenter ++++++++++
    // ++++++++++++++++++++++++++++++
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

    //shows leaderboard screen
    func showLeaderboard() {
        print("show leaderboard")
        // A new instance of a game center view controller:
        let gameCenter = GKGameCenterViewController(
                leaderboardID: self.leaderboardID,
                playerScope: .global,
                timeScope: .allTime)
        // Set this scene as the delegate (helps enable the
        // done button in the game center)
        gameCenter.gameCenterDelegate = self

        // gameCenter.leaderboardIdentifier = self.leaderboardID
        // Show the leaderboards when the game center opens:
        // gameCenter.viewState =
        //     GKGameCenterViewControllerState.leaderboards
        // Find the current view controller:
        if let gameViewController =
            self.view?.window?.rootViewController {
            // Display the new Game Center view controller:
            gameViewController.show(gameCenter, sender: self)
            gameViewController.navigationController?
                .pushViewController(gameCenter, animated: true)
        }
        // present(gameCenter, animated: true, completion: nil)
    }

 
    
   func saveScore(score: Int) {
    if GKLocalPlayer.local.isAuthenticated {

        // Submit a score to one or more leaderboards.
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
        leaderboardIDs: [self.leaderboardID]) { error in
            if error != nil {
                print("Error: \(error!.localizedDescription).")
            }
            else {
                print("Score submitted to your Leaderboard: \(score).")
            }
        }   
        }
    }
    
    let selection = UISelectionFeedbackGenerator()
    static let sceneScaleMode: SKSceneScaleMode = .aspectFill
    private static var lastPushTransitionDirection: SKTransitionDirection?
    
    func buttonTriggered(button: ButtonNode) {
        guard let identifier = button.buttonIdentifier else {
            return
        }
        selection.selectionChanged()
    
        var sceneToPresent: SKScene?
        var transition: SKTransition?
        let sceneScaleMode: SKSceneScaleMode = RoutingUtilityScene.sceneScaleMode
        
        switch identifier {
        case .play:
            let sceneId = Scenes.game.getName()
            sceneToPresent = PlayScene(fileNamed: sceneId)
            
            transition = SKTransition.fade(withDuration: 1.0)
        case .settings:
            let sceneId = Scenes.setting.getName()
            sceneToPresent = AtmosphereScene(fileNamed: sceneId)
            
            RoutingUtilityScene.lastPushTransitionDirection = .down
            transition = SKTransition.push(with: .down, duration: 1.0)
        case .scores:
            showLeaderboard()
            /*
            let sceneId = Scenes.score.getName()
            sceneToPresent = ScoresScene(fileNamed: sceneId)
            
            RoutingUtilityScene.lastPushTransitionDirection = .up
            transition = SKTransition.push(with: .up, duration: 1.0)
            */
        case .ItemShopCharacters:
            //authenticateLocalPlayer()
           initInAppPurchases()
  
            let sceneId = Scenes.ItemShopCharacters.getName()
            sceneToPresent = ItemShopScene(fileNamed: sceneId)
            debugPrint("created ItemShopScene instance")
            RoutingUtilityScene.lastPushTransitionDirection = .right
            transition = SKTransition.push(with: .right, duration: 1.0)
            /*
            if(!UserDefaults.standard.bool(forKey: "removeAdsKey")){
                
                initInAppPurchases()
                
                //noAdsBtn = SKSpriteNode(imageNamed: "noAdsBtn")
               // noAdsBtn.position = CGPoint(x: size.width * 0.9, y: size.height * 0.8)
               // noAdsBtn.setScale(0.75)
             //   self.addChild(noAdsBtn)
              //  noAdsBtn.name = "noAdsBtn"
            }
             */
            
  

        case .raven:
            initInAppPurchases()
             inAppPurchase()
             if !UserDefaults.standard.bool(forKey: "removeRavensLock") {
                 var tempCount = 0;
                 while(productInstances == 0 && tempCount < 30000){
                     inAppPurchase()
                     tempCount = tempCount + 1;
                     print(tempCount)
                 }
             }
            debugPrint("raven button pressed - purchase non-consumable")
        
        case .eldy:
            initInAppPurchases()
            inAppPurchase()
            debugPrint("eldy button pressed - purchase non-consumable")
        /*
        case .venu:
            saveScore(score: 10)
            //initInAppPurchases()
            debugPrint("venue - Init app purchase flow button")
            
        case .penu:
            showLeaderboard()
            //inAppPurchase()
            debugPrint("penue - purchase non-consumable")
            
        case .zenu:
            showLeaderboard()
            */ 
        case .menu:
            let sceneId = Scenes.title.getName()
            sceneToPresent = HomeScene(fileNamed: sceneId)
            var pushDirection: SKTransitionDirection?
            
            if let lastPushTransitionDirection = RoutingUtilityScene.lastPushTransitionDirection {
                switch lastPushTransitionDirection {
                case .up:
                    pushDirection = .down
                case .down:
                    pushDirection = .up
                case .left:
                    pushDirection = .right
                case .right:
                    pushDirection = .left
                @unknown default:
                    fatalError("Menu unable to handle directions.")
                }
                RoutingUtilityScene.lastPushTransitionDirection = pushDirection
            }
            if let pushDirection = pushDirection {
                transition = SKTransition.push(with: pushDirection, duration: 1.0)
            } else {
                transition = SKTransition.fade(withDuration: 1.0)
            }
            

            //let controller = sceneToPresent?.rootViewController as! MainUiGameView
            //controller.removeAd()
             
            
        default:
            debugPrint(#function + "BUTTON NOT SUPPORTED BY TITLE SCNE ")
        }
        
        guard let presentationScene = sceneToPresent, let unwrappedTransition = transition  else {
            return
        }
        
        presentationScene.scaleMode = sceneScaleMode
        unwrappedTransition.pausesIncomingScene = false
        unwrappedTransition.pausesOutgoingScene = false
        self.view?.presentScene(presentationScene, transition: unwrappedTransition)
        //self.view?.inputViewController.remove
        

        
        debugPrint("presented ItemShopScene instance")
    }
    


}
