//
//  CVMonth.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/12.
//

import Foundation

enum Month: String, CaseIterable {
    case january
    case february
    case march
    case April
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    var calendarTitle: String {
        self.rawValue.suffix(3).uppercased()
    }
    
    var pickerTitle: String {
        var string = self.rawValue
        string.removeFirst()
        let firstChar = self.rawValue.first?.uppercased() ?? ""
        return firstChar + string
    }
}
