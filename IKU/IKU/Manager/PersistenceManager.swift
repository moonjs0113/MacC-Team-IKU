//
//  PersistenceManager.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/21.
//

import Foundation

final class PersistenceManager {
    let sqliteService: SQLiteService
    let jsonService: JSONService
    
    init() throws {
        try self.sqliteService = SQLiteService()
        try self.sqliteService.createTableIfNotExist(byQuery: .videoTable)
        try self.jsonService = JSONService()
    }
}
