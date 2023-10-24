//
//  PipeFactory.swift
//  StavvyBird
//

//

import SpriteKit

struct PipeyFactory {

    // MARK: - Typealiases
    
    typealias PipeParts = (top: PipeNode, bottom: PipeNode, threshold: SKSpriteNode)
    typealias DoublePipeParts = (top: PipeNode, bottom: PipeNode, midUp: PipeNode, midDown: PipeNode, threshold: SKSpriteNode)
    
    // MARK: - Constants
    
    static let pipeWidth: CGFloat = 100
    private static var rangedHeight: CGFloat {
        return CGFloat.range(min: 70, max: 850)
    }
    private static var doubleRangeHeight: CGFloat {
        return CGFloat.range(min: 40, max: 200)
    }
    static let thresholdWidth: CGFloat = 20
    static let zPosition: CGFloat = 20
    
    // MARK: - Factory Methods
    
    static func launch(for scene: SKScene, targetNode: SKNode) -> SKAction {
        let pipeName = "pipey"
        
        let cleanUpAction = SKAction.run {
            targetNode.childNode(withName: pipeName)?.removeFromParent()
        }
        
        let waitAction = SKAction.wait(forDuration: UserDefaults.standard.getDifficultyLevel().rawValue)
        let pipeMoveDuration: TimeInterval = 4.5

        let producePipeAction = SKAction.run {
            guard var pipey = PipeyFactory.produceStandardPipe(sceneSize: scene.size) else {
                    return
                }
            
            pipey.name = pipeName
            targetNode.addChild(pipey)
            
            let moveAction = SKAction.move(to: CGPoint(x: -(pipey.size.width + 10  + scene.size.width), y: pipey.position.y), duration: pipeMoveDuration)
            let sequence = SKAction.sequence([moveAction, cleanUpAction])
            pipey.run(sequence)
        }
        
        let sequce = SKAction.sequence([waitAction, producePipeAction])
        return SKAction.repeatForever(sequce)
    }
    
    
    private static func produceStandardPipe(sceneSize: CGSize) -> SKSpriteNode? {
        guard let pipeParts = PipeyFactory.standardPipeParts(for: sceneSize) else {
            debugPrint(#function + " could not unwrap PipeParts type since it's nil")
            return nil
        }
        
        let pipeNode = SKSpriteNode(texture: nil, color: .clear, size: pipeParts.top.size)
        pipeNode.addChild(pipeParts.top)
        pipeNode.addChild(pipeParts.threshold)
        pipeNode.addChild(pipeParts.bottom)
        
        return pipeNode
    }
    
    private static func producseDoublePipe(sceneSize: CGSize) -> SKSpriteNode? {
        guard let pipeParts = PipeyFactory.standardPipeParts(for: sceneSize) else {
            debugPrint(#function + " could not unwrap PipeParts type since it's nil")
            return nil
        }
        
        let pipeNode = SKSpriteNode(texture: nil, color: .clear, size: pipeParts.top.size)
        pipeNode.addChild(pipeParts.top)
        pipeNode.addChild(pipeParts.threshold)
        pipeNode.addChild(pipeParts.bottom)
        
        return pipeNode
    }
    
    
    // MARK: - Pipe parts production
    
    private static func standardPipeParts(for sceneSize: CGSize) -> PipeParts? {
        
        let randomInt = Int.random(in: 0..<6)
        let randomDouble = Double.random(in: 2.71828...3.14159)
        let randomBool = Bool.random()
        
        
        let pipeX: CGFloat = sceneSize.width
        
        let pipeBottomSize = CGSize(width: pipeWidth, height: rangedHeight) // rangeHeight
        let pipeBottom = PipeNode(textures: (pipe: "pipe-greeny", cap: "cap-greeny"), of: pipeBottomSize, side: false)
        pipeBottom?.position = CGPoint(x: pipeX + 50, y: (pipeBottom?.size.height)! / 2)
        
        guard let unwrappedPipeBottom = pipeBottom else {
            debugPrint(#function + " could not construct PipeNode instnace")
            return nil
        }
        
        // Threshold node - basically gap for the player bird
        let threshold = SKSpriteNode(color: .clear, size: CGSize(width: thresholdWidth, height: CGFloat.range(min: 180, max: 350)))
        
        threshold.position = CGPoint(x: pipeX + 4, y: (pipeBottom?.size.height)! + threshold.size.height / 2)
        
        threshold.physicsBody = SKPhysicsBody(rectangleOf: threshold.size)
        threshold.physicsBody?.categoryBitMask =  PhysicsCategories.gap.rawValue
        threshold.physicsBody?.contactTestBitMask =  PhysicsCategories.player.rawValue
        threshold.physicsBody?.collisionBitMask = 1
        threshold.physicsBody?.isDynamic = false
        threshold.zPosition = zPosition
        
        // Top pipe
       // let topHeight = sceneSize.height - (pipeBottom?.size.height)! - threshold.size.height
    let pipeTopSize = CGSize(width: 40, height: 40)
        let pipeTop = PipeNode(textures: (pipe: "pipe-greeny", cap: "cap-greeny"), of: pipeTopSize, side: true)
        pipeTop?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + threshold.size.height + (pipeTop?.size.height)! / 2)
        
        guard let unwrappedPipeTop = pipeTop else {
            return nil
        }
        
        return PipeParts(top: unwrappedPipeTop, bottom: unwrappedPipeBottom, threshold: threshold)
    }

   
    
}
