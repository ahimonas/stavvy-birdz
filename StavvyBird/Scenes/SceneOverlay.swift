//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit

func *(lhs: CGSize, value: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * value, height: lhs.height * value)
}

class SceneOverlay {
        
    let backgroundNode: SKSpriteNode  //change these nodes
    let contentNode: SKSpriteNode
    
    
    init(overlaySceneFileName currFileName: String, zPosition: CGFloat) {
        let overlayScene = SKScene(fileNamed: currFileName)!
        let outterTemplateNode = overlayScene.childNode(withName: "Overlay") as! SKSpriteNode
        
        backgroundNode = SKSpriteNode(color: outterTemplateNode.color, size: outterTemplateNode.size * UIScreen.main.scale)
        backgroundNode.zPosition = zPosition

        // Copy the template node into the background node.
        contentNode = outterTemplateNode.copy() as! SKSpriteNode
        contentNode.position = .zero
        backgroundNode.addChild(contentNode)
        
        // Set the content node to a clear color to allow the background node to be seen through it.
        contentNode.color = .clear
    }

}
