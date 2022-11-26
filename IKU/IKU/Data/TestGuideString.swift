//
//  TestGuideString.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/22.
//

import Foundation

enum TestGuide: Equatable {
    case isReady
    case incorrectDistance
    case testComplete
    case uncover
    case coverTo(Eye)
    
    var voiceText: String {
        switch self {
        case .isReady: return "Please press the record button"
        case .incorrectDistance: return "Fit the child's face to the border."
        case .testComplete: return "The test is complete.\n Please push record button."
        case .uncover: return "Recording uncovering your eye."
        case .coverTo(let eye): return "Recording covering your eyes \n Cover your \(eye == .left ? "Right" : "Left")Eye"
        }
    }
    
    var labelText: String {
        switch self {
        case .isReady, .incorrectDistance, .testComplete:
            return self.voiceText
        case .uncover, .coverTo(_):
            return self.voiceText + " 3s"
        }
    }
}
