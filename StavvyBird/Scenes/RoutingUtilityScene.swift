//
//  RoutingUtilityScene.swift
//  StavvyBird

// THIS HAS SHOW SCOREBOARD, THIS ALSO HAS ALL BUTTON ACTIONS FOR SKSCENES, transition scenes based on buttons.

import SpriteKit
import GameKit
import UIKit
import StoreKit

class RoutingUtilityScene: SKScene, ButtonNodeResponderType, GKGameCenterControllerDelegate,   SKPaymentTransactionObserver, SKProductsRequestDelegate  {
    var request : SKProductsRequest!
    var products : [SKProduct] = []
    var noAdsPurchased = false
    //var _gameScene: GameSCNScene!
    var myLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var jumpBtn: SKSpriteNode!
    var playBtn: SKSpriteNode!
    var noAdsBtn:SKSpriteNode!
    
    
    
    //++++++++++++++++++++++++++++++
    //++++++ inApp purhchase ++++++
    //++++++++++++++++++++++++++++++
    
    func inAppPurchase(){
        
        let alert = UIAlertController(title: "In App Purchases", message: "", preferredStyle: UIAlertController.Style.alert)
        
        for i in 0 ..< products.count{
            let currentProduct = products[i]
            
            if(currentProduct.productIdentifier == "stavvy.consume.product" && noAdsPurchased == false){
                
                print("removead found")
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = currentProduct.priceLocale
                
                alert.addAction(UIAlertAction(title:currentProduct.localizedTitle + " : " + numberFormatter.string(from:           currentProduct.price)!,style:UIAlertAction.Style.default){_ in
                    
                    self.buyProduct(product: currentProduct)
                    
                })
            }
        }
        
        if(noAdsPurchased == false){
            alert.addAction(UIAlertAction(title:"Restore", style:UIAlertAction.Style.default){_ in
                self.restorePurchaseProducts()
            })
        }
        
        
        alert.addAction(UIAlertAction(title:"Cancel",style:UIAlertAction.Style.default){_ in
            print("cancelled purchase")
        })
        
        //_gameScene.scnView?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }//inapppurchase
    
    
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
                if transaction.payment.productIdentifier == "stavvy.consume.product" {
                    print("Transaction State: Purchased")
                    handleNoAdsPurchased()
                }
                queue.finishTransaction(transaction)
            case .failed:
                print("Payment Error: %@", transaction.error!)
                queue.finishTransaction(transaction)
            case .restored:
                if transaction.payment.productIdentifier == "stavvy.consume.product" {
                    print("Transaction State: Restored")
                    handleNoAdsPurchased()
                }
                queue.finishTransaction(transaction)
            case .deferred:
                print("Transaction State: %@", transaction.transactionState)
            }//switch
        }//for loop
    }//payment queue
    
    func handleNoAdsPurchased(){
        noAdsPurchased = true
    
        noAdsBtn.isHidden = true
        
        UserDefaults.standard.set(true, forKey: "removeAdsKey")
        
        //let controller = _gameScene.scnView?.window?.rootViewController as! GameViewController
        //controller.removeAd()

    }


    
    
    
    //Called when appstore responds and populates the products array
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print("products request received")
        
        self.products = response.products
        self.request = nil
        
        print("products count: ", products.count)
        
        if(response.invalidProductIdentifiers.count != 0){
            print(" *** products request not received ***")
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    //Restore purchases
    func restorePurchaseProducts() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //Called when an error happens in communication
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error)
        self.request = nil
    }
    
    
    // Initialize the App Purchases
    func initInAppPurchases() {
        print("In App Purchases Initialized")
        
        SKPaymentQueue.default().add(self)
        
        // Get the list of possible purchases
        if self.request == nil {
            self.request = SKProductsRequest(productIdentifiers: Set(["stavvy.consume.product"]))
            self.request.delegate = self
            self.request.start()
        }
    }
    

    func showLeaderBoard(){

        let viewController = self.view?.window?.rootViewController
         let gcvc = GKGameCenterViewController()

         gcvc.gameCenterDelegate = self

        viewController?.present(gcvc, animated: true, completion: nil)


     }


    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
     }
    
    
    
    //Call this when ur highscore should be saved
    func saveHighScore(number:Int){

        if(GKLocalPlayer.local.isAuthenticated){

            let scoreReporter = GKScore(leaderboardIdentifier: "stavvyboard22")
            scoreReporter.value = Int64(number)

            let scoreArray: [GKScore] = [scoreReporter]

            GKScore.report(scoreArray, withCompletionHandler: nil)

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
            sceneToPresent = GameScene(fileNamed: sceneId)
            
            transition = SKTransition.fade(withDuration: 1.0)
        case .settings:
            let sceneId = Scenes.setting.getName()
            sceneToPresent = SettingsScene(fileNamed: sceneId)
            
            RoutingUtilityScene.lastPushTransitionDirection = .down
            transition = SKTransition.push(with: .down, duration: 1.0)
        case .scores:
            let sceneId = Scenes.score.getName()
            sceneToPresent = ScoresScene(fileNamed: sceneId)
            
            RoutingUtilityScene.lastPushTransitionDirection = .up
            transition = SKTransition.push(with: .up, duration: 1.0)
            
        case .characters:
            let sceneId = Scenes.characters.getName()
            sceneToPresent = CharactersScene(fileNamed: sceneId)
            debugPrint("created CharactersScene instance")
            
            RoutingUtilityScene.lastPushTransitionDirection = .right
            transition = SKTransition.push(with: .right, duration: 1.0)
            
        case .venu:
            let tryCountCurrent :Int = 4
            initInAppPurchases()
            saveHighScore(number: tryCountCurrent)
            debugPrint("venueee button")
            //showLeaderBoard()

            
            
        case .menu:
            inAppPurchase()
            /*
            let sceneId = Scenes.title.getName()
            sceneToPresent = TitleScene(fileNamed: sceneId)
            
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
                    fatalError("Unknown case was deteced in .menu case in buttonTriggered method. Please, make sure that all the cases are properly handled.")
                }
                RoutingUtilityScene.lastPushTransitionDirection = pushDirection
            }
            if let pushDirection = pushDirection {
                transition = SKTransition.push(with: pushDirection, duration: 1.0)
            } else {
                transition = SKTransition.fade(withDuration: 1.0)
            }
             */
            
        default:
            debugPrint(#function + "triggered button node action that is not supported by the TitleScene class")
        }
        
        guard let presentationScene = sceneToPresent, let unwrappedTransition = transition  else {
            return
        }
        
        presentationScene.scaleMode = sceneScaleMode
        unwrappedTransition.pausesIncomingScene = false
        unwrappedTransition.pausesOutgoingScene = false
        self.view?.presentScene(presentationScene, transition: unwrappedTransition)
        debugPrint("presented CharactersScene instance")
    }
}

//https://cloud.tencent.com/developer/ask/sof/113518506
