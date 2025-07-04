//  SounioTechnologies LLC
//  StavvyBird
// revisit


//extansions, swap buttons, rename playables, transitions, remoove digi, rename the r1_ sheet, check the audios, check the particles, UI components
import UIKit
import SpriteKit
import GameplayKit
import SwiftUI
import GoogleMobileAds
import GameKit

enum Scenes: String {
    case title = "HomeScene"
    case game = "PlayScene"
    case ItemShopCharacters = "ItemShopScene"
    case setting = "AtmosphereScene"
    case pause = "ResumeScene"
    case failed = "GameOverScene"
}

//standard
extension Scenes {
    func getName() -> String {
        let padId = " iPad"; let isPad = UIDevice.current.userInterfaceIdiom == .pad
        return isPad ? self.rawValue + padId : self.rawValue
    }
}

enum NodeScale: Float {
    case nodeScaleOfContinuousBackground
}

extension NodeScale {
    func getValue() -> Float {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        switch self {
        case .nodeScaleOfContinuousBackground:
            return isPad ? 1.5 : 1.35
        }
    }
}

extension CGPoint {
    init(x: Float, y: Float) {
        self.init(); self.x = CGFloat(x); self.y = CGFloat(y)
    }
}


class MainUiGameView: UIViewController, GADBannerViewDelegate {

    var bannerView: GADBannerView!
    var admobBanner = UIView()
    
    func removeAd(){
        print("removed ads")
        bannerView?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateLocalPlayer()
        
        let sceneName = Scenes.title.getName()
        
        if let scene = SKScene(fileNamed: sceneName) as? HomeScene {

            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            if let view = self.view as! SKView? {
                view.presentScene(scene)
                view.ignoresSiblingOrder = true
                
                
                
                //REMOVE FOR APP CONNECT
                /*
                if(!UserDefaults.standard.bool(forKey: "removeRavensLock")){
                    bannerView = GADBannerView(adSize: GADAdSizeBanner)
                    addBannerViewToView(bannerView)
                    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
                    bannerView.rootViewController = self
                    bannerView.delegate = self
                    bannerView.load(GADRequest())
                    bannerView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
                    admobBanner = bannerView
                }
                */
                
                
                
                
                
//              view.showsFPS = true
//              view.showsNodeCount = true
//              view.showsPhysics = true
                
            }
        }
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
    
    func printFonts(){
        for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler =
            {(viewController, error) -> Void in
                if viewController != nil {
                    self.present(viewController!, animated: true,
                                 completion: nil)
                }
                else if localPlayer.isAuthenticated {
                    //Auth seccuess
                }
                else {
                    // Auth fail
                }
        }
    }
    
}




// UIViewRepresentable wrapper for AdMob banner view
//we shouldn't need this bc we bumped to v15
/*
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
*/
