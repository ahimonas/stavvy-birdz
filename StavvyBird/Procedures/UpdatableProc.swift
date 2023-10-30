//  SounioTechnologies LLC
//  StavvyBird

import Foundation

protocol Updatable: AnyObject {
    
    var delta: TimeInterval { get }
    var previousTiming: TimeInterval { get }
    var willRenew: Bool { get set }
    
    func update(_ currentTime: TimeInterval)
}


extension Updatable {
    func computeUpdatable(currentTime: TimeInterval) -> (delta: TimeInterval, previousTiming: TimeInterval) {
        let currDelta = (self.previousTiming == 0.0) ? 0.0 : currentTime - self.previousTiming
        let previousMarkTime = currentTime
        return (delta: currDelta, previousTiming: previousMarkTime)
    }
}
