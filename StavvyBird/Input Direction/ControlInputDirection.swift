//
//  ControlInput.swift
//  StavvyBird
//

//

import simd

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
