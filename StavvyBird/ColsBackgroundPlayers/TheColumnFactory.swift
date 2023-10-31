//  SounioTechnologies LLC
//  StavvyBird
// revisit


import SpriteKit

struct ColumnFactory {

    
    typealias PipeParts = (top: ColumnNode, bottom: ColumnNode, myCurrThresh: SKSpriteNode)
    typealias DoublePipeParts = (top: ColumnNode, bottom: ColumnNode, midUp: ColumnNode, midDown: ColumnNode, myCurrThresh: SKSpriteNode)
    
    
    static let pipeWidth: CGFloat = 102
    private static var rangedHeight: CGFloat {
        return CGFloat.range(min: 71, max: 851)
    }
    private static var doubleRangeHeight: CGFloat {
        return CGFloat.range(min: 100, max: 350)
    }
    static let myCurrThreshWidth: CGFloat = 1
    static let zPosition: CGFloat = 21
    
    

    static func launch(for scene: SKScene, targetNode: SKNode) -> SKAction {
        let pipeName = "column"
        let pipeName2 = "column"

        let cleanUpAction = SKAction.run {
            targetNode.childNode(withName: pipeName)?.removeFromParent()
        }
        
        let waitAction = SKAction.wait(forDuration: UserDefaults.standard.getDifficultyLevel().rawValue)
        let pipeMoveDuration: TimeInterval = 4.5

        let renderFactoryPipeAction = SKAction.run {
            
            guard var column = ColumnFactory.producseDoublePipe(sceneSize: scene.size) else {
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
        
        let pipeMoveDuration2: TimeInterval = 8

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
        
        
        let actionsSequential = SKAction.sequence([waitAction, renderFactoryPipeAction, renderFactoryPipeAction2])
        return SKAction.repeatForever(actionsSequential)
    }
    
    
    private static func produceStandardPipe(sceneSize: CGSize) -> SKSpriteNode? {
        guard let pipeParts = ColumnFactory.standardPipeParts(for: sceneSize) else {
            debugPrint(#function + "The standard pip failed")
            return nil
        }
        
        let myCurrPipNod = SKSpriteNode(texture: nil, color: .clear, size: pipeParts.top.size)
        myCurrPipNod.addChild(pipeParts.top)
        myCurrPipNod.addChild(pipeParts.myCurrThresh)
        myCurrPipNod.addChild(pipeParts.bottom)
        
        return myCurrPipNod
    }
    
    private static func producseDoublePipe(sceneSize: CGSize) -> SKSpriteNode? {
        guard let pipeParts = ColumnFactory.doublePipeParts(for: sceneSize) else {
            return nil
        }
        
        let myCurrPipNod = SKSpriteNode(texture: nil, color: .clear, size: pipeParts.top.size)
        //myCurrPipNod.addChild(pipeParts.top)
        myCurrPipNod.addChild(pipeParts.myCurrThresh)
        //myCurrPipNod.addChild(pipeParts.bottom)
        myCurrPipNod.addChild(pipeParts.midUp)
        //myCurrPipNod.addChild(pipeParts.midDown)
        
        return myCurrPipNod
    }
    
    
    // MARK: - Pipe parts production
    
    private static func standardPipeParts(for sceneSize: CGSize) -> PipeParts? {
        let pipeX: CGFloat = sceneSize.width
        
        let pipeBottomSize = CGSize(width: pipeWidth, height: rangedHeight) // rangeHeight
        let pipeBottom = ColumnNode(textures: (pipe: "column-parts", cap: "column-top"), of: pipeBottomSize, side: false)
        pipeBottom?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! / 2)
        
        guard let unwrappedPipeBottom = pipeBottom else {
            debugPrint(#function + " could not construct ColumnNode instnace")
            return nil
        }
        
        // Threshold node - basically gap for the player bird
        let myCurrThresh = SKSpriteNode(color: .clear, size: CGSize(width: myCurrThreshWidth, height: CGFloat.range(min: 180, max: 350)))
        myCurrThresh.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + myCurrThresh.size.height / 2)
        
        myCurrThresh.physicsBody = SKPhysicsBody(rectangleOf: myCurrThresh.size)
        myCurrThresh.physicsBody?.categoryBitMask =  BondaryMapping.gap.rawValue
        myCurrThresh.physicsBody?.contactTestBitMask =  BondaryMapping.player.rawValue
        myCurrThresh.physicsBody?.collisionBitMask = 0
        myCurrThresh.physicsBody?.isDynamic = false
        myCurrThresh.zPosition = zPosition
        
        let topHeight = sceneSize.height - (pipeBottom?.size.height)! - myCurrThresh.size.height
        let pipeTopSize = CGSize(width: pipeWidth, height: topHeight)
        let pipeTop = ColumnNode(textures: (pipe: "column-parts", cap: "column-top"), of: pipeTopSize, side: true)
        pipeTop?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + myCurrThresh.size.height + (pipeTop?.size.height)! / 2)
        
        guard let unwrappedPipeTop = pipeTop else {
            return nil
        }
        
        return PipeParts(top: unwrappedPipeTop, bottom: unwrappedPipeBottom, myCurrThresh: myCurrThresh)
    }

    private static func doublePipeParts(for sceneSize: CGSize) -> DoublePipeParts? {
        let pipeX = sceneSize.width
        let pipeY = sceneSize.height

        let currWIDTH = CGFloat.range(min: 100, max: 300)
        let pipeBottomSize = CGSize(width: currWIDTH, height: doubleRangeHeight)
        
        // Pipe bottom part
        let pipeBottom = ColumnNode(textures: (pipe: "column-parts", cap: "column-top"), of: pipeBottomSize, side: false)
        pipeBottom?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! / 2)
        
        guard let unwerappedPipeBottom = pipeBottom else {
            debugPrint(#function + " could not contruct ColumnNode instnace")
            return nil
        }
        
        // Threshold node ? THRESH MEANING GAP ?
        let myCurrThresh = SKSpriteNode(color: .clear, size: CGSize(width: myCurrThreshWidth, height: CGFloat.range(min: 500, max: 1200)))
        myCurrThresh.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + myCurrThresh.size.height / 2)
        
        myCurrThresh.physicsBody = SKPhysicsBody(rectangleOf: myCurrThresh.size)
        myCurrThresh.physicsBody?.categoryBitMask = BondaryMapping.gap.rawValue
        myCurrThresh.physicsBody?.contactTestBitMask =  BondaryMapping.player.rawValue
        myCurrThresh.physicsBody?.collisionBitMask = 0
        myCurrThresh.physicsBody?.isDynamic = false
        myCurrThresh.zPosition = zPosition
        
        // Top pipe
        let topHeight = sceneSize.height - (pipeBottom?.size.height)! - myCurrThresh.size.height
        let pipeTopSize = CGSize(width: currWIDTH, height: topHeight)
        let pipeTop = ColumnNode(textures: (pipe: "column-parts", cap: "column-top"), of: pipeTopSize, side: true)
        pipeTop?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + myCurrThresh.size.height + (pipeTop?.size.height)! / 2)
        
        guard let unwrappedPipeTop = pipeTop else {
            return nil
        }
        
        let myRando = CGFloat.range(min: 100, max: 400)
        
        let midUpPipe = ColumnNode(textures: (pipe: "column-parts", cap: "sparky33"), of: CGSize(width: currWIDTH, height: myRando), side: true)
        
        let myRandoHeightplacment = CGFloat.range(min: 5, max: pipeY-100)

        
        midUpPipe?.position = CGPoint(x: pipeX, y: myRandoHeightplacment)
        
        
        
        guard let unwrappedPipeMidUp = midUpPipe else {
            return nil
        }
        
        let topBottomPoint = (unwrappedPipeTop.position.y - unwrappedPipeTop.size.height / 2)
        let topMidUpDistance = topBottomPoint - (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y)
        
        let downMidSize = CGSize(width: currWIDTH, height: topMidUpDistance - CGFloat.range(min: 20, max: 100))
        //let downMidPosition = CGPoint(x: pipeX, y: (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y) + downMidSize.height / 2)
        
        let downMidPosition = CGPoint(x: 100, y: (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y) + downMidSize.height / 2)

        let midDownPipe = ColumnNode(textures: (pipe: "column-parts", cap: "sparky22"), of: downMidSize, side: false)
        midDownPipe?.position = downMidPosition
        
        guard let unwrappedPipeMidDown = midDownPipe else {
            return nil
        }
        
        return DoublePipeParts(top: unwrappedPipeTop, bottom: unwerappedPipeBottom, midUp: unwrappedPipeMidUp, midDown: unwrappedPipeMidDown, myCurrThresh: myCurrThresh)
    }
    
    
}

/*RENDERING THE COLUMN*/

import SpriteKit

typealias typeIsTopColumn = Bool

class ColumnNode: SKSpriteNode {
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    
    init?(textures: (pipe: String, cap: String), of size: CGSize, side: typeIsTopColumn) {
        
        guard let texture = UIImage(named: textures.pipe)?.cgImage else {
                 return nil
             }
        
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

