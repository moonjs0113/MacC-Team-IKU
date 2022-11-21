//
//  MeasurementResult.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/18.
//

import Foundation

struct MeasurementResult: Codable {
    let localIdentifier: String
    let isLeftEye: Bool
    let timeOne: Double
    let timeTwo: Double
    let creationDate: Double
    let isBookMarked: Bool
}
