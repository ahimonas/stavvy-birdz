//  SounioTechnologies LLC
//  StavvyBird

import SpriteKit

//settings
class AtmosphereScene: RoutingUtilityScene, ToggleButtonNodeResponderType, TriggleButtonNodeResponderType {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let buttonNodeMusic = 
            scene?.childNode(withName: "Sound") as? ToggleButtonNode
        buttonNodeMusic?.isOn = 
            UserDefaults.standard.bool(for: .isSoundOn)
        
        let buttonForDifficulty = scene?.childNode(withName: "Difficulty") as? TriggleButtonNode
        let difficultyLevel = UserDefaults.standard.getDifficultyLevel()
        let difficultyState = TriggleButtonNode.TriggleState.convert(from: difficultyLevel)
        buttonForDifficulty?.triggle = .init(state: difficultyState)
    }
        
    func toggleButtonTriggered(toggle: ToggleButtonNode) {
        UserDefaults.standard.set(toggle.isOn, for: .isSoundOn)
    }
        
    func triggleButtonTriggered(triggle: TriggleButtonNode) {
        debugPrint("trigger button node")
        let currDifficulty = triggle.triggle.toDifficultyLevel()
        UserDefaults.standard.set(difficultyLevel: currDifficulty)
    }
    
}
