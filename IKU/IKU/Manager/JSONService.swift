//
//  JSONService.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/21.
//

import Foundation

final class JSONService {
    static let path: String = "StrabismusAngles"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let url: URL
    
    init(url: URL) throws {
        self.url = url.appendingPathComponent(Self.path)
        try createFolderIfNotExists()
    }
    
    private func createFolderIfNotExists() throws {
        if !FileManager.default.fileExists(atPath: url.path()) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    func fetch(toFileName name: String) throws -> StrabismusAngle { 
        let url = url.appendingPathComponent(name, conformingTo: .json)
        let jsonData = try Data(contentsOf: url)
        return try decoder.decode(StrabismusAngle.self, from: jsonData)
    }
    
    func save(toFileName name: String, with dictionary: [Double: Double]) throws {
        let strabismusAngle = StrabismusAngle(fileName: name, dictionary: dictionary)
        let encodedData = try encoder.encode(strabismusAngle)
        try encodedData.write(to: url.appendingPathComponent(name, conformingTo: .json))
    }
    
    func delete(ofFileName name: String) throws {
        try FileManager.default.removeItem(at: url.appendingPathComponent(name, conformingTo: .json))
    }
}

struct StrabismusAngle: Codable {
    let fileName: String
    let dictionary: [Double: Double]
}
