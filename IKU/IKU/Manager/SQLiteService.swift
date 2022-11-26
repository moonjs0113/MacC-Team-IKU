//
//  SQLiteService.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/17.
//

import SQLite3
import Foundation

final class SQLiteService {
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
                CREATIONTIMEINTERVAL REAL,
                BOOKMARK INTEGER
                );
                """
            }
        }
    }
    enum InsertionQuery {
        case videoData(localIdentifier: String, eye: Int, timeOne: Double, timeTwo: Double, creationTimeinterval: Double, bookmark: Int)
        var statement: String {
            switch self {
            case .videoData: return """
                INSERT INTO VIDEO (LOCALIDENTIFIER, EYE, TIME_ONE, TIME_TWO, CREATIONTIMEINTERVAL, BOOKMARK) VALUES (?, ?, ?, ?, ?, ?);
                """
            }
        }
    }
    enum SelectionQuery {
        case allVideos
        case videoForSpecipic(day: Date)
        
        var statement: String {
            switch self {
            case .allVideos:
                return """
                SELECT * FROM VIDEO
                """
            case .videoForSpecipic(let day) :
                let greatOrEqual = day.startTimeIntervalOfDay
                let less = day.startTimeIntervalOfNextDay
                return """
                SELECT * FROM VIDEO WHERE CREATIONTIMEINTERVAL >= \(greatOrEqual) AND CREATIONTIMEINTERVAL < \(less)
                """
            }
        }
    }
    enum DeletionQuery {
        case videoData(withLocalIdentifier: String)
        
        var statement: String {
            switch self {
            case .videoData(let localIdentifier) : return """
            DELETE FROM VIDEO WHERE LOCALIDENTIFIER = '\(localIdentifier)';
            """
            }
        }
    }
    enum UpdateQuery {
        case videoBookmarkData(withLocalIdentifier: String, setTo: Int)
        case videoTimeOneAndTimeTwoData(withLocalIdentifier: String, setTimeOneTo: Double, setTimeTwoTo: Double)
        
        var statement: String {
            switch self {
            case .videoBookmarkData(let localIdentifier, let bookmark) : return """
            UPDATE VIDEO SET BOOKMARK = \(bookmark) WHERE LOCALIDENTIFIER = '\(localIdentifier)';
            """
            case .videoTimeOneAndTimeTwoData(let localIdentifier, let timeOne, let timeTwo): return """
            UPDATE VIDEO SET TIME_ONE = \(timeOne), TIME_TWO = \(timeTwo) WHERE LOCALIDENTIFIER = '\(localIdentifier)'
            """
            }
        }
    }

    static let path = "IKU.sqlite"
    private var db: OpaquePointer? = nil

    init(url: URL) throws {
        let database = try openDatabase(at: url)
        self.db = database
    }
    deinit {
        sqlite3_close(db)
    }

    private func openDatabase(at url: URL) throws -> OpaquePointer? {
        var db: OpaquePointer?
        let dbURL: URL = url.appendingPathComponent(Self.path)

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
        case .videoData(let localIdentifier, let eye, let timeOne, let timeTwo, let creationTimeinterval, let bookmark):
            try insertVideoData(
                insertStatement: insertStatement,
                localIdentifier: localIdentifier,
                eye: eye,
                timeOne: timeOne,
                timeTwo: timeTwo,
                creationTimeinterval: creationTimeinterval,
                bookmark: bookmark
            )
        }
    }
    func select(byQuery query: SelectionQuery) throws -> [MeasurementResult] {
        let selectStatement = try prepare(forQuery: query.statement)
        defer { sqlite3_finalize(selectStatement) }
        return try selectVideoData(selectStatement: selectStatement)
    }
    func delete(byQuery query: DeletionQuery) throws {
        let deleteStatement = try prepare(forQuery: query.statement)
        defer { sqlite3_finalize(deleteStatement) }
        return try deleteVideoData(deleteStatement: deleteStatement)
    }
    func update(byQuery query: UpdateQuery) throws {
        let updateStatement = try prepare(forQuery: query.statement)
        defer { sqlite3_finalize(updateStatement) }
        return try updateVideoData(updateStatement: updateStatement)
    }
    
    private func insertVideoData(insertStatement: OpaquePointer?, localIdentifier: String, eye: Int, timeOne: Double, timeTwo: Double, creationTimeinterval: Double, bookmark: Int) throws {
        sqlite3_bind_text(insertStatement, 1, NSString(string: localIdentifier).utf8String, -1, nil)
        sqlite3_bind_int(insertStatement, 2, Int32(eye))
        sqlite3_bind_double(insertStatement, 3, timeOne)
        sqlite3_bind_double(insertStatement, 4, timeTwo)
        sqlite3_bind_double(insertStatement, 5, creationTimeinterval)
        sqlite3_bind_int(insertStatement, 6, Int32(bookmark))
        
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            throw SQLiteError.step(message: "Could not insert row")
        }
    }
    private func selectVideoData(selectStatement: OpaquePointer?) throws -> [MeasurementResult] {
        var result: [MeasurementResult] = []
        while sqlite3_step(selectStatement) == SQLITE_ROW {
            guard let localIdentifier = sqlite3_column_text(selectStatement, 0) else {
                throw SQLiteError.step(message: "First element is not a text")
            }
            let eye = sqlite3_column_int(selectStatement, 1)
            let timeOne = sqlite3_column_double(selectStatement, 2)
            let timeTwo = sqlite3_column_double(selectStatement, 3)
            let creationTimeInterval = sqlite3_column_double(selectStatement, 4)
            let bookMark = sqlite3_column_int(selectStatement, 5)
            let measurementResult = MeasurementResult(
                localIdentifier: String(cString: localIdentifier),
                isLeftEye: eye == 1,
                timeOne: timeOne,
                timeTwo: timeTwo,
                creationDate: Date(timeIntervalSince1970: creationTimeInterval),
                isBookMarked: bookMark == 1
            )
            result.append(measurementResult)
        }
        return result
    }
    
    private func deleteVideoData(deleteStatement: OpaquePointer?) throws {
        if sqlite3_step(deleteStatement) != SQLITE_DONE {
            throw SQLiteError.step(message: "Could not delete row")
        }
    }
    
    private func updateVideoData(updateStatement: OpaquePointer?) throws {
        if sqlite3_step(updateStatement) != SQLITE_DONE {
            throw SQLiteError.step(message: "Could not update row")
        }
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
