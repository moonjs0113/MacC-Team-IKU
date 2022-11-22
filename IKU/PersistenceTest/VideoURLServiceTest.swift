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
        let testFileURL = try testFileURLWithCreatingFile()
        try videoURLService.moveURLToVideoFolder(testFileURL, withChangingNameTo: "test")
        let allFileNames = try allFileNamesInDocumentDirectory(appendingPathComponent: VideoURLService.path)
        XCTAssertEqual(allFileNames.count, 1)
        XCTAssertEqual(allFileNames.first, "test.mp4")
    }
    
    func test_fetch_video_url() throws {
        let testFileURL = try testFileURLWithCreatingFile()
        try videoURLService.moveURLToVideoFolder(testFileURL, withChangingNameTo: "test")
        let url = try videoURLService.fetchVideoURL(named: "test")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path()))
    }
}
