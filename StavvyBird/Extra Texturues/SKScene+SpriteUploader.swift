//
//  SKScene.swift
//  StavvyBird
//

import SpriteKit.SKScene
import SpriteKit.SKNode

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
