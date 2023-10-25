//
//  PipeNode.swift
//  StavvyBird
//

import SpriteKit

typealias IsTopPipe = Bool

class PipeNode: SKSpriteNode {
    
    
    init?(textures: (pipe: String, cap: String), of size: CGSize, side: IsTopPipe) {
        
        guard let texture = UIImage(named: textures.pipe)?.cgImage else {
            return nil
        }
        let textureRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // Render tiled pipe form the previously loaded cgImage
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.draw(texture, in: textureRect, byTiling: true)
        let tiledBackground = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let unwrappedTiledBackground = tiledBackground, let tiledCGImage =  unwrappedTiledBackground.cgImage else {
            return nil
        }
        let backgroundTexture = SKTexture(cgImage: tiledCGImage)
        let pipe = SKSpriteNode(texture: backgroundTexture)
        pipe.zPosition = 1
        
        let cap = SKSpriteNode(imageNamed: textures.cap)
        cap.position = CGPoint(x: 0.0, y: side ? -pipe.size.height / 2 + cap.size.height / 2 : pipe.size.height / 2 - cap.size.height / 2)
        
        // Changes width and height of cap
        cap.size = CGSize(width: pipe.size.width + pipe.size.width/3, height: cap.size.height*2)
        cap.zPosition = 5
        pipe.addChild(cap)
        
        if side {
            let angle: CGFloat = 180.0
            cap.zRotation = angle.toRadians
        }
        
        super.init(texture: backgroundTexture, color: .clear, size: backgroundTexture.size())
        
        // Add physics body
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategories.pipe.rawValue
        physicsBody?.contactTestBitMask =  PhysicsCategories.player.rawValue
        physicsBody?.collisionBitMask = PhysicsCategories.player.rawValue
        physicsBody?.isDynamic = false
        zPosition = 21
        
        self.addChild(pipe)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder has failed")
    }
    
}
