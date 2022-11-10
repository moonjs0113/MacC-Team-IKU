//
//  NexonFont.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/10.
//

import Foundation

enum NexonFont {
    case regular
    case light
    case bold
    
    var name: String {
        switch self {
        case .regular: return "NEXONLv1GothicOTFRegular"
        case .light: return "NEXONLv1GothicOTFLight"
        case .bold: return "NEXONLv1GothicOTFBold"
        }
    }
    
    // Usage
    // UIFont(name: NexonFont.regular.name, size: 13)
}
