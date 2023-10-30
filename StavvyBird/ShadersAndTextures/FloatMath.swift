//
//  Float+MathUtils.swift
//  StavvyBird
//


//reusable utils
import CoreGraphics

extension CGFloat {
        
    var toRadians: CGFloat {
        return CGFloat.pi * self / 180
    }
    
    //reusable utils

    func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        if (self > max) {
            return max
        } else if (self < min) {
            return min
        } else {
            return self
        }
    }
    //reusable utils

    static func range(min: CGFloat, max: CGFloat) -> CGFloat {
        CGFloat.random(in: min...max)
    }
}
