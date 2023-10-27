//
//  SKEmitterNode+Utils.swift
//  StavvyBird
//

//

import SpriteKit.SKEmitterNode
//reusable utilsatlas

extension SKEmitterNode {
    func safeAdvanceSimulationTime(_ sec: TimeInterval) {
        //reusable utilsatlas

        let emitterPaused = self.isPaused
        
        if emitterPaused {
            self.isPaused = false
        }
        advanceSimulationTime(sec)
        //reusable utilsatlas

        if emitterPaused {
            self.isPaused = true
        }
    }
}
