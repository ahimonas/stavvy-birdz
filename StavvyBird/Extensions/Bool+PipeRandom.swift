//
//  Bool+PipeRandom.swift
//  StavvyBird
//
//  Created by Astemir Eleev on 03/06/2018.

//

import Foundation
import CoreGraphics

extension Bool {
    
    static var pseudoRandomPipe: Bool {
        return CGFloat.range(min: 1.0, max: 2.0) <= 1.6
    }
}
