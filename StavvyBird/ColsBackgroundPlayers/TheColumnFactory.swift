//  SounioTechnologies LLC
//  StavvyBird
// revisit


import SpriteKit

struct ColumnFactory {

 
    typealias singlePipeParts = ( midUp: BlockNode, myCurrThresh: SKSpriteNode)

    
    static let pipeWidth: CGFloat = 102
    private static var rangedHeight: CGFloat {
        return CGFloat.range(min: 71, max: 851)
    }
    private static var doubleRangeHeight: CGFloat {
        return CGFloat.range(min: 100, max: 350)
    }
    static let zPosition: CGFloat = 21
    
    

    static func launch(for scene: SKScene, targetNode: SKNode) -> SKAction {
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
            targetNode.childNode(withName: pipeName)?.removeFromParent()
        }
        
        let pipeMoveDuration2: TimeInterval = 6

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
            targetNode.childNode(withName: pipeName)?.removeFromParent()
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
        //myCurrPipNod.addChild(pipeParts.top)
        myCurrPipNod.addChild(pipeParts.myCurrThresh)
        //myCurrPipNod.addChild(pipeParts.bottom)
        myCurrPipNod.addChild(pipeParts.midUp)
        //myCurrPipNod.addChild(pipeParts.midDown)
        
        return myCurrPipNod
    }
    
    
    
    private static func generateSkyBlock(for sceneSize: CGSize) -> singlePipeParts? {
        let pipeX = sceneSize.width
        let pipeY = sceneSize.height
        //This one worked pretty well
        //let currWIDTH = CGFloat.range(min: 100, max: 250)
        let currWIDTH = CGFloat.range(min: 80, max: 380)
        
         let myCurrThreshWidth: CGFloat = 5

        //it makes sense the threshhold of the screen is the height of the entier screen
        let myCurrThresh = SKSpriteNode(color: .clear, size: CGSize(width: myCurrThreshWidth, height: pipeY))
        myCurrThresh.position = CGPoint(x: pipeX, y: pipeY)
        myCurrThresh.physicsBody = SKPhysicsBody(rectangleOf: myCurrThresh.size)
        myCurrThresh.physicsBody?.categoryBitMask = BondaryMapping.gap.rawValue
        myCurrThresh.physicsBody?.contactTestBitMask =  BondaryMapping.player.rawValue
        myCurrThresh.physicsBody?.collisionBitMask = 0
        myCurrThresh.physicsBody?.isDynamic = false
        myCurrThresh.zPosition = zPosition
        
        let randomBlockHeight = CGFloat.range(min: 180, max: 600) //height
        
        let midUpPipe = BlockNode(textures: (pipe: "column-parts", cap: "sparky22"), of: CGSize(width: currWIDTH, height: randomBlockHeight))
        
        
        //halfofblock needs to be over the bottom axis, we can place the blocks anywhere between heree
        let bottomBoundary = (randomBlockHeight/2)+1
        let topBoundary = pipeY-(randomBlockHeight/2)-1
        let myRandoHeightplacment = CGFloat.range(min: bottomBoundary, max: topBoundary)
        
        //we can put the poistion anywhere within that gap
        midUpPipe?.position = CGPoint(x: pipeX, y: myRandoHeightplacment)
        
        
        guard let unwrappedPipeMidUp = midUpPipe else {
            return nil
        }
        
        //midUp is just a random piece of the pipe
        return singlePipeParts(midUp: unwrappedPipeMidUp, myCurrThresh: myCurrThresh)
    }
    
    
    
}

/*RENDERING THE COLUMN*/

import SpriteKit

typealias typeIsTopColumn = Bool

class ColumnNode: SKSpriteNode {
    
    init?(textures: (pipe: String, cap: String), of size: CGSize, side: typeIsTopColumn) {

        guard let pipeTOPP = UIImage(named: textures.cap)?.cgImage else {
                 return nil
        }
        
        let textureRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
             
             // Render tiled pipe form the previously loaded cgImage
        if(size.height > 0){
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            // context?.draw(texture, in: textureRect, byTiling: true)
            context?.draw(pipeTOPP, in:textureRect)
        }
            let tiledBackground = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let unwrappedTiledBackground = tiledBackground, let tiledCGImage =  unwrappedTiledBackground.cgImage else {
                return nil
            }
            let backgroundTexture = SKTexture(cgImage: tiledCGImage)
            let pipe = SKSpriteNode(texture: backgroundTexture)
            pipe.zPosition = 1
            
            let cap = SKSpriteNode(imageNamed: textures.cap)
            //cap.position = CGPoint(x: 0.0, y: side ? -pipe.size.height / 2 + cap.size.height / 2 : pipe.size.height / 2 - cap.size.height / 2)
            
            // Changes width and height of cap
            //cap.size = CGSize(width: pipe.size.width + pipe.size.width/3, height: cap.size.height*2)
            //cap.zPosition = 5
            //pipe.addChild(cap)
            /*
            if side {
                let angle: CGFloat = 180.0
                cap.zRotation = angle.toRadians
            }
    */
        
        super.init(texture: backgroundTexture, color: .clear, size: backgroundTexture.size())
        
        // Add physics body
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = BondaryMapping.pipe.rawValue
        physicsBody?.contactTestBitMask =  BondaryMapping.player.rawValue
        physicsBody?.collisionBitMask = BondaryMapping.player.rawValue
        physicsBody?.isDynamic = false
        zPosition = 21
        /*
        if(size.height > 1){
            
                self.addChild(pipe)
            }
         */
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder has failed")
    }
    
}


class BlockNode: SKSpriteNode {
    
    init?(textures: (pipe: String, cap: String), of size: CGSize) {
        
        guard let pipeTOPP = UIImage(named: "sparky22" )?.cgImage else {
                 return nil
             }
        
             let textureRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
             
       // Render tiled pipe form the previously loaded cgImage
        if(size.height > 0){
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            context?.draw(pipeTOPP, in:textureRect)
        }
            let boundaryWithGraphic = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let unwrappedBoundaryWithGraphic = boundaryWithGraphic, let blockCgImage =  unwrappedBoundaryWithGraphic.cgImage else {
                return nil
            }
        
        let textureWrapperForGraphic = SKTexture(cgImage: blockCgImage)
        
        super.init(texture: textureWrapperForGraphic, color: .clear, size: textureWrapperForGraphic.size())
        
        // Add physics body
        
        //The phiscs Body is a map, when we change the order it does not colide with the bird and end the game
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = BondaryMapping.pipe.rawValue
        physicsBody?.contactTestBitMask =  BondaryMapping.player.rawValue
        physicsBody?.collisionBitMask = BondaryMapping.player.rawValue
        physicsBody?.isDynamic = false
        zPosition = 21
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder has failed")
    }
    
}








