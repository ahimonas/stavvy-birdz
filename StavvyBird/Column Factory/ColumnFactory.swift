//  SounioTechnologies LLC
//  StavvyBird
// revisit


import SpriteKit

struct ColumnFactory {

    typealias PipeParts = (top: ColumnNode, bottom: ColumnNode, myCurrThresh: SKSpriteNode)
    typealias RenderTwoPartPipe = 
    
    (top: ColumnNode, bottom: ColumnNode, midUp: ColumnNode, midDown: ColumnNode, myCurrThresh: SKSpriteNode)
    
    
    static let pipeWidth: CGFloat = 102
    private static var rangedHeight: CGFloat {
        return CGFloat.range(min: 71, max: 851)
    }
    private static var doubleRangeHeight: CGFloat {
        return CGFloat.range(min: 41, max: 201)
    }
    static let myCurrThreshWidth: CGFloat = 21
    static let zPosition: CGFloat = 21
    
    
    static func launch(for scene: SKScene, targetNode: SKNode) -> SKAction {
        let pipeName = "pipe"
        
        let cleanUpAction = SKAction.run {
            targetNode.childNode(withName: pipeName)?.removeFromParent()
        }
        
        let waitAction = SKAction.wait(forDuration: UserDefaults.standard.getDifficultyLevel().rawValue)
        let pipeMoveDuration: TimeInterval = 4.5

        let renderFactoryPipeAction = SKAction.run {
            
            guard var pipe = ColumnFactory.producseDoublePipe(sceneSize: scene.size) else {
                return
            }
            if Bool.pseudoRandomPipe {
                guard let standardPipe = ColumnFactory.produceStandardPipe(sceneSize: scene.size) else {
                    return
                }
                pipe = standardPipe
            }
            
            pipe.name = pipeName
            targetNode.addChild(pipe)
            
            let pipeRelocation = SKAction.move(to: CGPoint(x: -(pipe.size.width + scene.size.width), y: pipe.position.y), duration: pipeMoveDuration)
            let sequence = SKAction.sequence([pipeRelocation, cleanUpAction])
            pipe.run(sequence)
        }
        
        let actionsSequential = SKAction.sequence([waitAction, renderFactoryPipeAction])
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
        guard let pipeParts = ColumnFactory.renderTwoPartPipe(for: sceneSize) else {
            return nil
        }
        
        let myCurrPipNod = SKSpriteNode(texture: nil, color: .clear, size: pipeParts.top.size)
        myCurrPipNod.addChild(pipeParts.top)
        myCurrPipNod.addChild(pipeParts.myCurrThresh)
        myCurrPipNod.addChild(pipeParts.bottom)
        myCurrPipNod.addChild(pipeParts.midUp)
        myCurrPipNod.addChild(pipeParts.midDown)
        
        return myCurrPipNod
    }
    
        
    private static func standardPipeParts(for sceneSize: CGSize) -> PipeParts? {
        let pipeX: CGFloat = sceneSize.width
        
        let pipeBottomSize = CGSize(width: pipeWidth, height: rangedHeight) // rangeHeight
        let pipeBottom = ColumnNode(textures: (pipe: "col-parts", cap: "col-top"), of: pipeBottomSize, side: false)
        pipeBottom?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! / 2)
        
        guard let unwrappedPipeBottom = pipeBottom else {
            debugPrint(#function + " could not construct ColumnNode instnace")
            return nil
        }
        
        // Threshold node - basically gap for the player bird
        let myCurrThresh = SKSpriteNode(color: .clear, size: CGSize(width: myCurrThreshWidth, height: CGFloat.range(min: 180, max: 350)))
        myCurrThresh.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + myCurrThresh.size.height / 2)
        
        myCurrThresh.physicsBody = SKPhysicsBody(rectangleOf: myCurrThresh.size)
        myCurrThresh.physicsBody?.categoryBitMask =  GamePhysics.gap.rawValue
        myCurrThresh.physicsBody?.contactTestBitMask =  GamePhysics.player.rawValue
        myCurrThresh.physicsBody?.collisionBitMask = 0
        myCurrThresh.physicsBody?.isDynamic = false
        myCurrThresh.zPosition = zPosition
        
        let topHeight = sceneSize.height - (pipeBottom?.size.height)! - myCurrThresh.size.height
        let pipeTopSize = CGSize(width: pipeWidth, height: topHeight)
        let pipeTop = ColumnNode(textures: (pipe: "col-parts", cap: "col-top"), of: pipeTopSize, side: true)
        pipeTop?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + myCurrThresh.size.height + (pipeTop?.size.height)! / 2)
        
        guard let unwrappedPipeTop = pipeTop else {
            return nil
        }
        
        return PipeParts(top: unwrappedPipeTop, bottom: unwrappedPipeBottom, myCurrThresh: myCurrThresh)
    }

    private static func renderTwoPartPipe(for sceneSize: CGSize) -> RenderTwoPartPipe? {
        let pipeX = sceneSize.width
        let pipeBottomSize = CGSize(width: pipeWidth, height: doubleRangeHeight)
        
        // Pipe bottom part
        let pipeBottom = ColumnNode(textures: (pipe: "col-parts", cap: "col-top"), of: pipeBottomSize, side: false)
        pipeBottom?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! / 2)
        
        guard let unwerappedPipeBottom = pipeBottom else {
            debugPrint(#function + " could not contruct ColumnNode instnace")
            return nil
        }
        
        // Threshold node ? THRESH MEANING GAP ?
        let myCurrThresh = SKSpriteNode(color: .clear, size: CGSize(width: myCurrThreshWidth, height: CGFloat.range(min: 700, max: 1200)))
        myCurrThresh.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + myCurrThresh.size.height / 2)
        
        myCurrThresh.physicsBody = SKPhysicsBody(rectangleOf: myCurrThresh.size)
        myCurrThresh.physicsBody?.categoryBitMask = GamePhysics.gap.rawValue
        myCurrThresh.physicsBody?.contactTestBitMask =  GamePhysics.player.rawValue
        myCurrThresh.physicsBody?.collisionBitMask = 0
        myCurrThresh.physicsBody?.isDynamic = false
        myCurrThresh.zPosition = zPosition
        
        // Top pipe
        let topHeight = sceneSize.height - (pipeBottom?.size.height)! - myCurrThresh.size.height
        let pipeTopSize = CGSize(width: pipeWidth, height: topHeight)
        let pipeTop = ColumnNode(textures: (pipe: "col-parts", cap: "col-top"), of: pipeTopSize, side: true)
        pipeTop?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + myCurrThresh.size.height + (pipeTop?.size.height)! / 2)
        
        guard let unwrappedPipeTop = pipeTop else {
            return nil
        }
        
        let midUpPipe = ColumnNode(textures: (pipe: "col-parts", cap: "col-top"), of: CGSize(width: pipeWidth, height: CGFloat.range(min: 50, max: 150)), side: true)
        midUpPipe?.position = CGPoint(x: pipeX, y: unwerappedPipeBottom.size.height + CGFloat.range(min: 250, max: 300))
        
        guard let unwrappedPipeMidUp = midUpPipe else {
            return nil
        }
        
        let topBottomPoint = (unwrappedPipeTop.position.y - unwrappedPipeTop.size.height / 2)
        let topMidUpDistance = topBottomPoint - (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y)
        
        let downMidSize = CGSize(width: pipeWidth, height: topMidUpDistance - CGFloat.range(min: 200, max: 250))
        let downMidPosition = CGPoint(x: pipeX, y: (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y) + downMidSize.height / 2)
        
        let midDownPipe = ColumnNode(textures: (pipe: "col-parts", cap: "col-top"), of: downMidSize, side: false)
        midDownPipe?.position = downMidPosition
        
        guard let unwrappedPipeMidDown = midDownPipe else {
            return nil
        }
        
        return RenderTwoPartPipe(top: unwrappedPipeTop, bottom: unwerappedPipeBottom, midUp: unwrappedPipeMidUp, midDown: unwrappedPipeMidDown, myCurrThresh: myCurrThresh)
    }
    
    
}
