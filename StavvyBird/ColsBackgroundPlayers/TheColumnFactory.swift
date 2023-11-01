//  SounioTechnologies LLC
//  StavvyBird
// revisit


import SpriteKit

struct ColumnFactory {

 
    typealias singleBlockFragment = ( midUp: BlockNode, myCurrThresh: SKSpriteNode)

    static func launch(for scene: SKScene, targetNode: SKNode) -> SKAction {
        //all the pipes need same name based on collision map
        let pipeName = "column"
        let pipeName2 = "column"
        let pipeName3 = "column"

        let cleanUpAction = SKAction.run {
            targetNode.childNode(withName: pipeName)?.removeFromParent()
        }
        
        let waitAction = SKAction.wait(forDuration: UserDefaults.standard.getDifficultyLevel().rawValue)
        let pipeMoveDuration: TimeInterval = 3

        let renderFactoryPipeAction = SKAction.run {
            
            guard let column = ColumnFactory.producseDoublePipe(sceneSize: scene.size) else {
                return
            }

            column.name = pipeName
            targetNode.addChild(column)
            
            let pipeRelocation = SKAction.move(to: CGPoint(x: -(column.size.width + scene.size.width), y: column.position.y), duration: pipeMoveDuration)
            let sequence = SKAction.sequence([pipeRelocation, cleanUpAction])
            column.run(sequence)
        }
        
        let cleanUpAction2 = SKAction.run {
            targetNode.childNode(withName: pipeName2)?.removeFromParent()
        }
        
        let pipeMoveDuration2: TimeInterval = 7

        let renderFactoryPipeAction2 = SKAction.run {
            guard let column2 = ColumnFactory.producseDoublePipe(sceneSize: scene.size) else {
                return
            }
            column2.name = pipeName2
            targetNode.addChild(column2)
            
            let pipeRelocation2 = SKAction.move(to: CGPoint(x: -(column2.size.width + scene.size.width), y: column2.position.y), duration: pipeMoveDuration2)
            let sequence2 = SKAction.sequence([pipeRelocation2, cleanUpAction2])
            column2.run(sequence2)
        }
        
        let cleanUpAction3 = SKAction.run {
            targetNode.childNode(withName: pipeName3)?.removeFromParent()
        }
        
        let pipeMoveDuration3: TimeInterval = 9

        let renderFactoryPipeAction3 = SKAction.run {
            guard let column3 = ColumnFactory.producseDoublePipe(sceneSize: scene.size) else {
                return
            }
            column3.name = pipeName3
            targetNode.addChild(column3)
            
            let pipeRelocation3 = SKAction.move(to: CGPoint(x: -(column3.size.width + scene.size.width), y: column3.position.y), duration: pipeMoveDuration3)
            let sequence3 = SKAction.sequence([pipeRelocation3, cleanUpAction3])
            column3.run(sequence3)
        }
        
        
        
        let actionsSequential = SKAction.sequence([waitAction, renderFactoryPipeAction, renderFactoryPipeAction2, renderFactoryPipeAction3])//
        return SKAction.repeatForever(actionsSequential)
    }
    
    
    private static func producseDoublePipe(sceneSize: CGSize) -> SKSpriteNode? {
        guard let pipeParts = ColumnFactory.generateSkyBlock(for: sceneSize) else {
            return nil
        }
        
        let myCurrPipNod = SKSpriteNode(texture: nil, color: .clear, size: pipeParts.midUp.size)
        myCurrPipNod.addChild(pipeParts.myCurrThresh)
        myCurrPipNod.addChild(pipeParts.midUp)
        return myCurrPipNod
    }
    
    
    
    private static func generateSkyBlock(for sceneSize: CGSize) -> singleBlockFragment? {
        let pipeX = sceneSize.width
        let pipeY = sceneSize.height
        //This one worked pretty well
        //let randomBlockWidth = CGFloat.range(min: 100, max: 250)
        
        let myCurrThreshWidth: CGFloat = 3

        //it makes sense the threshhold of the screen is the height of the entier screen
        let myCurrThresh = SKSpriteNode(color: .green, size: CGSize(width: myCurrThreshWidth, height: pipeY*2))
        myCurrThresh.position = CGPoint(x: pipeX, y: 0)
        myCurrThresh.physicsBody = SKPhysicsBody(rectangleOf: myCurrThresh.size)
        myCurrThresh.physicsBody?.categoryBitMask = BondaryMapping.gap.rawValue
        myCurrThresh.physicsBody?.contactTestBitMask =  BondaryMapping.characterX.rawValue
        myCurrThresh.physicsBody?.collisionBitMask = 0
        myCurrThresh.physicsBody?.isDynamic = false
        myCurrThresh.zPosition = 21
        
        let randomBlockWidth = CGFloat.range(min: 105, max: 350)

        let randomBlockHeight = CGFloat.range(min: 120, max: 470) //height
        let midUpPipe = BlockNode(textures: (pipe: "column-parts", cap: "sparky22"), of: CGSize(width: randomBlockWidth, height: randomBlockHeight))
        
        
        //halfofblock needs to be over the bottom axis, we can place the blocks anywhere between heree
        let bottomBoundary = (randomBlockHeight/2)+2
        let topBoundary = pipeY-(randomBlockHeight/2)-20
        
        
        let myRandoHeightplacment = CGFloat.range(min: bottomBoundary+10, max: topBoundary-100)
        //we can put the poistion anywhere within that gap
        midUpPipe?.position = CGPoint(x: pipeX, y: myRandoHeightplacment)
        
        //wrap the pipe to make sure its not null
        guard let unwrappedPipeMidUp = midUpPipe else {
            return nil
        }
        //midUp is just a random piece of the pipe
        return singleBlockFragment(midUp: unwrappedPipeMidUp, myCurrThresh: myCurrThresh)
    }
    
    
    
}

class BlockNode: SKSpriteNode {
    
    init?(textures: (pipe: String, cap: String), of size: CGSize) {
        
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
        
        //boundary based on graphic
        let boundaryWithGraphic = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //null check
            guard let unwrappedBoundaryWithGraphic = boundaryWithGraphic, let blockCgImage =  unwrappedBoundaryWithGraphic.cgImage else {
                return nil
            }
        
        let textureWrapperForGraphic = SKTexture(cgImage: blockCgImage)
        
        //create an instance of itself with the above rectangle and image inside
        super.init(texture: textureWrapperForGraphic, color: .clear, size: textureWrapperForGraphic.size())
                
        //The phiscs Body is a map, when we change the order it does not colide with the bird and end the game
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = BondaryMapping.pipe.rawValue
        physicsBody?.contactTestBitMask =  BondaryMapping.characterX.rawValue
        physicsBody?.collisionBitMask = BondaryMapping.characterX.rawValue
        physicsBody?.isDynamic = false
        zPosition = 21
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder has failed")
    }
    
}








