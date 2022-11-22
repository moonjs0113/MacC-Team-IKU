//
//  File.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/21.
//

import Foundation

extension Double {
    var roundSecondPoint: Double {
        let digit: Double = pow(10, 1)
        return (self * digit).rounded() / digit
    }
}
