//
//  SKEmitterNode+Utils.swift
//  StavvyBird
//
//  Created by Astemir Eleev on 20/05/2018.

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
