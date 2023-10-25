//
//  PipeFactory.swift
//  StavvyBird
//

//

import SpriteKit

struct PipeFactory {

    // MARK: - Typealiases
    
    typealias PipeParts = (top: PipeNode, bottom: PipeNode, threshold: SKSpriteNode)
    typealias DoublePipeParts = (top: PipeNode, bottom: PipeNode, midUp: PipeNode, midDown: PipeNode, threshold: SKSpriteNode)
    typealias MidPipeParts = (midUp: PipeNode, midDown: PipeNode, threshold: SKSpriteNode)
    typealias MidUpPipeParts = (midUp: PipeNode, threshold: SKSpriteNode)
    typealias MidBotPipeParts = (midDown: PipeNode, threshold: SKSpriteNode)

    // MARK: - Constants
    
    static let pipeWidth: CGFloat = 600
    private static var rangedHeight: CGFloat {
        return CGFloat.range(min: 70, max: 850)
    }
    private static var doubleRangeHeight: CGFloat {
        return CGFloat.range(min: 40, max: 850)
    }
    static let thresholdWidth: CGFloat = 20
    static let zPosition: CGFloat = 20
    
    // MARK: - Factory Methods
    
    static func launch(for scene: SKScene, targetNode: SKNode) -> SKAction {
        let pipeName = "pipe"
        let pipeName2 = "pipe2"

        let cleanUpAction = SKAction.run {
            targetNode.childNode(withName: pipeName)?.removeFromParent()
        }
        
        let waitAction = SKAction.wait(forDuration: 3)
        let pipeMoveDuration: TimeInterval = 2.5

        let producePipeAction = SKAction.run {
            
            guard var pipe = PipeFactory.producseDoublePipe(sceneSize: scene.size) else {
                return
            }
            if Bool.pseudoRandomPipe {
                guard let standardPipe = PipeFactory.producseDoublePipe(sceneSize: scene.size) else {
                    return
                }
                pipe = standardPipe
            }
            
            pipe.name = pipeName

            targetNode.addChild(pipe)

            guard var pipe2 = PipeFactory.producseDoublePipe(sceneSize: scene.size) else {
                return
            }
            if Bool.pseudoRandomPipe {
                guard let standardPipe2 = PipeFactory.producseDoublePipe(sceneSize: scene.size) else {
                    return
                }
                pipe2 = standardPipe2
            }
            
            pipe2.name = pipeName2
            targetNode.addChild(pipe2)
            

            let moveAction = SKAction.move(to: CGPoint(x: -(pipe.size.width + scene.size.width), y: pipe.position.y), duration: pipeMoveDuration)
            let sequence = SKAction.sequence([moveAction, cleanUpAction])
            
            
            let moveAction2 = SKAction.move(to: CGPoint(x: -(pipe2.size.width + scene.size.width), y: pipe2.position.y), duration: pipeMoveDuration+4)
            let sequence2 = SKAction.sequence([moveAction2, cleanUpAction])
            
            pipe.run(sequence)
            pipe2.run(sequence2)

        }
        
        let producePipeAction2 = SKAction.run {
            
            guard var pipe2 = PipeFactory.producseDoublePipe(sceneSize: scene.size) else {
                return
            }
            if Bool.pseudoRandomPipe {
                guard let standardPipe2 = PipeFactory.producseDoublePipe(sceneSize: scene.size) else {
                    return
                }
                pipe2 = standardPipe2
            }
            
            pipe2.name = pipeName2
            targetNode.addChild(pipe2)
        
            
            
            
            let moveAction = SKAction.move(to: CGPoint(x: -(pipe2.size.width + scene.size.width), y: pipe2.position.y), duration: pipeMoveDuration)
            let sequence = SKAction.sequence([moveAction, cleanUpAction])
            pipe2.run(sequence)
            
        }
        /*
        let producePipeAction3 = SKAction.run {
            
            guard var pipe = PipeFactory.producseDoubleBotPipe(sceneSize: scene.size) else {
                return
            }
            if Bool.pseudoRandomPipe {
                guard let standardPipe = PipeFactory.producseDoubleBotPipe(sceneSize: scene.size) else {
                    return
                }
                pipe = standardPipe
            }
            
            pipe.name = pipeName

            targetNode.addChild(pipe)


            let moveAction = SKAction.move(to: CGPoint(x: -(pipe.size.width + scene.size.width), y: pipe.position.y), duration: pipeMoveDuration+4.5)
            let sequence = SKAction.sequence([moveAction, cleanUpAction])
            pipe.run(sequence)
        }
         */
        
        
        
      //  let sequce = SKAction.sequence([waitAction, producePipeAction, producePipeAction2])
      let sequce = SKAction.sequence([waitAction, producePipeAction])

        return SKAction.repeatForever(sequce)
    }
    
    
    private static func produceStandardPipe(sceneSize: CGSize) -> SKSpriteNode? {
        guard let pipeParts = PipeFactory.standardPipeParts(for: sceneSize) else {
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
        guard let pipeParts = PipeFactory.doublePipeParts(for: sceneSize) else {
            return nil
        }
        
        let pipeNode = SKSpriteNode(texture: nil, color: .clear, size: pipeParts.midUp.size)
        //pipeNode.addChild(pipeParts.top)
        pipeNode.addChild(pipeParts.threshold)
        //pipeNode.addChild(pipeParts.bottom)
        pipeNode.addChild(pipeParts.midUp)
        //pipeNode.addChild(pipeParts.midDown)
        
        return pipeNode
    }
    
    
    private static func producseDoubleBotPipe(sceneSize: CGSize) -> SKSpriteNode? {
        guard let pipeParts = PipeFactory.doublePipeBotmParts(for: sceneSize) else {
            return nil
        }
        
        let pipeNode = SKSpriteNode(texture: nil, color: .clear, size: pipeParts.midDown.size)
        //pipeNode.addChild(pipeParts.top)
        pipeNode.addChild(pipeParts.threshold)
        //pipeNode.addChild(pipeParts.bottom)
        //pipeNode.addChild(pipeParts.midUp)
        pipeNode.addChild(pipeParts.midDown)
        
        return pipeNode
    }
    
    // MARK: - Pipe parts production
    
    private static func standardPipeParts(for sceneSize: CGSize) -> PipeParts? {
        let pipeX: CGFloat = sceneSize.width
        
        let pipeBottomSize = CGSize(width: pipeWidth, height: rangedHeight) // rangeHeight
        let pipeBottom = PipeNode(textures: (pipe: "pipe-green", cap: "cap-green"), of: pipeBottomSize, side: false)
        pipeBottom?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! / 2)
        
        guard let unwrappedPipeBottom = pipeBottom else {
            debugPrint(#function + " could not construct PipeNode instnace")
            return nil
        }
        
        // Threshold node - basically gap for the player bird
        let threshold = SKSpriteNode(color: .clear, size: CGSize(width: thresholdWidth, height: CGFloat.range(min: 180, max: 350)))
        threshold.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + threshold.size.height / 2)
        
        threshold.physicsBody = SKPhysicsBody(rectangleOf: threshold.size)
        threshold.physicsBody?.categoryBitMask =  PhysicsCategories.gap.rawValue
        threshold.physicsBody?.contactTestBitMask =  PhysicsCategories.player.rawValue
        threshold.physicsBody?.collisionBitMask = 0
        threshold.physicsBody?.isDynamic = false
        threshold.zPosition = zPosition
        
        // Top pipe
        let topHeight = sceneSize.height - (pipeBottom?.size.height)! - threshold.size.height
        let pipeTopSize = CGSize(width: pipeWidth, height: topHeight)
        let pipeTop = PipeNode(textures: (pipe: "pipe-green", cap: "cap-green"), of: pipeTopSize, side: true)
        pipeTop?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + threshold.size.height + (pipeTop?.size.height)! / 2)
        
        guard let unwrappedPipeTop = pipeTop else {
            return nil
        }
        
        return PipeParts(top: unwrappedPipeTop, bottom: unwrappedPipeBottom, threshold: threshold)
    }

    private static func doublePipeParts33(for sceneSize: CGSize) -> MidPipeParts? {
        
        let randomDouble2 = Double.random(in: 200.71828...720.14159)

        
        let pipeX = sceneSize.width
        let pipeBottomSize = CGSize(width: pipeWidth + randomDouble2, height: doubleRangeHeight)
        
        // Pipe bottom part
        let pipeBottom = PipeNode(textures: (pipe: "pipe-green", cap: "cap-green"), of: pipeBottomSize, side: false)
        pipeBottom?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! / 2)
        
        guard let unwerappedPipeBottom = pipeBottom else {
            debugPrint(#function + " could not contruct PipeNode instnace")
            return nil
        }
        
        // Threshold node
        let threshold = SKSpriteNode(color: .clear, size: CGSize(width: thresholdWidth, height: CGFloat.range(min: 700, max: 1200)))
        threshold.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + threshold.size.height / 2)
        
        threshold.physicsBody = SKPhysicsBody(rectangleOf: threshold.size)
        threshold.physicsBody?.categoryBitMask = PhysicsCategories.gap.rawValue
        threshold.physicsBody?.contactTestBitMask =  PhysicsCategories.player.rawValue
        threshold.physicsBody?.collisionBitMask = 0
        threshold.physicsBody?.isDynamic = false
        threshold.zPosition = zPosition
        
        // Top pipe
        let topHeight = sceneSize.height - (pipeBottom?.size.height)! - threshold.size.height
        let pipeTopSize = CGSize(width: pipeWidth, height: topHeight)
        let pipeTop = PipeNode(textures: (pipe: "pipe-green", cap: "pipe-green3"), of: pipeTopSize, side: true)
        pipeTop?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + threshold.size.height + (pipeTop?.size.height)! / 2)
        
        guard let unwrappedPipeTop = pipeTop else {
            return nil
        }
        
        let midUpPipe = PipeNode(textures: (pipe: "pipe-green", cap: "pipe-green3"), of: CGSize(width:  CGFloat.range(min: 200, max: 350), height: CGFloat.range(min: 0, max: 550)), side: true)
        midUpPipe?.position = CGPoint(x: pipeX, y:  CGFloat.range(min: 0, max: 600))
        
        guard let unwrappedPipeMidUp = midUpPipe else {
            return nil
        }
        
        let topBottomPoint = (unwrappedPipeTop.position.y - unwrappedPipeTop.size.height / 2)
        let topMidUpDistance = topBottomPoint - (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y)
        
        let downMidSize = CGSize(width: CGFloat.range(min: 200, max: 450), height: topMidUpDistance - CGFloat.range(min: 200, max: 250))
        let downMidPosition = CGPoint(x: pipeX, y: (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y) + downMidSize.height / 2)
        
        let midDownPipe = PipeNode(textures: (pipe: "pipe-green", cap: "pipe-green3"), of: downMidSize, side: false)
        midDownPipe?.position = downMidPosition
        
        guard let unwrappedPipeMidDown = midDownPipe else {
            return nil
        }
        
        return MidPipeParts(midUp: unwrappedPipeMidUp, midDown: unwrappedPipeMidDown, threshold: threshold)
    }
    
    private static func doublePipeParts(for sceneSize: CGSize) -> MidUpPipeParts? {
        
        let randomDouble2 = Double.random(in: 2.71828...720.14159)

        
        let pipeX = sceneSize.width
        
        let pipeBottomSize = CGSize(width: pipeWidth + randomDouble2, height: doubleRangeHeight)
        
        // Pipe bottom part
        let pipeBottom = PipeNode(textures: (pipe: "pipe-green", cap: "cap-green"), of: pipeBottomSize, side: false)
        pipeBottom?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! / 2)
        
        guard let unwerappedPipeBottom = pipeBottom else {
            debugPrint(#function + " could not contruct PipeNode instnace")
            return nil
        }
        
        // Threshold node
        let threshold = SKSpriteNode(color: .clear, size: CGSize(width: thresholdWidth, height: CGFloat.range(min: 200, max: 350)))
        threshold.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + threshold.size.height / 2)
        
        threshold.physicsBody = SKPhysicsBody(rectangleOf: threshold.size)
        threshold.physicsBody?.categoryBitMask = PhysicsCategories.gap.rawValue
        threshold.physicsBody?.contactTestBitMask =  PhysicsCategories.player.rawValue
        threshold.physicsBody?.collisionBitMask = 0
        threshold.physicsBody?.isDynamic = false
        threshold.zPosition = zPosition
        
        // Top pipe
        let topHeight = sceneSize.height - (pipeBottom?.size.height)! - threshold.size.height
        let pipeTopSize = CGSize(width: pipeWidth, height: topHeight)
        let pipeTop = PipeNode(textures: (pipe: "pipe-green", cap: "pipe-green3"), of: pipeTopSize, side: true)
        pipeTop?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + threshold.size.height + (pipeTop?.size.height)! / 2)
        
        guard let unwrappedPipeTop = pipeTop else {
            return nil
        }
        
        let midUpPipe = PipeNode(textures: (pipe: "pipe-green", cap: "pipe-green3"), of: CGSize(width:  CGFloat.range(min: 20, max: 550), height: CGFloat.range(min: 20, max: 550)), side: true)
        midUpPipe?.position = CGPoint(x: pipeX, y:  CGFloat.range(min: 20, max: 550))
        
        guard let unwrappedPipeMidUp = midUpPipe else {
            return nil
        }
        
        let topBottomPoint = (unwrappedPipeTop.position.y - unwrappedPipeTop.size.height / 2)
        let topMidUpDistance =  CGFloat.range(min: 20, max: 650)
        /*
        let downMidSize = CGSize(width: CGFloat.range(min: 200, max: 450), height: topMidUpDistance - CGFloat.range(min: 200, max: 250))
        let downMidPosition = CGPoint(x: pipeX, y: (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y) + downMidSize.height / 2)
        
        let midDownPipe = PipeNode(textures: (pipe: "pipe-green", cap: "pipe-green3"), of: downMidSize, side: false)
        midDownPipe?.position = downMidPosition
        
        guard let unwrappedPipeMidDown = midDownPipe else {
            return nil
        }
         */
        
        return MidUpPipeParts(midUp: unwrappedPipeMidUp, threshold: threshold)
    }
    
    
    
    private static func doublePipeBotmParts(for sceneSize: CGSize) -> MidBotPipeParts? {
        
        let randomDouble2 = Double.random(in: 2.71828...720.14159)

        
        let pipeX = sceneSize.width
        
        let pipeBottomSize = CGSize(width: pipeWidth + randomDouble2, height: doubleRangeHeight)
        
        // Pipe bottom part
        let pipeBottom = PipeNode(textures: (pipe: "pipe-green", cap: "cap-green"), of: pipeBottomSize, side: false)
        pipeBottom?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! )
        
        guard let unwerappedPipeBottom = pipeBottom else {
            debugPrint(#function + " could not contruct PipeNode instnace")
            return nil
        }
        
        // Threshold node
        let threshold = SKSpriteNode(color: .clear, size: CGSize(width: thresholdWidth, height: CGFloat.range(min: 700, max: 1200)))
        threshold.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + threshold.size.height / 2)
        
        threshold.physicsBody = SKPhysicsBody(rectangleOf: threshold.size)
        threshold.physicsBody?.categoryBitMask = PhysicsCategories.gap.rawValue
        threshold.physicsBody?.contactTestBitMask =  PhysicsCategories.player.rawValue
        threshold.physicsBody?.collisionBitMask = 0
        threshold.physicsBody?.isDynamic = false
        threshold.zPosition = zPosition
        
        // Top pipe
        let topHeight = sceneSize.height - (pipeBottom?.size.height)! - threshold.size.height
        let pipeTopSize = CGSize(width: pipeWidth, height: topHeight)
        let pipeTop = PipeNode(textures: (pipe: "pipe-green", cap: "pipe-green3"), of: pipeTopSize, side: true)
        pipeTop?.position = CGPoint(x: pipeX, y: (pipeBottom?.size.height)! + threshold.size.height + (pipeTop?.size.height)! / 2)
        
        guard let unwrappedPipeTop = pipeTop else {
            return nil
        }
        
        let midUpPipe = PipeNode(textures: (pipe: "pipe-green", cap: "pipe-green3"), of: CGSize(width:  CGFloat.range(min: 20, max: 350), height: CGFloat.range(min: 20, max: 350)), side: true)
        midUpPipe?.position = CGPoint(x: pipeX, y:  CGFloat.range(min: 20, max: 350))
        
        guard let unwrappedPipeMidUp = midUpPipe else {
            return nil
        }
        
        let topBottomPoint = (unwrappedPipeTop.position.y - unwrappedPipeTop.size.height / 2)
        let topMidUpDistance = topBottomPoint - (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y)
        
        let downMidSize = CGSize(width: CGFloat.range(min: 200, max: 450), height:  CGFloat.range(min: 200, max: 250))
        let downMidPosition = CGPoint(x: pipeX, y: (unwrappedPipeMidUp.size.height / 2 + unwrappedPipeMidUp.position.y) + downMidSize.height / 2)
        
        let midDownPipe = PipeNode(textures: (pipe: "pipe-green", cap: "pipe-green3"), of: downMidSize, side: false)
        midDownPipe?.position = downMidPosition
        
        guard let unwrappedPipeMidDown = midDownPipe else {
            return nil
        }
         
        
        return MidBotPipeParts(midDown: unwrappedPipeMidUp, threshold: threshold)
    }
    
    
    
}
