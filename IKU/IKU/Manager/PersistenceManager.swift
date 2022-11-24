//
//  PersistenceManager.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/21.
//

import Foundation

final class PersistenceManager {
    enum Term {
        case all
        case at(day: Date)
    }
    
    private let sqliteService: SQLiteService
    private let jsonService: JSONService
    private let videoURLService: VideoURLService
    private let url: URL
    
    init() throws {
        self.url = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        try self.sqliteService = SQLiteService(url: self.url)
        try self.sqliteService.createTableIfNotExist(byQuery: .videoTable)
        try self.jsonService = JSONService(url: self.url)
        try self.videoURLService = VideoURLService(url: self.url)
    }
    
    func clearGarbageFilesInDocumentFolder() throws {
        let usingFiles: [String] = [SQLiteService.path, JSONService.path, VideoURLService.path]
        let fileNamesOfGarbageFiles = try FileManager.default.contentsOfDirectory(atPath: url.path())
            .filter { !usingFiles.contains($0) }
        try fileNamesOfGarbageFiles.forEach {
            try FileManager.default.removeItem(at: url.appendingPathComponent($0))
        }
    }
    
    func save(
        videoURL: URL,
        withARKitResult dictionay: [Double: Double],
        isLeftEye: Bool,
        uncoveredPhotoTime: Double,
        coveredPhotoTime: Double,
        creationDate: Date = Date.now,
        isBookMarked: Bool = false
    ) throws {
        let newFileName = UUID().uuidString
        try jsonService.save(
            toFileName: newFileName,
            with: dictionay
        )
        try videoURLService.moveURLToVideoFolder(
            videoURL,
            withChangingNameTo: newFileName
        )
        try sqliteService.insert(
            byQuery: .videoData(
                localIdentifier: newFileName,
                eye: isLeftEye ? 1 : 0,
                timeOne: uncoveredPhotoTime,
                timeTwo: coveredPhotoTime,
                creationTimeinterval: creationDate.timeIntervalSince1970,
                bookmark: isBookMarked ? 1 : 0
            )
        )
    }
    
    func fetchVideo(_ day: Term) throws -> [(videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)] {
        switch day {
        case .all:
            return try fetchVideo(from: try sqliteService.select(byQuery: .allVideos))
        case .at(let day):
            return try fetchVideo(from: try sqliteService.select(byQuery: .videoForSpecipic(day: day)))
        }
    }
    
    func deleteVideo(withLocalIdentifier localIdentifier: String) throws {
        try jsonService.delete(ofFileName: localIdentifier)
        try videoURLService.deleteVideoURL(named: localIdentifier)
        try sqliteService.delete(byQuery: .videoData(withLocalIdentifier: localIdentifier))
    }
    
    private func fetchVideo(from measurementResults: [MeasurementResult]) throws -> [(videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)] {
        return try measurementResults.map { measurementResult in
            let fileName = measurementResult.localIdentifier
            let videoURL = try videoURLService.fetchVideoURL(named: fileName)
            let angles = try jsonService.fetch(toFileName: fileName).dictionary
            return ((videoURL, angles, measurementResult))
        }
    }
}


