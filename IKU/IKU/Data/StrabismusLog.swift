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
        return [
            StrabismusLog(date: .now.addingTimeInterval(0), degree: 0.5),
            StrabismusLog(date: .now.addingTimeInterval(1), degree: 0.6),
            StrabismusLog(date: .now.addingTimeInterval(2), degree: 0.5),
            StrabismusLog(date: .now.addingTimeInterval(3), degree: 0.7),
            StrabismusLog(date: .now.addingTimeInterval(4), degree: 0.7),
            StrabismusLog(date: .now.addingTimeInterval(5), degree: 0.5),
            StrabismusLog(date: .now.addingTimeInterval(6), degree: 0.5),
            StrabismusLog(date: .now.addingTimeInterval(7), degree: 0.6),
        ]
    }
}
