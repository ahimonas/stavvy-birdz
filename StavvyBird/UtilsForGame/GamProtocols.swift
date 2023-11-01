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
    var previousTime: TimeInterval { get }
    var willRelive: Bool { get set }
    func update(_ currentTime: TimeInterval)
}


protocol PhysicsContactable {
    var collisionBitMask: UInt32 { get }
    var shouldEnablePhysics: Bool { get set }
}



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

protocol Touchable: AnyObject {
    var isInteractable: Bool { get set }
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
    //in order to touch the nodes
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
}



protocol PlaySceneProtocol {
    var modernizers: [Updatable] { get }; var tangibles: [Touchable] { get }; var scene: SKScene? { get }
    init?(with scene: SKScene)
}

protocol Playable: AnyObject {
    var size: CGSize { get set }; var isHeavy: Bool { get set }
}

extension Updatable {
    func computeUpdatable(currentTime: TimeInterval) -> (delta: TimeInterval, precedingMoment: TimeInterval) {
        let currDelta = (self.previousTime == 0.0) ? 0.0 : currentTime - self.previousTime
        let previousMarkTime = currentTime
        return (delta: currDelta, precedingMoment: previousMarkTime)
    }
}

struct BondaryMapping : OptionSet {
    let zeroLayer = 0
    let firsLayer = 1
    let rawValue : UInt32
    let secondLayer = 2
    let thirdLayer = 3
    
    static let boundary = BondaryMapping(rawValue: 1 << 0); static let characterX = BondaryMapping(rawValue: 1 << 1)
    static let block = BondaryMapping(rawValue: 1 << 2); static let column = BondaryMapping(rawValue: 1 << 2)
    static let breaker = BondaryMapping(rawValue: 1 << 3)
}

extension CGFloat {
    var toRadians: CGFloat {return CGFloat.pi * self / 180}
    func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        if(self > max){return max} else if ( self < min  ) { return min }else{return self }
    }
static func range(min: CGFloat, max: CGFloat) -> CGFloat { CGFloat.random(in: min...max) }
}



extension SKScene {
    func upload<Node>(for key: String, with pattern: (_ key: String, _ index: Int)->String, inRange indices: ClosedRange<Int>) -> [Node] where Node: SKNode { var foundNodes = [Node]()
        for index in indices.lowerBound...indices.upperBound {
            let lowerLevelNode = pattern(key, index)
            guard let node = self.childNode(withName: lowerLevelNode) as? Node else {
                debugPrint(#function + " ----Unavailable:xchilde node ----", lowerLevelNode)
                continue
            }
            foundNodes.append(node)
        }
        
        return foundNodes
    }
}



//complete
extension SKTextureAtlas {
    class func upload
    (named name: String, beginIndex: Int = 1, pattern: (_ name: String, _ index: Int) -> String)
    throws -> [SKTexture] {
        let currSkAtl = SKTextureAtlas(named: name)
        var skTextArray = [SKTexture]()
        let textureIndex = currSkAtl.textureNames.count
        if beginIndex > textureIndex {
            throw NSError(domain: "-- Atlas is messed up currSkAtl named: \(name)----------", code: 1, userInfo: nil)
        }
        for index in beginIndex...textureIndex {
            let namePattern = pattern(name, index)
            let mySkTx = currSkAtl.textureNamed(namePattern)
            skTextArray.append(mySkTx)
        }
        return skTextArray
    }
}

//done
extension SKEmitterNode {
    func safeAdvanceSimulationTime(_ sec: TimeInterval) {
        let emitterPaused = self.isPaused
        if emitterPaused { self.isPaused = false }
        advanceSimulationTime(sec)
        if emitterPaused { self.isPaused = true }
    }
}

//done
extension SKSpriteNode {
    convenience init
    (withAnimatedGif name: String, correctAspectRatioFor width: CGFloat) {
        self.init(texture: nil, color: .clear, size: .zero)
        resizerWithTheAsset(named: name, width: width)
    }
    
    func resizerWithTheAsset(named name: String, width: CGFloat) {
        guard let myCurrRation = animateWithLocalGIF(named: name) else {
            debugPrint(#function + "----UNABEL TO ANIMATE GIF--------------")
            return
        }
        
        let aspect = myCurrRation.width / myCurrRation.height
        let newHeight = myCurrRation.width / aspect
        self.size.width = myCurrRation.width
        self.size.height = newHeight
    }
    
    @discardableResult
    func animateWithLocalGIF(named name: String) -> CGSize? {
        debugPrint(#function + " -------Animstion----------")

        guard let imageDataGifContent = Bundle.main.url(
            forResource: name, withExtension: "gif") else {
            debugPrint(#function + " -------GIF not found-----------")
                return nil
        }
        
        do {
            let myNsData = try Data(contentsOf: imageDataGifContent); let myCurrNs =  SKSpriteNode.gif(with: myNsData as NSData)
            guard let currGameAnimationFrames = myCurrNs.0 else  { return nil }
            let skRunner = SKAction.repeatForever(SKAction.animate(with: currGameAnimationFrames, timePerFrame: myCurrNs.1[0]))
            self.run(skRunner)
            return currGameAnimationFrames.first?.size()
        } catch {
            debugPrint(#function + " ------NS GIF NODE IS WIFFED------- ", error)
            return nil
        }
    }
    
    class func gif(with data: NSData) -> ([SKTexture]?, [Double]) {
        print("-----------Gif things---------------t")
        guard let myCurrSrc = CGImageSourceCreateWithData(data, nil) else {
            print("-----------Gif things---------------t")
            return (nil, [])
        }
        return SKSpriteNode.animatedImage(with: myCurrSrc)
    }
    
    class func animatedImage(with source: CGImageSource) -> ([SKTexture]?, [Double]) {
        let myIndexer = CGImageSourceGetCount(source)
        var currGameTiming = [Double]()
        var currGameAnimationFrames = [SKTexture]()
        for i in 0..<myIndexer {
            if let myAsset = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let mySkTx = SKTexture(cgImage: myAsset)
                currGameAnimationFrames.append(mySkTx)
            }
            let resultingTime = SKSpriteNode.delayForImageAtIndex(index: Int(i), source: source); currGameTiming.append(resultingTime)
        }
        
        return (currGameAnimationFrames, currGameTiming)
    }
    class func gcdForArray(array: Array<Int>) -> Int {
        let retVal = 1
        let tempy = array;
        if tempy.isEmpty { return retVal }
        var gcd = array[0]
        tempy.forEach { val in gcd = SKSpriteNode.gcdFor(pair: val, target: gcd) }
        return gcd
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        debugPrint(#function + " ------Image Index------- ")
        var imageStutter = 0.1
        let terminalDbl = Double(0)
        let sourceImgCopyProp = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let savvyBirdDictionaryProp: CFDictionary = unsafeBitCast(CFDictionaryGetValue(sourceImgCopyProp, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
        let terminal = 0.01

        var impeederCast: AnyObject = unsafeBitCast(CFDictionaryGetValue(savvyBirdDictionaryProp, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
        
        if impeederCast.doubleValue == terminalDbl {
            impeederCast = unsafeBitCast(CFDictionaryGetValue(savvyBirdDictionaryProp, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        imageStutter = impeederCast as! Double
        if imageStutter < terminal { imageStutter = terminal }
        return imageStutter
    }
    
    class func gcdFor(pair value: Int, target: Int) -> Int {
        var myVal1 = value; var myVal2 = target
        if myVal1 < myVal2 {
            let myVal3 = myVal1; myVal1 = myVal2; myVal2 = myVal3
        }
        var remainder: Int
        while true { remainder = myVal1 % myVal2
            if remainder == 0 { return myVal2 }
            else { myVal1 = myVal2; myVal2 = remainder }
        }
    }
}



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
    

/*
 func present(scene: SKScene?, shaderName: String, transitionDuration: TimeInterval) {
    
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
 */
}
/*
extension Bool {
    
    static var pseudoRandomPipe: Bool {
        return CGFloat.range(min: 1.0, max: 2.0) <= 1.6
    }
}
*/










