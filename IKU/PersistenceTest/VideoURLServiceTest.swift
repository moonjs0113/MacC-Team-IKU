//
//  VideoURLServiceTest.swift
//  PersistenceTest
//
//  Created by Shin Jae Ung on 2022/11/21.
//

import XCTest

final class VideoURLServiceTest: XCTestCase {
    var videoURLService: VideoURLService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        videoURLService = try VideoURLService(url: documentFolderURL())
    }

    override func tearDownWithError() throws {
        let dbURL: URL = try documentFolderURL().appendingPathComponent(VideoURLService.path)
        try FileManager.default.removeItem(at: dbURL)
        videoURLService = nil
        try super.tearDownWithError()
    }

    func test_move_URL_to_folder() throws {
        let testFileURL = try exampleFileURLWithCreatingFile()
        try videoURLService.moveURLToVideoFolder(testFileURL, withChangingNameTo: "test")
        let allFileNames = try allFileNamesInDocumentDirectory(appendingPathComponent: VideoURLService.path)
        XCTAssertEqual(allFileNames.count, 1)
        XCTAssertEqual(allFileNames.first, "test.mp4")
    }
    
    func test_fetch_video_url() throws {
        let testFileURL = try exampleFileURLWithCreatingFile()
        try videoURLService.moveURLToVideoFolder(testFileURL, withChangingNameTo: "test")
        let url = try videoURLService.fetchVideoURL(named: "test")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path()))
    }
    
    func test_delete_video() throws {
        let testFileURL = try exampleFileURLWithCreatingFile()
        let testFileName = "test"
        try videoURLService.moveURLToVideoFolder(testFileURL, withChangingNameTo: testFileName)
        let allFileNamesBeforeDeletion = try allFileNamesInDocumentDirectory(appendingPathComponent: VideoURLService.path)
        XCTAssertEqual(allFileNamesBeforeDeletion.count, 1)
        XCTAssertEqual(allFileNamesBeforeDeletion.first, "test.mp4")
        try videoURLService.deleteVideoURL(named: testFileName)
        let allFileNamesAfterDeletion = try allFileNamesInDocumentDirectory(appendingPathComponent: VideoURLService.path)
        XCTAssertEqual(allFileNamesAfterDeletion.count, 0)
    }
    
    func test_delete_video_if_it_only_delete_specific_file() throws {
        let testFileOneURL = try exampleFileURLWithCreatingFile()
        let testFileOneName = "testOne"
        try videoURLService.moveURLToVideoFolder(testFileOneURL, withChangingNameTo: testFileOneName)
        let testFileTwoURL = try exampleFileURLWithCreatingFile()
        let testFileTwoName = "testTwo"
        try videoURLService.moveURLToVideoFolder(testFileTwoURL, withChangingNameTo: testFileTwoName)
        
        let allFileNamesBeforeDeletion = try allFileNamesInDocumentDirectory(appendingPathComponent: VideoURLService.path)
        XCTAssertEqual(allFileNamesBeforeDeletion.count, 2)
        
        try videoURLService.deleteVideoURL(named: testFileTwoName)
        let allFileNamesAfterDeletion = try allFileNamesInDocumentDirectory(appendingPathComponent: VideoURLService.path)
        XCTAssertEqual(allFileNamesAfterDeletion.count, 1)
        XCTAssertEqual(allFileNamesAfterDeletion.first, testFileOneName + ".mp4")
    }
}
