//  SounioTechnologies LLC
//  StavvyBird


import UIKit

extension UserDefaults {

    
    func playableCharacter(for setting: Setting) -> PlayableCharacter? {
        guard let rawPlayableCharacter = self.string(forKey: setting.rawValue) else {
            return nil
        }
        return PlayableCharacter(rawValue: rawPlayableCharacter)
    }
    
    func set(_ playableCharacter: PlayableCharacter, for setting: Setting) {
        set(playableCharacter.rawValue, forKey: setting.rawValue)
    }
    
    func set(difficultyLevel level: Difficulty) {
        set(level.rawValue, forKey: Setting.difficulty.rawValue)
    }
    
    func rateOfBlocksInSky() -> Difficulty {
        let diffVal = double(forKey: Setting.difficulty.rawValue)
        return Difficulty(rawValue: diffVal) ?? .medium
    }
    
    
    
    func integer(for setting: Setting) -> Int {
        return self.integer(forKey: setting.rawValue)
    }
    
    func set(_ int: Int, for setting: Setting) {
        set(int, forKey: setting.rawValue)
    }
    
    func bool(for setting: Setting) -> Bool {
        return bool(forKey: setting.rawValue)
    }
    
    func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
    
}


enum Setting: String {

    case highestScoreAchieved
    case lastScore
    case isSoundOn
    case character
    case difficulty
        
    static func regusterDefaults() {
        UserDefaults.standard.register(defaults: [
            Setting.highestScoreAchieved.rawValue: 0,
            Setting.lastScore.rawValue: 0,
            Setting.isSoundOn.rawValue: true,
            Setting.character.rawValue: PlayableCharacter.bird.rawValue,
            Setting.difficulty.rawValue: Difficulty.medium.rawValue
            ])
    }
}

enum Difficulty: Double { case easy = 4.1; case medium = 3.4; case hard = 3.1 }

enum PlayableCharacter: String { case stavvyRat = "stavvyRat"; case eldyBird = "eldyBird"; case stavvyRaven = "stavvyRaven"; case stavvyGold = "stavvyGold"; case stavvyPig = "stavvyPig"; case bird = "bird"; }

extension PlayableCharacter { func getBirdCharacterName() -> String { switch self {
        case .stavvyGold: return "stavvy-gold"; case .stavvyRat: return "stavvy-rat"; case .stavvyPig: return "stavvy-pig"; case .eldyBird: return "eldy-bird"; case .stavvyRaven: return "stavvy-raven"; case .bird: return "Birddy Bird"; } }
}
