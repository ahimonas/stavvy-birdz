//
//  ToggleButtonNode.swift
//  StavvyBird
//
//

import SpriteKit

protocol ToggleButtonNodeResponderType: AnyObject {
    func toggleButtonTriggered(toggle: ToggleButtonNode)
}

class ToggleButtonNode: ButtonNode {
        
    var isOn: Bool {
        didSet {
            guard let on = state.on, let off = state.off else {
                return
            }
            
            on.isHidden = !isOn
            off.isHidden = isOn
            
            if isUserInteractionEnabled {
                toggleResponder.toggleButtonTriggered(toggle: self)
            }
        }
    }
    
    private var state: (on: SKLabelNode?, off: SKLabelNode?) = (on: nil, off: nil)
    

    var toggleResponder: ToggleButtonNodeResponderType {
        guard let responder = scene as? ToggleButtonNodeResponderType else {
            fatalError("The button didn't change state")
        }
        return responder
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        let isSoundOn = UserDefaults.standard.bool(for: .isSoundOn)
        isOn = isSoundOn
        
        super.init(coder: aDecoder)
        
        guard let onState = self.childNode(withName: "On") as? SKLabelNode else  {
            fatalError("Unavailable:  SKLabel node")
        }
        state.on = onState
        
        guard let offState = self.childNode(withName: "Off") as? SKLabelNode else {
            fatalError("Unavailable:  SKLabel node")
        }
        state.off = offState
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isOn = !isOn
    }
}

