//  SounioTechnologies LLC
//  StavvyBird

// Complete
import UIKit
import SpriteKit

class ContinuousBackground: SKNode {
    internal var delta = TimeInterval(0)
    var cyclicalGameView: SKNode
    var backgroundSpeed: TimeInterval
    internal var previousTime = TimeInterval(0)
    let limitOfBlocksOnScreen = 8
    var willRelive: Bool = true; let sceneNodeName = "background"; var arrayOfSkNode: [SKNode]
    init(fileName: String, scaleFactor scale: CGPoint = CGPoint(x: 1.0, y: 1.0),
         speed: TimeInterval = 98) {
        self.backgroundSpeed = speed
        arrayOfSkNode = [SKSpriteNode](); cyclicalGameView = SKNode()
        let fileSkText = SKTexture(imageNamed: fileName); let transferYPosition: CGFloat = 4.77
        let backgroundWidth = fileSkText.size().width
        for x in 0...limitOfBlocksOnScreen {
            let myCurrTil = SKSpriteNode(texture: fileSkText)
            myCurrTil.xScale = scale.x; myCurrTil.yScale = scale.y; myCurrTil.anchorPoint = .zero
            myCurrTil.position = 
                CGPoint(x: CGFloat(x) * backgroundWidth * scale.x, y: transferYPosition)
            myCurrTil.name = sceneNodeName; myCurrTil.zPosition = 0; cyclicalGameView.addChild(myCurrTil)
        }
        super.init()
        cyclicalGameView.enumerateChildNodes(withName: sceneNodeName) { [weak self] node, pointer in
            self?.arrayOfSkNode += [node]
        }
        self.addChild(cyclicalGameView)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("---NSCoder Error----") }
        
    fileprivate func shiftBackgroundImg() {
        let xCoordinateDelta = -backgroundSpeed * delta
        cyclicalGameView.position = CGPoint(x: cyclicalGameView.position.x + CGFloat(xCoordinateDelta), y: 0.0)
        let limitOfBlox = CGFloat(limitOfBlocksOnScreen)
        cyclicalGameView.enumerateChildNodes(withName: sceneNodeName) { [weak self] node, stop in
            if let backgroundInstance = self {
                let background_screen_position = backgroundInstance.cyclicalGameView.convert(node.position, to: backgroundInstance)
                if background_screen_position.x <= -node.frame.size.width {
                    node.position = CGPoint(x: node.position.x + (node.frame.size.width * limitOfBlox), y: node.position.y)
                }
            } else { debugPrint(#function + "----------failed to wrap-----------") }
        }
    }
}
extension ContinuousBackground: Updatable {
    func update(_ currentTime: TimeInterval) {
let computedUpdatable = computeUpdatable(currentTime: currentTime); delta = computedUpdatable.delta; previousTime = computedUpdatable.precedingMoment; shiftBackgroundImg()
    }
}
