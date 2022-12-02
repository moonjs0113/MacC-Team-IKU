//
//  TestGuideString.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/22.
//

import Foundation

enum TestGuide: Equatable {
    case getCloser
    case getAway
    case keepDistance
    
    case isReady
    case incorrectDistance
    case testComplete
    case uncover
    case coverTo(Eye)
    case countTime
    
    var voiceText: String {
        switch self {
        case .getCloser: return "get closer"
        case .getAway: return "get away"
        case .keepDistance: return "please keep this distance"
            
        case .countTime: return "3s...2s...1s...Done!"
            
        case .isReady: return "Please press the record button"
        case .incorrectDistance: return "Fit the child's face to the border."
        case .testComplete: return "The test is complete.\nPlease push record button."
        case .uncover: return "Recording uncovering your eye."
        case .coverTo(let eye): return "Recording covering your eyes.\nCover your \(eye == .left ? "Right" : "Left")Eye"
        }
    }
    
    var labelText: String {
        switch self {
        case .getAway, .getCloser, .keepDistance, .countTime:
            return self.voiceText
        case .isReady, .incorrectDistance, .testComplete:
            return self.voiceText
        case .uncover, .coverTo(_):
            return self.voiceText + " 3s"
        }
    }
}
