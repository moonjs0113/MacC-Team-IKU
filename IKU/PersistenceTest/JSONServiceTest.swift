//
//  JSONServiceTest.swift
//  PersistenceTest
//
//  Created by Shin Jae Ung on 2022/11/21.
//

@testable import IKU
import XCTest

final class JSONServiceTest: XCTestCase {
    var jsonService: JSONService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        jsonService = try JSONService(url: documentFolderURL())
    }

    override func tearDownWithError() throws {
        let dbURL: URL = try documentFolderURL().appendingPathComponent(JSONService.path)
        try FileManager.default.removeItem(at: dbURL)
        jsonService = nil
        try super.tearDownWithError()
    }

    func test_save_data() throws {
        XCTAssertNoThrow(try jsonService.save(toFileName: "test", with: [:]))
    }
    
    func test_save_data_and_check_if_it_is_in() throws {
        try jsonService.save(toFileName: "test", with: [:])
        let allFileNames = try allFileNamesInDocumentDirectory(appendingPathComponent: JSONService.path)
        XCTAssertEqual(allFileNames.count, 1)
        XCTAssertEqual(allFileNames.first, "test.json")
    }
    
    func test_delete_data() throws {
        try jsonService.save(toFileName: "test", with: [:])
        XCTAssertNoThrow(try jsonService.delete(ofFileName: "test"))
    }
}
