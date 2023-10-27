//
//  Bool+PipeRandom.swift
//  StavvyBird
//

//

import Foundation
import CoreGraphics

extension Bool {
    //reusable utils 
    
    static var pseudoRandomPipe: Bool {
        return CGFloat.range(min: 1.0, max: 2.0) <= 1.6
    }
}
