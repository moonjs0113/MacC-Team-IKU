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
        case .isReady: return "녹화버튼을 눌러주세요."
        case .incorrectDistance: return "카메라와 적정거리(30-35cm)인지 확인해주세요."
        case .testComplete: return "검사가 완료되었으니 종료버튼을 눌러주세요."
        case .uncover: return "손바닥을 떼주세요"
        case .coverTo(let eye): return "\(eye == .left ? "오른쪽" : "왼쪽") 눈을 손바닥으로 가려주세요"
        }
    }
    
    var labelText: String {
        switch self {
        case .isReady, .incorrectDistance, .testComplete:
            return self.voiceText
        case .uncover, .coverTo(_):
            return self.voiceText + " 3초"
        }
    }
}
