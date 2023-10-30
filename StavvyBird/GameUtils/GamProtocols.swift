//  SounioTechnologies LLC
//  StavvyBird
import SpriteKit
import UIKit
import Foundation
import SpriteKit
import CoreGraphics
import simd
import SpriteKit.SKScene
import SpriteKit.SKNode
import SpriteKit.SKTextureAtlas
import SpriteKit.SKTexture
import SpriteKit.SKEmitterNode
import ImageIO



protocol Updatable: AnyObject {
    
    var delta: TimeInterval { get }
    var precedingMoment: TimeInterval { get }
    var willRenew: Bool { get set }
    
    func update(_ currentTime: TimeInterval)
}


extension Updatable {
    func computeUpdatable(currentTime: TimeInterval) -> (delta: TimeInterval, precedingMoment: TimeInterval) {
        let currDelta = (self.precedingMoment == 0.0) ? 0.0 : currentTime - self.precedingMoment
        let previousMarkTime = currentTime
        return (delta: currDelta, precedingMoment: previousMarkTime)
    }
}


protocol Touchable: AnyObject {
        
    var shouldAcceptTouches: Bool { get set }
    
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    /*
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
     */
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    
    
}

extension Touchable {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    /*
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    */
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
}



protocol PlaySceneProtocol {
    var updatables: [Updatable] { get }
    var touchables: [Touchable] { get }
    
    var scene: SKScene? { get }
    init?(with scene: SKScene)
    
}



protocol Playable: AnyObject {
    var size: CGSize { get set }

    var weighedDownByForce: Bool { get set }
}


protocol PhysicsContactable {
    var collisionBitMask: UInt32 { get }
    var shouldEnablePhysics: Bool { get set }
}


//
//  ControlInput.swift
//  StavvyBird
//

//


enum ControlInputDirection: Int {
    case up = 0, down, left, right
    
    init?(vector: SIMD2<Float>) {
        guard length(vector) >= 0.5 else { return nil }
        
        if abs(vector.x) > abs(vector.y) {
            self = vector.x > 0 ? .right : .left
        } else {
            self = vector.y > 0 ? .up : .down
        }
    }
}



import Foundation

struct PhysicsCategories : OptionSet {
    let rawValue : UInt32
    static let boundary     = PhysicsCategories(rawValue: 1 << 0)
    static let player       = PhysicsCategories(rawValue: 1 << 1)
    static let pipe         = PhysicsCategories(rawValue: 1 << 2)
    static let gap          = PhysicsCategories(rawValue: 1 << 3)
}




//
//  Float+MathUtils.swift
//  StavvyBird
//




extension CGFloat {
    
    // MARK: - Properties
    
    var toRadians: CGFloat {
        return CGFloat.pi * self / 180
    }
    
    // MARK: - Methods
    
    func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        if (self > max) {
            return max
        } else if (self < min) {
            return min
        } else {
            return self
        }
    }
    
    static func range(min: CGFloat, max: CGFloat) -> CGFloat {
        CGFloat.random(in: min...max)
    }
}



extension SKScene {
    func upload<Node>(for key: String, with pattern: (_ key: String, _ index: Int)->String, inRange indices: ClosedRange<Int>) -> [Node] where Node: SKNode {
        
        var foundNodes = [Node]()
        
        for index in indices.lowerBound...indices.upperBound {
            let childName = pattern(key, index)
            guard let node = self.childNode(withName: childName) as? Node else {
                debugPrint(#function + " Unavailable:  child with the following name: ", childName)
                continue
            }
            foundNodes.append(node)
        }
        
        return foundNodes
    }
}




extension SKTextureAtlas {
    class func upload(named name: String, beginIndex: Int = 1, pattern: (_ name: String, _ index: Int) -> String) throws -> [SKTexture] {
        
        let atlas = SKTextureAtlas(named: name)
        var frames = [SKTexture]()
        let count = atlas.textureNames.count
        
        if beginIndex > count {
            throw NSError(domain: "Begin index is grather than the number of texture in a the texture atlas named: \(name)", code: 1, userInfo: nil)
        }
        
        for index in beginIndex...count {
            let namePattern = pattern(name, index)
            let texture = atlas.textureNamed(namePattern)
            frames.append(texture)
        }
        
        return frames
    }
}


import SpriteKit.SKTexture

extension SKTexture {
    
    enum GradientDirection {
        case up
        case left
        case upLeft
        case upRight
    }
    
    convenience init(size: CGSize, startColor: SKColor, endColor: SKColor, direction: GradientDirection = .up) {
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CILinearGradient")!
        let startVector: CIVector
        let endVector: CIVector
        
        filter.setDefaults()
        
        switch direction {
        case .up:
            startVector = CIVector(x: size.width/2, y: 0)
            endVector   = CIVector(x: size.width/2, y: size.height)
        case .left:
            startVector = CIVector(x: size.width, y: size.height/2)
            endVector   = CIVector(x: 0, y: size.height/2)
        case .upLeft:
            startVector = CIVector(x: size.width, y: 0)
            endVector   = CIVector(x: 0, y: size.height)
        case .upRight:
            startVector = CIVector(x: 0, y: 0)
            endVector   = CIVector(x: size.width, y: size.height)
        }
        
        filter.setValue(startVector, forKey: "inputPoint0")
        filter.setValue(endVector, forKey: "inputPoint1")
        filter.setValue(CIColor(color: startColor), forKey: "inputColor0")
        filter.setValue(CIColor(color: endColor), forKey: "inputColor1")
        
        let image = context.createCGImage(filter.outputImage!, from: CGRect(origin: .zero, size: size))
        
        self.init(cgImage: image!)
    }
}


extension SKEmitterNode {
    func safeAdvanceSimulationTime(_ sec: TimeInterval) {
        let emitterPaused = self.isPaused
        
        if emitterPaused {
            self.isPaused = false
        }
        advanceSimulationTime(sec)
        
        if emitterPaused {
            self.isPaused = true
        }
    }
}

extension SKSpriteNode {
    
    convenience init(withAnimatedGif name: String, correctAspectRatioFor width: CGFloat) {
        self.init(texture: nil, color: .clear, size: .zero)
        animateWithLocalAspectCorrectGIF(named: name, width: width)
    }
    
    func animateWithLocalAspectCorrectGIF(named name: String, width: CGFloat) {
        guard let size = animateWithLocalGIF(named: name) else {
            debugPrint(#function + " could not unwrap size of the GIF texture - the method will be aborted")
            return
        }
        
        let aspect = size.width / size.height
        let newHeight = size.width / aspect
        self.size.width = size.width
        self.size.height = newHeight
    }
    
    @discardableResult
    func animateWithLocalGIF(named name: String) -> CGSize? {
        
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            debugPrint(#function + " image with .gif extension does not exist")
                return nil
        }
        
        do {
            let imageData = try Data(contentsOf: bundleURL)
            let data =  SKSpriteNode.gif(with: imageData as NSData)
            
            guard let textures = data.0 else  {
                return nil
            }
            
            let action = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: data.1[0]))
            self.run(action)
            
            return textures.first?.size()
        } catch {
            debugPrint(#function + " could not create data source from bundle URL: ", error)
            return nil
        }
    }
    
    class func gif(with data: NSData) -> ([SKTexture]?, [Double]) {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return (nil, [])
        }
        
        return SKSpriteNode.animatedImage(with: source)
    }
    
    class func animatedImage(with source: CGImageSource) -> ([SKTexture]?, [Double]) {
        let count = CGImageSourceGetCount(source)
        var delays = [Double]()
        var textures = [SKTexture]()
        
        for i in 0..<count {

            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let texture = SKTexture(cgImage: image)
                textures.append(texture)
            }
        
            let delaySeconds = SKSpriteNode.delayForImageAtIndex(index: Int(i), source: source)
            delays.append(delaySeconds)
        }
        
        return (textures, delays)
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty { return 1 }
        var gcd = array[0]
        
        array.forEach { val in
            gcd = SKSpriteNode.gcdFor(pair: val, target: gcd)
        }
        
        return gcd
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.01 { delay = 0.01 }

        return delay
    }
    
    class func gcdFor(pair value: Int, target: Int) -> Int {
        var a = value
        var b = target

        // Swap for modulo
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        
        while true {
            rest = a % b
            
            if rest == 0 { return b }
            else {
                a = b
                b = rest
            }
        }
    }
    
}


import SpriteKit

private let kNodeNameTransitionShaderNode = "kNodeNameTransitionShaderNode"
private let kNodeNameFadeColourOverlay = "kNodeNameFadeColourOverlay"
private var presentationStartTime: CFTimeInterval = -1
private var shaderChoice = -1

extension SKScene {
    
    
    private var transitionShader: SKShader? {
        get {
            if let shaderContainerNode = self.childNode(withName: kNodeNameTransitionShaderNode) as? SKSpriteNode {
                return shaderContainerNode.shader
            }
            
            return nil
        }
    }
    

    //What in the worold?
    func present(scene: SKScene?, shaderName: String, transitionDuration: TimeInterval) {
        /*
        // Create shader and add it to the scene
        let shaderContainer = SKSpriteNode(imageNamed: "dummy")
        shaderContainer.name = kNodeNameTransitionShaderNode
        shaderContainer.zPosition = 9999 // something arbitrarily large to ensure it's in the foreground
        shaderContainer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        shaderContainer.size = CGSize(width: size.width, height: size.height)
        shaderContainer.shader = createShader(shaderName: shaderName, transitionDuration:transitionDuration)
        self.addChild(shaderContainer)
        
        // remove the shader from the scene after its animation has completed.
        let delayTime = DispatchTime.init(uptimeNanoseconds: UInt64(transitionDuration * Double(NSEC_PER_SEC)))
        
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            let fadeOverlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            fadeOverlay.name = kNodeNameFadeColourOverlay
            fadeOverlay.fillColor = SKColor(red: 131.0 / 255.0, green: 149.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            fadeOverlay.zPosition = shaderContainer.zPosition
            scene!.addChild(fadeOverlay)
            self.view!.presentScene(scene)
            
        }
        
        // Reset the time presentScene was called so that the elapsed time from now can
        // be calculated in updateShaderTransitions(currentTime:)
        presentationStartTime = -1
         */
    }
    
    func updateShaderTransition(currentTime: CFTimeInterval) {
        if let shader = self.transitionShader {
            let elapsedTime = shader.uniformNamed("u_elapsed_time")!
            if (presentationStartTime < 0) {
                presentationStartTime = currentTime
            }
            elapsedTime.floatValue = Float(currentTime - presentationStartTime)
        }
    }
    
    func completeShaderTransition() {
        if let fadeOverlay = self.childNode(withName: kNodeNameFadeColourOverlay) {
            fadeOverlay.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 0.3), SKAction.removeFromParent()]))
        }
    }
    
    
    private func createShader(shaderName: String, transitionDuration: TimeInterval) -> SKShader {
        let shader = SKShader(fileNamed:shaderName)
        
        let u_size = SKUniform(name: "u_size", vectorFloat3: vector3(Float(UIScreen.main.scale * size.width), Float(UIScreen.main.scale * size.height), 0.0))
        
        let u_fill_colour = SKUniform(name: "u_fill_colour", vectorFloat4: vector4(131.0 / 255.0, 149.0 / 255.0, 255.0 / 255.0, 1.0))
        let u_border_colour = SKUniform(name: "u_border_colour", vectorFloat4: vector4(104.0 / 255.0, 119.0 / 255.0, 204.0 / 255.0, 1.0))
        let u_total_animation_duration = SKUniform(name: "u_total_animation_duration", float: Float(transitionDuration))
        let u_elapsed_time = SKUniform(name: "u_elapsed_time", float: Float(0))
        shader.uniforms = [u_size, u_fill_colour, u_border_colour, u_total_animation_duration, u_elapsed_time]
        
        return shader
    }
    
}

extension Bool {
    
    static var pseudoRandomPipe: Bool {
        return CGFloat.range(min: 1.0, max: 2.0) <= 1.6
    }
}












