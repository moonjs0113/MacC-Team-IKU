//
//  StrabismusLog.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/11.
//

import Foundation

struct StrabismusLog: Hashable {
    var date: Date
    var degree: Double
    
    init(date: Date, degree: Double) {
        self.date = date
        self.degree = degree
    }
}

extension StrabismusLog {
    static var preview: StrabismusLog {
        StrabismusLog(date: .now, degree: Double.random(in: 0...15))
    }
    
    static var previews: [StrabismusLog] {
        return (0...5).map {
            StrabismusLog(date: .now.addingTimeInterval(.init(integerLiteral: $0)), degree: Double.random(in: 5...20))
        }
    }
}
