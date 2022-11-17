//
//  PersistenceTest.swift
//  PersistenceTest
//
//  Created by Shin Jae Ung on 2022/11/17.
//

import XCTest

final class PersistenceTest: XCTestCase {
    var persistenceManager: PersistenceManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistenceManager = try PersistenceManager()
    }
    
    override func tearDownWithError() throws {
        let dbURL: URL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("IKU.sqlite")
        try FileManager.default.removeItem(at: dbURL)
        persistenceManager = nil
        try super.tearDownWithError()
    }

    func test_table_select_data_of_same_day() throws {
        try persistenceManager.createTableIfNotExist(byQuery: .videoTable)
        try persistenceManager.insert(
            byQuery: .videoData(
                localIdentifier: "localIdentifier",
                isLeftEye: true,
                timeOne: 0,
                timeTwo: 0,
                creationDate: "2022-11-22 00:12:34".toDate()!.timeIntervalSince1970,
                isBookMarked: false
            )
        )
        
        for day in 21...23 {
            for hour in 0...23 {
                let dateString = createDateString(year: 2022, month: 11, day: day, hour: hour, minute: 12, second: 34)
                let date = dateString.toDate()!
                let array = try persistenceManager.select(byQuery: .videoForSpecipic(day: date))
                if day == 22 {
                    XCTAssertEqual(array.count, 1)
                } else {
                    XCTAssertEqual(array.count, 0)
                }
            }
        }
    }
    
    private func createDateString(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> String {
        return "\(year)-\(month)-\(day) \(hour):\(minute):\(second)"
    }
}

private extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: self)
    }
}
