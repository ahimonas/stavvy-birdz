//
//  SKTextureAtlas.swift
//  StavvyBird
//


import SpriteKit.SKTextureAtlas
import SpriteKit.SKTexture

//reusable utils
extension SKTextureAtlas {
    
    class func upload(named name: String, beginIndex: Int = 1, pattern: (_ name: String, _ index: Int) -> String) throws -> [SKTexture] {
        //reusable utils

        let atlas = SKTextureAtlas(named: name)
        var frames = [SKTexture]()
        let count = atlas.textureNames.count
        //reusable utilsatlas

        if beginIndex > count {
            throw NSError(domain: "Atlas failed : \(name)", code: 1, userInfo: nil)
        }
        
        for index in beginIndex...count {
            let namePattern = pattern(name, index)
            let texture = atlas.textureNamed(namePattern)
            frames.append(texture)
        }
        
        return frames
    }
}


