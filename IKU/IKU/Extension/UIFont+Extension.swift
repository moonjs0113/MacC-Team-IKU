//
//  UIFont+Extension.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/11.
//

import UIKit

extension UIFont {
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
    }
    
    static func nexonGothicFont(ofSize fontSize: CGFloat, weight: NexonFont = .regular) -> UIFont {
        guard let font = UIFont.init(name: weight.name, size: fontSize) else {
            return .systemFont(ofSize: fontSize, weight: .regular)
        }
        return font
    }
}
