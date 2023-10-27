import Foundation

struct GamePhysics : OptionSet {
    let rawValue : UInt32
    static let boundary     = GamePhysics(rawValue: 1 << 0)
    static let player       = GamePhysics(rawValue: 1 << 1)
    static let pipe         = GamePhysics(rawValue: 1 << 2)
    static let gap          = GamePhysics(rawValue: 1 << 3)
}
