//
//  VideoURLService.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/21.
//

import Foundation

final class VideoURLService {
    enum URLError: Error {
        case noFile
    }
    
    static let path: String = "videos"
    private let url: URL
    private let pathExtension: String = ".mp4"
    
    init(url: URL) throws {
        self.url = url.appendingPathComponent(Self.path)
        try createFolderIfNotExists()
    }
    
    private func createFolderIfNotExists() throws {
        if !FileManager.default.fileExists(atPath: url.path()) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    func moveURLToVideoFolder(_ currentURL: URL, withChangingNameTo name: String) throws {
        try FileManager.default.moveItem(at: currentURL, to: url.appendingPathComponent(name + pathExtension))
    }
    
    func fetchVideoURL(named name: String) throws -> URL {
        let videoURL = url.appendingPathComponent(name + pathExtension)
        if FileManager.default.fileExists(atPath: videoURL.path()) {
            return videoURL
        } else {
            throw URLError.noFile
        }
    }
}
