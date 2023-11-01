//  SounioTechnologies LLC
//  StavvyBird

import UIKit
import SpriteKit

class ContinuousBackground: SKNode {
    
    var willRelive: Bool = true
    let key = "background"
    var tiles: [SKNode]
    var background: SKNode
    var backgroundSpeed: TimeInterval
    
    let maxNumOfTiles = 8 //hmm
    
    internal var delta = TimeInterval(0)
    internal var previousTime = TimeInterval(0)
        
    init(fileName: String, scaleFactor scale: CGPoint = CGPoint(x: 1.0, y: 1.0), speed: TimeInterval = 98) {
        self.backgroundSpeed = speed
        
        let yShift: CGFloat = 4.99
        
        tiles = [SKSpriteNode]()
        background = SKNode()
        let texture = SKTexture(imageNamed: fileName)
        let width = texture.size().width
        
        
        for x in 0...maxNumOfTiles {
            let myCurrTil = SKSpriteNode(texture: texture)
            myCurrTil.xScale = scale.x
            myCurrTil.yScale = scale.y
            myCurrTil.anchorPoint = .zero
            myCurrTil.position = CGPoint(x: CGFloat(x) * width * scale.x, y: yShift)
            myCurrTil.name = key
            myCurrTil.zPosition = 0
            background.addChild(myCurrTil)
        }
        
        super.init()
        
        background.enumerateChildNodes(withName: key) { [weak self] node, pointer in
            self?.tiles += [node]
        }
        
        self.addChild(background)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("The NSCoder didn't respond")
    }
        
    fileprivate func moveBackground() {
        let posX = -backgroundSpeed * delta
        background.position = CGPoint(x: background.position.x + CGFloat(posX), y: 0.0)
        
        let maxTiles = CGFloat(maxNumOfTiles)
        
        background.enumerateChildNodes(withName: key) { [weak self] node, stop in
            if let unwrappedSelf = self {
                let background_screen_position = unwrappedSelf.background.convert(node.position, to: unwrappedSelf)
                
                if background_screen_position.x <= -node.frame.size.width {
                    node.position = CGPoint(x: node.position.x + (node.frame.size.width * maxTiles), y: node.position.y)
                }
            } else {
                debugPrint(#function + "failed to wrap")
                
            }
        }
    }
    
    
}

extension ContinuousBackground: Updatable {
    func update(_ currentTime: TimeInterval) {
        let computedUpdatable = computeUpdatable(currentTime: currentTime)
        delta = computedUpdatable.delta
        previousTime = computedUpdatable.precedingMoment
        moveBackground()
    }
}
