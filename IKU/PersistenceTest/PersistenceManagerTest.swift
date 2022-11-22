//
//  PersistenceManagerTest.swift
//  PersistenceTest
//
//  Created by Shin Jae Ung on 2022/11/21.
//

import XCTest

final class PersistenceManagerTest: XCTestCase {
    var persistenceManager: PersistenceManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.persistenceManager = try PersistenceManager()
    }

    override func tearDownWithError() throws {
        let dbURL: URL = try documentFolderURL()
        persistenceManager = nil
        for item in try allFileNamesInDocumentDirectory() {
            try FileManager.default.removeItem(at: dbURL.appendingPathComponent(item))
        }
        try super.tearDownWithError()
    }

    func test_save_video_without_prefixed_values() throws {
        try persistenceManager.save(
            videoURL: try testFileURLWithCreatingFile(),
            withARKitResult: [:],
            isLeftEye: true,
            uncoveredPhotoTime: 0,
            coveredPhotoTime: 1.2
        )
    }
    
    func test_save_video_with_all_values() throws {
        try persistenceManager.save(
            videoURL: try testFileURLWithCreatingFile(),
            withARKitResult: [:],
            isLeftEye: true,
            uncoveredPhotoTime: 0,
            coveredPhotoTime: 1.2,
            creationDate: Date.now.timeIntervalSince1970,
            isBookMarked: false
        )
    }
    
    func test_fetch_all_video() throws {
        try persistenceManager.save(
            videoURL: try testFileURLWithCreatingFile(),
            withARKitResult: [2.2:3.3],
            isLeftEye: true,
            uncoveredPhotoTime: 0,
            coveredPhotoTime: 1.2,
            creationDate: 1234567,
            isBookMarked: false
        )
        let result = try persistenceManager.fetchVideo(.all)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.angles, [2.2:3.3])
        XCTAssertEqual(result.first?.measurementResult.isLeftEye, true)
        XCTAssertEqual(result.first?.measurementResult.timeOne, 0)
        XCTAssertEqual(result.first?.measurementResult.timeTwo, 1.2)
        XCTAssertEqual(result.first?.measurementResult.creationDate, 1234567)
        XCTAssertEqual(result.first?.measurementResult.isBookMarked, false)
    }
    
    func test_clear_garbage_files() throws {
        _ = try testFileURLWithCreatingFile()
        var expectedFiles: Set<String> = ["example.mp4", "strabismusAngles", "videos", "IKU.sqlite"]
        
        for fileName in try allFileNamesInDocumentDirectory() {
            XCTAssertTrue(expectedFiles.contains(fileName))
            expectedFiles.remove(fileName)
        }
        
        try persistenceManager.clearGarbageFilesInDocumentFolder()
        
        expectedFiles = ["strabismusAngles", "videos", "IKU.sqlite"]
        
        for fileName in try allFileNamesInDocumentDirectory() {
            XCTAssertTrue(expectedFiles.contains(fileName))
            expectedFiles.remove(fileName)
        }
    }
}
