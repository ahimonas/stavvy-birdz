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



class GameViewController: UIViewController, GADBannerViewDelegate {

    func authenticateLocalPlayer() {
        // Create a new Game Center localPlayer instance:
        let localPlayer = GKLocalPlayer.local
        // Create a function to check if they authenticated
        // or show them the log in screen:
        localPlayer.authenticateHandler =
            {(viewController, error) -> Void in
                if viewController != nil {
                    // They are not logged in, show the log in:
                    self.present(viewController!, animated: true,
                                 completion: nil)
                }
                else if localPlayer.isAuthenticated {
                    // They authenticated successfully!
                    // We will be back later to create a
                    // leaderboard button in the MenuScene
                }
                else {
                    // Not able to authenticate, skip Game Center
                }
        }
    }

    
    var bannerView: GADBannerView!
    var admobBanner = UIView()
    // MARK: - Overrides
    
    func removeAd(){
        print("removed ad")

        bannerView?.removeFromSuperview()
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        //authenticateLocalPlayer()
        for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        if(!UserDefaults.standard.bool(forKey: "removeRavensLock")){ //if raven is locked and not paid for
            
            bannerView = GADBannerView(adSize: GADAdSizeBanner)
            addBannerViewToView(bannerView)
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.delegate = self
            bannerView.load(GADRequest())
            bannerView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
            
            admobBanner = bannerView
        }
        
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




