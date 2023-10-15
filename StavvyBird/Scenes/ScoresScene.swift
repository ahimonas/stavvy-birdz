//
//  ScoresScene.swift
//  StavvyBird
//

// THIS IS AUTH TO GAMECENTER 

import SpriteKit
import GameplayKit
import GameKit

class ScoresScene: RoutingUtilityScene {
    
    // MARK: - Overrides
    //var gcEnabled = Bool()
    /*
    var gcDefaultLeaderboard = String()
    var leaderboardID = "stavvyboard22"
    
    var scoreboard :SKSpriteNode!
     */
    var tryCountCurrent :Int = 0
    var tryCountBest :Int!
    var tryCountCurrentLabel :SKLabelNode!
    var tryCountBestLabel :SKLabelNode!
    var buttonReset : SKSpriteNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        authenticateLocalPlayer()
        fetchScores()
        //createScoreboard()
        //submitScore()
        //showScoreboard()
        saveHighScore33(number: 33)
        advanceRainParticleEmitter(for: 10)
    }
/*
    func createScoreboard() {
        scoreboard = SKSpriteNode(imageNamed: "dummy")
        scoreboard.position = CGPoint(x: size.width / 2, y: size.height - 50 - scoreboard.size.height / 2)
        scoreboard.zPosition = 1
        scoreboard.name = "scoreboard"
        addChild(scoreboard)
        
        tryCountCurrentLabel = SKLabelNode(fontNamed: "Arial")
        tryCountCurrentLabel?.text = "Attemp: \(tryCountCurrent)"
        tryCountCurrentLabel?.fontSize = 30
        tryCountCurrentLabel?.fontColor = SKColor.white
        tryCountCurrentLabel?.zPosition = 11
        tryCountCurrentLabel?.position = CGPoint(x: scoreboard.position.x, y: scoreboard.position.y + 10)
        addChild(tryCountCurrentLabel)
        
        // TODO: we need to get the best score from the storage (NSUserDefault)
        
        tryCountBest = UserDefaults.standard.integer(forKey: "besttrycount") as Int
        
        tryCountBestLabel = SKLabelNode(fontNamed: "Arial")
        tryCountBestLabel?.text = "Best: \(tryCountBest!)"
        tryCountBestLabel?.fontSize = 30
        tryCountBestLabel?.fontColor = SKColor.white
        tryCountBestLabel?.zPosition = 11
        tryCountBestLabel?.position = CGPoint(x: tryCountCurrentLabel.position.x, y: tryCountCurrentLabel.position.y - 10 - tryCountCurrentLabel.fontSize)
        addChild(tryCountBestLabel)
        
        buttonReset = SKSpriteNode(imageNamed: "dummy")
        buttonReset.position = CGPoint(x: scoreboard.position.x + scoreboard.size.width / 2 - buttonReset.size.width, y: scoreboard.position.y - buttonReset.size.height / 3)
        buttonReset.name = "reset"
        buttonReset.zPosition = 11
        buttonReset.setScale(0.5)
        addChild(buttonReset)
        buttonReset.isHidden = true
    }
    
    func showScoreboard() {
        
        scoreboard.isHidden = false
        tryCountBestLabel.isHidden = false
        tryCountCurrentLabel.isHidden = false
        buttonReset.isHidden = false
        
        if tryCountBest == nil || tryCountBest == 0 {
            tryCountBestLabel.isHidden = true
        }
    }
    */
    
    
    // MARK: - Helpers
    
    private func advanceRainParticleEmitter(for amount: TimeInterval) {
        let particleEmitter = childNode(withName: "Rain Particle Emitter") as? SKEmitterNode
        particleEmitter?.advanceSimulationTime(amount)
    }
    
    // MARK: leaderboard
    /*
    func authenticateLocalPlayer() {
        let localPlayer : GKLocalPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler = { (viewController, error) -> Void in
            if viewController != nil {
                let vc = self.view?.window?.rootViewController
                vc?.present(viewController!, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                print("player is already authenticated")
                self.gcEnabled = true
                
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

    */
    private func fetchScores() {
        // Read the scores from UserDefaults
        
        if let bestScoreLabel = self.scene?.childNode(withName: "Best Score Label") as? SKLabelNode {
            let bestScore = UserDefaults.standard.integer(for: .bestScore)
            bestScoreLabel.text = "Best: \(bestScore)"
        }
        
        if let lastScoreLabel = self.scene?.childNode(withName: "Last Score Label") as? SKLabelNode {
            let lastScore = UserDefaults.standard.integer(for: .lastScore)
            lastScoreLabel.text = "Last: \(lastScore)"
        }
    }
    
    func submitScore() {
        if self.scene?.childNode(withName: "Best Score Label") is SKLabelNode {
            let bestScore = UserDefaults.standard.integer(for: .bestScore)
            let sScore = GKScore(leaderboardIdentifier: leaderboardID)
            sScore.value = Int64(bestScore)
            
            let _ : GKLocalPlayer = GKLocalPlayer()
           // GKScore.report([sScore], withCompletionHandler: { (error) -> Void in
            GKScore.report([sScore], withCompletionHandler: { (error) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("score submiteed successful")
                }
            })
        }
        }
    
    //Call this when ur highscore should be saved
    func saveHighScore33(number:Int){

        if(GKLocalPlayer.local.isAuthenticated){

            let scoreReporter = GKScore(leaderboardIdentifier: "stavvyboard22")
            scoreReporter.value = Int64(number)

            let scoreArray: [GKScore] = [scoreReporter]

            GKScore.report(scoreArray, withCompletionHandler: nil)

        }

    }
        
        

    
}
