//
//  SQLiteServiceTest.swift
//  PersistenceTest
//
//  Created by Shin Jae Ung on 2022/11/17.
//

import XCTest

final class SQLiteServiceTest: XCTestCase {
    var sqliteService: SQLiteService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sqliteService = try SQLiteService(url: documentFolderURL())
    }
    
    override func tearDownWithError() throws {
        let dbURL: URL = try documentFolderURL().appendingPathComponent(SQLiteService.path)
        try FileManager.default.removeItem(at: dbURL)
        sqliteService = nil
        try super.tearDownWithError()
    }

    func test_table_select_data_of_same_day() throws {
        let measurementResult = MeasurementResult(
            localIdentifier: "localIdentifier",
            isLeftEye: true,
            timeOne: 0,
            timeTwo: 1.2,
            creationDate: "2022-11-22 00:12:34".toDate()!.timeIntervalSince1970,
            isBookMarked: false
        )
        try sqliteService.createTableIfNotExist(byQuery: .videoTable)
        try sqliteService.insert(byQuery: .videoData(measurementResult: measurementResult))
        
        for day in 21...23 {
            for hour in 0...23 {
                let dateString = createDateString(year: 2022, month: 11, day: day, hour: hour, minute: 12, second: 34)
                let date = dateString.toDate()!
                let array = try sqliteService.select(byQuery: .videoForSpecipic(day: date))
                if day == 22 {
                    XCTAssertEqual(array.count, 1)
                    XCTAssertEqual(array.first?.localIdentifier, "localIdentifier")
                    XCTAssertEqual(array.first?.isLeftEye, true)
                    XCTAssertEqual(array.first?.timeOne, 0)
                    XCTAssertEqual(array.first?.timeTwo, 1.2)
                    XCTAssertEqual(array.first?.creationDate, "2022-11-22 00:12:34".toDate()!.timeIntervalSince1970)
                    XCTAssertEqual(array.first?.isBookMarked, false)
                } else {
                    XCTAssertEqual(array.count, 0)
                }
            }
        }
    }
    
    func test_table_select_all() throws {
        try sqliteService.createTableIfNotExist(byQuery: .videoTable)
        for number in 1...10 {
            let measurementResult = MeasurementResult(
                localIdentifier: String(number),
                isLeftEye: true,
                timeOne: 0,
                timeTwo: 0,
                creationDate: "2022-11-\(String(format: "%02d", number)) 00:12:34".toDate()!.timeIntervalSince1970,
                isBookMarked: false
            )
            try sqliteService.insert(byQuery: .videoData(measurementResult: measurementResult))
        }
        let array = try sqliteService.select(byQuery: .allVideos)
        XCTAssertEqual(array.count, 10)
    }
    
    func test_delete_data() throws {
        let localIdentifier = "E3C929C3-3B49-480E-A47B-A8479F40A4C2"
        let measurementResult = MeasurementResult(
            localIdentifier: localIdentifier,
            isLeftEye: true,
            timeOne: 0,
            timeTwo: 1.2,
            creationDate: "2022-11-22 00:12:34".toDate()!.timeIntervalSince1970,
            isBookMarked: false
        )
        try sqliteService.createTableIfNotExist(byQuery: .videoTable)
        try sqliteService.insert(byQuery: .videoData(measurementResult: measurementResult))
        
        XCTAssertNoThrow(
            try sqliteService.delete(byQuery: .videoData(withLocalIdentifier: localIdentifier))
        )
    }
    
    func test_delete_data_and_check_if_it_exists() throws {
        let localIdentifier = "E3C929C3-3B49-480E-A47B-A8479F40A4C2"
        let measurementResult = MeasurementResult(
            localIdentifier: localIdentifier,
            isLeftEye: true,
            timeOne: 0,
            timeTwo: 1.2,
            creationDate: "2022-11-22 00:12:34".toDate()!.timeIntervalSince1970,
            isBookMarked: false
        )
        try sqliteService.createTableIfNotExist(byQuery: .videoTable)
        try sqliteService.insert(byQuery: .videoData(measurementResult: measurementResult))
        
        let resultsBeforeDeletion = try sqliteService.select(byQuery: .videoForSpecipic(day: "2022-11-22 00:12:34".toDate()!))
        XCTAssertEqual(resultsBeforeDeletion.count, 1)
        
        try sqliteService.delete(byQuery: .videoData(withLocalIdentifier: localIdentifier))
        let resultsAfterDeletion = try sqliteService.select(byQuery: .videoForSpecipic(day: "2022-11-22 00:12:34".toDate()!))
        XCTAssertEqual(resultsAfterDeletion.count, 0)
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
