//
//  SKEmitterNode+Utils.swift
//  StavvyBird
//

//

import SpriteKit.SKEmitterNode

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
