//
//  SettingsScene.swift
//  StavvyBird
//

//

import SpriteKit
import SwiftUI

class SettingsScene: RoutingUtilityScene, ToggleButtonNodeResponderType, TriggleButtonNodeResponderType {
    func toggleButtonTriggered(toggle: ToggleButtonNode) {
        debugPrint("remove old overlay")

    }
    
    func triggleButtonTriggered(triggle: TriggleButtonNode) {
        debugPrint("remove old overlay")
    }
    

    // MARK: - Overrides
    
    
        override func didMove(to view: SKView) {
            physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let box = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
            box.position = location
            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
            addChild(box)
        }
    }
/*
struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 300, height: 400)
        scene.scaleMode = .fill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 300, height: 400)
            .ignoresSafeArea()
    }
}*/

struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 300, height: 400)
        scene.scaleMode = .fill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 300, height: 400)
            .ignoresSafeArea()
    }
}
