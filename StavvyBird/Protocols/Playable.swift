//
//  Playable.swift
//  StavvyBird
//
//  Created by Astemir Eleev on 22/05/2018.

//

import Foundation
import CoreGraphics

protocol Playable: AnyObject {
    var isAffectedByGravity: Bool { get set }
    var size: CGSize { get set }
}
