//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit

func *(lhs: CGSize, value: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * value, height: lhs.height * value)
}

//Scene
class GameOverlay {
        
    let myCurrBackground: SKSpriteNode  //change these nodes
    let myCurrSpritNod: SKSpriteNode
    
    
    init(overlaySceneFileName currFileName: String, zPosition: CGFloat) {
        let overlayScene = SKScene(fileNamed: currFileName)!
        let outterTemplateNode = overlayScene.childNode(withName: "Overlay") as! SKSpriteNode
        
        myCurrBackground = SKSpriteNode(color: outterTemplateNode.color, size: outterTemplateNode.size * UIScreen.main.scale)
        myCurrBackground.zPosition = zPosition

        // Copy the template node into the background node.
        myCurrSpritNod = outterTemplateNode.copy() as! SKSpriteNode
        myCurrSpritNod.position = .zero
        myCurrBackground.addChild(myCurrSpritNod)
        
        // Set the content node to a clear color to allow the background node to be seen through it.
        myCurrSpritNod.color = .clear
    }

}
