//
//  ButtonNode.swift
//  StavvyBird
//
//

import SpriteKit

protocol ButtonNodeResponderType: AnyObject {
    func buttonTriggered(button: ButtonNode)
}

enum myButtonIdentifier: String {
    case start = "Start";case menu = "Menu"; case cancel = "Cancel"; case venu = "Venu";     case scores = "Scores"; case scores22 = "Scores22"; case retry = "Retry"; case penu = "Penu";  case home = "Home"; case sound = "Sound"; case zenu = "Zenu"; case pause = "Pause"; case eldy = "EldyBird"; case settings = "Settings"; case raven = "RavensBird";case resume = "Resume"; case titley = "Titley"; case titley22 = "Titley22";  case home22 = "Home22";case retry22 = "Retry22";

    case ItemShopCharacters = "ItemShopCharacters"
    //case difficulty = "Difficulty" .difficulty
    
    static let allOfTheGameButtonss: [myButtonIdentifier] = [
        .start, .pause, .resume, .menu, .venu, .penu, .zenu,.titley, .settings, .home, .retry,.retry22, .cancel, .scores,.scores22, sound, .ItemShopCharacters, .eldy, .raven, .titley22, .home22
    ]
    
    var selectedTextureName: String? {
        switch self {
        default:
            return nil
        }
    }
}

class ButtonNode: SKSpriteNode {
    
    var myCurrButId: myButtonIdentifier!

    var currGameHighlyt = false {
        didSet {
            guard oldValue != currGameHighlyt else { return }
            removeAllActions()
            let butCgHighlight: CGFloat = currGameHighlyt ? 0.98 : 1.02
            let skActionresize = SKAction.scale(by: butCgHighlight, duration: 0.14)
            let mixTheHighlights: CGFloat = currGameHighlyt ? 1.0 : 0.0
            let mixTheHigh = SKAction.colorize(withColorBlendFactor: mixTheHighlights, duration: 0.14)
            run(SKAction.group([skActionresize, mixTheHigh]))
        }
    }
    
    var currChosenText = false { didSet { texture = currChosenText ? theSkTWeAssigned : atRestSkTx }}
    
    var atRestSkTx: SKTexture?
    var theSkTWeAssigned: SKTexture?
    var focusableNeighbors = [ControlInputDirection: ButtonNode]()
    

    var isFocused = false {
        didSet {
            if isFocused {
                run(SKAction.scale(to: 1.09, duration: 0.21))
                
                focusRing.alpha = 0.0
                focusRing.isHidden = false
                focusRing.run(SKAction.fadeIn(withDuration: 0.3))
            }
            else {
                run(SKAction.scale(to: 1.0, duration: 0.21))
                
                focusRing.isHidden = true
            }
        }
    }
    
    lazy var focusRing: SKNode = self.childNode(withName: "focusRing")!
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let nameOfAsset = name, let myCurrButId = myButtonIdentifier(rawValue: nameOfAsset) else {
            fatalError("The button didn't exist.")
        }
        self.myCurrButId = myCurrButId
        
        atRestSkTx = texture
        
        if let textureName = myCurrButId.selectedTextureName {
            theSkTWeAssigned = SKTexture(imageNamed: textureName)
        }
        else {
            theSkTWeAssigned = texture
        }
        
        focusRing.isHidden = true
        isUserInteractionEnabled = true
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let newButton = super.copy(with: zone) as! ButtonNode
        
        newButton.myCurrButId = myCurrButId
        newButton.atRestSkTx = atRestSkTx?.copy() as? SKTexture
        newButton.theSkTWeAssigned = theSkTWeAssigned?.copy() as? SKTexture
        return newButton
    }
    
    func buttonTriggered() {
        if isUserInteractionEnabled {
            responder.buttonTriggered(button: self)
        }
    }
    

    func performInvalidFocusChangeAnimationForDirection(direction: ControlInputDirection) {
        let animationKey = "ButtonNode.InvalidFocusChangeAnimationKey"
        guard action(forKey: animationKey) == nil else { return }
        
        let theAction: SKAction
        switch direction {
        case .up:    theAction = SKAction(named: "InvalidFocusChange_Up")!
        case .down:  theAction = SKAction(named: "InvalidFocusChange_Down")!
        case .left:  theAction = SKAction(named: "InvalidFocusChange_Left")!
        case .right: theAction = SKAction(named: "InvalidFocusChange_Right")!
        }
        
        run(theAction, withKey: animationKey)
    }
    
    var responder: ButtonNodeResponderType {
        guard let responder = scene as? ButtonNodeResponderType else {
            fatalError("Current Button isn't in scene")
        }
        return responder
    }
    
    
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        currGameHighlyt = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        currGameHighlyt = false
        if containsTouches(touches: touches) { buttonTriggered() }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        /*we can set the highlight */ currGameHighlyt = false
    }
    
    private func containsTouches(touches: Set<UITouch>) -> Bool {
        guard let scene = scene else { return false }
        return touches.contains { touch in
            let whereWasPinged = touch.location(in: scene)
            let whatGotTouched = scene.atPoint(whereWasPinged)
            return whatGotTouched === self || whatGotTouched.inParentHierarchy(self)
        }
    }
}

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
            guard let On = state.On, let Off = state.Off else {
                return
            }
            On.isHidden = !isOn
            Off.isHidden = isOn
            if isUserInteractionEnabled {
                toggleResponder.toggleButtonTriggered(toggle: self)
            }
        }
    }
    
    private var state: (On: SKLabelNode?, Off: SKLabelNode?) = (On: nil, Off: nil)
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
        state.On = onState
        guard let offState = self.childNode(withName: "Off") as? SKLabelNode else {
            fatalError("Unavailable:  SKLabel node")
        }
        state.Off = offState
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isOn = !isOn
    }
}


