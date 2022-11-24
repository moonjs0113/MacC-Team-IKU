//
//  XCTestCase+Extension.swift
//  PersistenceTest
//
//  Created by Shin Jae Ung on 2022/11/21.
//

import XCTest

extension XCTestCase {
    func documentFolderURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }
    
    func allFileNamesInDocumentDirectory() throws -> [String] {
        let dbURL: URL = try documentFolderURL()
        return try FileManager.default.contentsOfDirectory(atPath: dbURL.path())
    }
    
    func allFileNamesInDocumentDirectory(appendingPathComponent component: String) throws -> [String] {
        let dbURL: URL = try documentFolderURL().appendingPathComponent(component)
        return try FileManager.default.contentsOfDirectory(atPath: dbURL.path())
    }
    
    func exampleFileURLWithCreatingFile() throws -> URL {
        let testData = "example".data(using: .utf8)
        let testFileURL = try documentFolderURL().appendingPathComponent("example.mp4")
        FileManager.default.createFile(atPath: testFileURL.path(), contents: testData)
        return testFileURL
    }
}
