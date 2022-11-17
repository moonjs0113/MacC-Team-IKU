//
//  PersistenceManager.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/17.
//

import SQLite3
import Foundation

final class PersistenceManager {
    enum SQLiteError: Error {
        case openDatabase(message: String)
        case prepare(message: String)
        case createTable(message: String)
        case step(message: String)
        case bind(message: String)
    }
    enum CreationQuery {
        case videoTable
        
        var statement: String {
            switch self {
            case .videoTable: return """
                CREATE TABLE IF NOT EXISTS VIDEO(
                LOCALIDENTIFIER TEXT PRIMARY KEY NOT NULL,
                EYE INTEGER,
                TIME_ONE REAL,
                TIME_TWO REAL,
                CREATIONDATE REAL,
                BOOKMARK INTEGER
                );
                """
            }
        }
    }
    enum InsertionQuery {
        case videoData(
            localIdentifier: String,
            eye: Bool,
            timeOne: Double,
            timeTwo: Double,
            creationDate: Double,
            bookMark: Bool
        )
        var statement: String {
            switch self {
            case .videoData: return """
                INSERT INTO VIDEO (LOCALIDENTIFIER, EYE, TIME_ONE, TIME_TWO, CREATIONDATE, BOOKMARK) VALUES (?, ?, ?, ?, ?, ?);
                """
            }
        }
    }
    enum SelectionQuery {
        case videoForSpecipic(day: Date)
        
        var statement: String {
            switch self {
            case .videoForSpecipic(let day) :
                let greatOrEqual = day.startTimeIntervalOfDay
                let less = day.startTimeIntervalOfNextDay
                return """
                SELECT * FROM VIDEO WHERE CREATIONDATE >= \(greatOrEqual) AND CREATIONDATE < \(less)
                """
            }
        }
    }

    private let path = "IKU.sqlite"
    private var db: OpaquePointer? = nil

    init() throws {
        let database = try openDatabase()
        self.db = database
    }
    deinit {
        sqlite3_close(db)
    }

    private func openDatabase() throws -> OpaquePointer? {
        var db: OpaquePointer?
        let dbURL: URL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(path)

        if sqlite3_open(dbURL.path, &db) == SQLITE_OK {
            return db
        } else {
            throw SQLiteError.openDatabase(message: "Unable to open database")
        }
    }
    private func prepare(forQuery string: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, string, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.prepare(message: "SQLite3 is not prepared")
        }
        return statement
    }
    func createTableIfNotExist(byQuery query: CreationQuery) throws {
        let createTableStatement = try prepare(forQuery: query.statement)
        defer { sqlite3_finalize(createTableStatement) }
        if sqlite3_step(createTableStatement) != SQLITE_DONE {
            throw SQLiteError.createTable(message: "VIDEO table is not created")
        }
    }
    func insert(byQuery query: InsertionQuery) throws {
        let insertStatement = try prepare(forQuery: query.statement)
        defer { sqlite3_finalize(insertStatement) }
        switch query {
        case .videoData(let localIdentifier, let eye, let timeOne, let timeTwo, let creationDate, let bookMark):
            try insertVideoData(
                insertStatement: insertStatement,
                localIdentifier: localIdentifier,
                eye: eye,
                timeOne: timeOne,
                timeTwo: timeTwo,
                creationDate: creationDate,
                bookMark: bookMark
            )
        }
    }
    func select(byQuery query: SelectionQuery) throws -> [String] {
        let selectStatement = try prepare(forQuery: query.statement)
        defer { sqlite3_finalize(selectStatement) }
        switch query {
        case .videoForSpecipic:
            return try selectVideoData(selectStatement: selectStatement)
        }
    }
    
    private func insertVideoData(insertStatement: OpaquePointer?, localIdentifier: String, eye: Bool, timeOne: Double, timeTwo: Double, creationDate: Double, bookMark: Bool) throws {
        let localIdentifier = NSString(string: localIdentifier)
        let eye: Int32 = eye == true ? 1 : 0
        let bookMark: Int32 = bookMark == true ? 1 : 0
        
        sqlite3_bind_text(insertStatement, 1, localIdentifier.utf8String, -1, nil)
        sqlite3_bind_int(insertStatement, 2, eye)
        sqlite3_bind_double(insertStatement, 3, timeOne)
        sqlite3_bind_double(insertStatement, 4, timeTwo)
        sqlite3_bind_double(insertStatement, 5, creationDate)
        sqlite3_bind_int(insertStatement, 6, bookMark)
        
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            throw SQLiteError.step(message: "Could not insert row")
        }
    }
    private func selectVideoData(selectStatement: OpaquePointer?) throws -> [String] {
        var result: [String] = []
        while sqlite3_step(selectStatement) == SQLITE_ROW {
            guard let localIdentifier = sqlite3_column_text(selectStatement, 0) else {
                throw SQLiteError.step(message: "First element is not a text")
            }
            result.append(String(cString: localIdentifier))
        }
        return result
    }
}

extension Date {
    var startTimeIntervalOfDay: TimeInterval {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self).timeIntervalSince1970
    }
    var startTimeIntervalOfNextDay: TimeInterval {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: self))!.timeIntervalSince1970
    }
}
