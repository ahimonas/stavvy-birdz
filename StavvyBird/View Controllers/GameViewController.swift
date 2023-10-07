//
//  GameViewController.swift
//  StavvyBird
//


//

import UIKit
import SpriteKit
import GameplayKit
import SwiftUI
import GoogleMobileAds
import GameKit
import UIKit
import StoreKit





enum Scenes: String {
    case title = "TitleScene"
    case game = "GameScene"
    case setting = "SettingsScene"
    case score = "ScoreScene"
    case pause = "PauseScene"
    case failed = "FailedScene"
    case characters = "CharactersScene"
}

extension Scenes {
    func getName() -> String {
        let padId = " iPad"
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        return isPad ? self.rawValue + padId : self.rawValue
    }
}

enum NodeScale: Float {
    case gameBackgroundScale
}

extension NodeScale {
    
    func getValue() -> Float {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        switch self {
        case .gameBackgroundScale:
            return isPad ? 1.5 : 1.35
        }
    }
}

extension CGPoint {
    init(x: Float, y: Float) {
        self.init()
        self.x = CGFloat(x)
        self.y = CGFloat(y)
    }
}



class GameViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, GADBannerViewDelegate {

    
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var restore: UIButton!
    @IBOutlet weak var mail: UIImageView!
    @IBOutlet weak var shopDescription: UILabel!
    
    var productsRequest = SKProductsRequest()
    var validProducts = [SKProduct]()
    var productIndex = 0
   
    

    var bannerView: GADBannerView!
    var admobBanner = UIView()
    // MARK: - Overrides
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        bannerView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)

        admobBanner = bannerView
        
        
        
        
        
        buyBtn?.isHidden = true
             shopDescription?.numberOfLines = 0
             shopDescription?.lineBreakMode = NSLineBreakMode.byWordWrapping
             shopDescription?.sizeToFit()
             shopDescription?.text = NSLocalizedString("packpro", comment: "")
             //   SKPaymentQueue.default().add(self)
             let tap4 = UITapGestureRecognizer(target: self, action:#selector(tappedMe5))
             mail?.addGestureRecognizer(tap4)
             mail?.isUserInteractionEnabled = true
             fetchAvailableProducts()
        
        
        
/*
        var bannerView: GADBannerView!
        var admobBanner = UIView()
        //Advertisments
         // In this case, we instantiate the banner with desired ad size.
        
         bannerView = GADBannerView(adSize: GADAdSizeBanner)
         addBannerViewToView(bannerView)
         bannerView.adUnitID = "ca-app-pub-5440760624380114/3970418685"
         bannerView.rootViewController = self
         bannerView.delegate = self
         bannerView.load(GADRequest())
        bannerView.tag = 100
         
        
        //var bannerView: GADBannerView!
         addBannerViewToView2(bannerView)
         bannerView.adUnitID = "ca-app-pub-5440760624380114/3970418685"
         bannerView.rootViewController = self
         navigationController?.toolbar.addSubview(bannerView)
         bannerView.load(GADRequest())
         bannerView.delegate = self
         view.exerciseAmbiguityInLayout()

         admobBanner = bannerView
        */
        
        
  
        //view.addSubview(BannerAd)
        
        let sceneName = Scenes.title.getName()
        
        if let scene = SKScene(fileNamed: sceneName) as? TitleScene {

            // Set the scale mode to scale to fit the window
//            scene.scaleMode = .aspectFit
            scene.scaleMode = .aspectFill
            
            // Present the scene
            if let view = self.view as! SKView? {
                view.presentScene(scene)
                
                view.ignoresSiblingOrder = true
//                view.showsFPS = true
//                view.showsNodeCount = true
//                view.showsPhysics = true
                
            }
/*
            if #available(iOS 13.0, *) {
                AdBannerView(adUnitID: "ca-app-pub-5440760624380114/3970418685").frame(height:200)
            } else {
                // Fallback on earlier versions
            }
 */
        }
    }
    
    func fetchAvailableProducts()  {
           let productIdentifiers = NSSet(objects:
               "stavvy.product.ref"        // 0
           )
           productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
           productsRequest.delegate = self
           productsRequest.start()
       }
       
       func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
           if (response.products.count > 0) {
               validProducts = response.products
               let prod100coins = response.products[0] as SKProduct
               print("1st rpoduct: " + prod100coins.localizedDescription)
               buyBtn.isHidden = false
           }
       }
       
   /*    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
           return true
       }*/
       
       func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
       
       func purchaseMyProduct(_ product: SKProduct) {
           if self.canMakePurchases() {
               let payment = SKPayment(product: product)
               SKPaymentQueue.default().add(self)
               SKPaymentQueue.default().add(payment)
           } else { print("Purchases are disabled in your device!") }
       }
       
       func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
           for transaction:AnyObject in transactions {
               if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                   switch trans.transactionState {
                       
                   case .purchased:
                       SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                       UserDefaults.standard.set(true, forKey: "premiumUser")
                       UserDefaults.standard.set(false, forKey: "limitedVersion")
                       break
                       
                   case .failed:
                       SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                       print("Payment has failed.")
                       break
                   case .restored:
                       SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                       print("Purchase has been successfully restored!")
                       UserDefaults.standard.set(true, forKey: "premiumUser")
                       UserDefaults.standard.set(false, forKey: "limitedVersion")
                       break
                       
                   default: break
                   }}}
       }
       
       func restorePurchase() {
           SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
           SKPaymentQueue.default().restoreCompletedTransactions()
       }
       
       func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
           print("The Payment was successfull!")
       }
       
       override func viewWillAppear(_ animated: Bool) {
           setGradientBackground()
           super.viewWillAppear(animated)
       }
       
       @IBAction func restoreCC(_ sender: Any) {
           restorePurchase()
       }
       
       @IBAction func buyCC(_ sender: Any) {
           productIndex = 0
           purchaseMyProduct(validProducts[productIndex])
       }
   
       @objc func tappedMe5()
       {
           /*
           if MFMailComposeViewController.canSendMail() {
               let mail = MFMailComposeViewController()
               mail.mailComposeDelegate = self
               mail.setToRecipients(["dfmv.enterprise@gmail.com"])
               mail.setSubject("")
               mail.setMessageBody("", isHTML: true)
               present(mail, animated: true)
           }else{
               let alert = UIAlertController(title: NSLocalizedString("info", comment: ""), message: NSLocalizedString("noClientMail", comment: ""), preferredStyle: UIAlertController.Style.alert)
               alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default, handler: nil))
               self.present(alert, animated: true, completion: nil)
           }
            */
       }
       
       func setGradientBackground() {
           let colorTop =  UIColor(red:1.00, green:0.30, blue:0.30, alpha:1.0).cgColor
           let colorBottom = UIColor(red:1.00, green:0.69, blue:0.25, alpha:1.0).cgColor
           
           let gradientLayer = CAGradientLayer()
           gradientLayer.colors = [colorTop, colorBottom]
           gradientLayer.locations = [0.0, 1.0]
           gradientLayer.frame = self.view.bounds
           
           self.view.layer.insertSublayer(gradientLayer, at:0)
       }
    

    func addBannerViewToView2(_ bannerView: GADBannerView)
    {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints([NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0), NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)])
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}




// UIViewRepresentable wrapper for AdMob banner view
@available(iOS 13.0, *)
struct AdBannerView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50))) // Set your desired banner ad size
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}




