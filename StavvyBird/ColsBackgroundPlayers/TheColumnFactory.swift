//  SounioTechnologies LLC
//  StavvyBird
// revisit


import SpriteKit

struct ColumnFactory {

 
    typealias singleBlockFragment = ( midUp: BlockNode, myCurrThresh: SKSpriteNode)

    static func launch(for scene: SKScene, targetNode: SKNode) -> SKAction {
        //all the blocks need same name based on collision map
        let blockName = "column"
        let blockName2 = "column"
        let blockName3 = "column"

        let cleanUpAction = SKAction.run {
            targetNode.childNode(withName: blockName)?.removeFromParent()
        }
        
        let waitAction = SKAction.wait(forDuration: UserDefaults.standard.rateOfBlocksInSky().rawValue)
        let blockMoveDuration: TimeInterval = 3

        let renderFactoryPipeAction = SKAction.run {
            
            guard let column = ColumnFactory.generateBlocks(sceneSize: scene.size) else {
                return
            }

            column.name = blockName
            targetNode.addChild(column)
            
            let blockRelocation = SKAction.move(to: CGPoint(x: -(column.size.width + scene.size.width), y: column.position.y), duration: blockMoveDuration)
            let sequence = SKAction.sequence([blockRelocation, cleanUpAction])
            column.run(sequence)
        }
        
        let cleanUpAction2 = SKAction.run {
            targetNode.childNode(withName: blockName2)?.removeFromParent()
        }
        
        let blockMoveDuration2: TimeInterval = 7

        let renderFactoryPipeAction2 = SKAction.run {
            guard let column2 = ColumnFactory.generateBlocks(sceneSize: scene.size) else {
                return
            }
            column2.name = blockName2
            targetNode.addChild(column2)
            
            let blockRelocation2 = SKAction.move(to: CGPoint(x: -(column2.size.width + scene.size.width), y: column2.position.y), duration: blockMoveDuration2)
            let sequence2 = SKAction.sequence([blockRelocation2, cleanUpAction2])
            column2.run(sequence2)
        }
        
        let cleanUpAction3 = SKAction.run {
            targetNode.childNode(withName: blockName3)?.removeFromParent()
        }
        
        let blockMoveDuration3: TimeInterval = 9

        let renderFactoryPipeAction3 = SKAction.run {
            guard let column3 = ColumnFactory.generateBlocks(sceneSize: scene.size) else {
                return
            }
            column3.name = blockName3
            targetNode.addChild(column3)
            
            let blockRelocation3 = SKAction.move(to: CGPoint(x: -(column3.size.width + scene.size.width), y: column3.position.y), duration: blockMoveDuration3)
            let sequence3 = SKAction.sequence([blockRelocation3, cleanUpAction3])
            column3.run(sequence3)
        }
        
        
        
        let actionsSequential = SKAction.sequence([waitAction, renderFactoryPipeAction, renderFactoryPipeAction2, renderFactoryPipeAction3])//
        return SKAction.repeatForever(actionsSequential)
    }
    
    private static func generateBlocks(sceneSize: CGSize) -> SKSpriteNode? {
        guard let blockParts = ColumnFactory.generateSkyBlock(for: sceneSize) else {
            return nil
        }
        
        let myCurrPipNod = SKSpriteNode(texture: nil, color: .clear, size: blockParts.midUp.size)
        myCurrPipNod.addChild(blockParts.myCurrThresh)
        myCurrPipNod.addChild(blockParts.midUp)
        return myCurrPipNod
    }
    
    
    
    private static func generateSkyBlock(for sceneSize: CGSize) -> singleBlockFragment? {
        let blockX = sceneSize.width
        let blockY = sceneSize.height
        //This one worked pretty well
        //let randomBlockWidth = CGFloat.range(min: 100, max: 250)
        
        let myCurrThreshWidth: CGFloat = 3

        //it makes sense the threshhold of the screen is the height of the entier screen
        let myCurrThresh = SKSpriteNode(color: .green, size: CGSize(width: myCurrThreshWidth, height: blockY*2))
        myCurrThresh.position = CGPoint(x: blockX, y: 0)
        myCurrThresh.physicsBody = SKPhysicsBody(rectangleOf: myCurrThresh.size)
        myCurrThresh.physicsBody?.categoryBitMask = EdgeMapping.breaker.rawValue
        myCurrThresh.physicsBody?.contactTestBitMask =  EdgeMapping.characterX.rawValue
        myCurrThresh.physicsBody?.collisionBitMask = 0
        myCurrThresh.physicsBody?.isDynamic = false
        myCurrThresh.zPosition = 21
        
        let randomBlockWidth = CGFloat.range(min: 105, max: 350)

        let randomBlockHeight = CGFloat.range(min: 120, max: 470) //height
        let midUpPipe = BlockNode(textures: (block: "column-parts", cap: "sparky22"), of: CGSize(width: randomBlockWidth, height: randomBlockHeight))
        
        //halfofblock needs to be over the bottom axis, we can place the blocks anywhere between heree
        let bottomBoundary = (randomBlockHeight/2)+2
        let topBoundary = blockY-(randomBlockHeight/2)-20
        
        
        let myRandoHeightplacment = CGFloat.range(min: bottomBoundary+10, max: topBoundary-100)
        //we can put the poistion anywhere within that breaker
        midUpPipe?.position = CGPoint(x: blockX, y: myRandoHeightplacment)
        
        //wrap the block to make sure its not null
        guard let blockInstanceEncapsulator = midUpPipe else {
            return nil
        }
        //midUp is just a random piece of the block
        return singleBlockFragment(midUp: blockInstanceEncapsulator, myCurrThresh: myCurrThresh)
    }
    
    
    
}

class BlockNode: SKSpriteNode {
    
    init?(textures: (block: String, cap: String), of size: CGSize) {
        
        guard let skyBlockIMGGG = UIImage(named: "sparky22" )?.cgImage else {
                 return nil
             }
        
        //The rectangle we draw the block in, think outer container, if we touch this we die and we draw the image inside
        let textureRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
             
        //MAKKE SURE THE BLOCK IS NOT OF THE SCREEN, app crashes if not
        if(size.height > 0){
            //Begin Graphics with size of block passed in
            UIGraphicsBeginImageContext(size)
            //get the context of that Graphic
            let context = UIGraphicsGetCurrentContext()
            
            //Draw the image as CImage within the block
            context?.draw(skyBlockIMGGG, in:textureRect)
        }
        
        //edges based on graphic
        let edgesWithGraphic = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //null check
            guard let unwrappedBoundaryWithGraphic = edgesWithGraphic, let blockCgImage =  unwrappedBoundaryWithGraphic.cgImage else {
                return nil
            }
        
        let textureWrapperForGraphic = SKTexture(cgImage: blockCgImage)
        
        //create an instance of itself with the above rectangle and image inside
        super.init(texture: textureWrapperForGraphic, color: .clear, size: textureWrapperForGraphic.size())
                
        //The phiscs Body is a map, when we change the order it does not colide with the bird and end the game
        physicsBody = SKPhysicsBody(rectangleOf: size)
        
        physicsBody?.categoryBitMask = EdgeMapping.block.rawValue
        physicsBody?.contactTestBitMask =  EdgeMapping.characterX.rawValue
        physicsBody?.collisionBitMask = EdgeMapping.characterX.rawValue
        physicsBody?.isDynamic = false
        zPosition = 21
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder has failed")
    }
    
}








