//
//  String+Extension.swift
//  PersistenceTest
//
//  Created by Shin Jae Ung on 2022/11/24.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: self)
    }
}
