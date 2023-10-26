//  SounioTechnologies LLC
//  StavvyBird

import Foundation
import SpriteKit

protocol PlaySceneProtocol {
    var updatables: [Updatable] { get }
    var touchables: [Touchable] { get }
    
    var scene: SKScene? { get }
    init?(with scene: SKScene)
    
}
