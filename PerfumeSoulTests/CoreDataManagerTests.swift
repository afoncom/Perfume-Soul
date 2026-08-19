//
//  CoreDataManagerTests.swift
//  PerfumeSoulTests
//
//  Created by Codex on 28.07.2026.
//

import Foundation
import CoreData
import XCTest
@testable import PerfumeSoul

final class CoreDataManagerTests: XCTestCase {
    func testGenericMigrationErrorWithNonCorruptionUnderlyingCannotRecreateStore() {
        let underlyingError = NSError(
            domain: NSCocoaErrorDomain,
            code: NSFileWriteOutOfSpaceError
        )
        let migrationError = NSError(
            domain: NSCocoaErrorDomain,
            code: NSMigrationError,
            userInfo: [NSUnderlyingErrorKey: underlyingError]
        )

        XCTAssertFalse(CoreDataManagerImpl().canRecreatePersistentStore(after: migrationError))
    }

    func testQuarantinePersistentStoreCopiesSQLiteSidecars() throws {
        let fileManager = FileManager.default
        let directoryURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer {
            try? fileManager.removeItem(at: directoryURL)
        }

        let storeURL = directoryURL.appendingPathComponent("PerfumeSoul.sqlite")
        let walURL = URL(fileURLWithPath: storeURL.path + "-wal")
        let shmURL = URL(fileURLWithPath: storeURL.path + "-shm")
        try Data("store".utf8).write(to: storeURL)
        try Data("wal".utf8).write(to: walURL)
        try Data("shm".utf8).write(to: shmURL)

        try CoreDataManagerImpl().quarantinePersistentStore(at: storeURL)

        XCTAssertEqual(
            try String(contentsOf: storeURL.appendingPathExtension("quarantine"), encoding: .utf8),
            "store"
        )
        XCTAssertEqual(
            try String(contentsOf: walURL.appendingPathExtension("quarantine"), encoding: .utf8),
            "wal"
        )
        XCTAssertEqual(
            try String(contentsOf: shmURL.appendingPathExtension("quarantine"), encoding: .utf8),
            "shm"
        )
    }
}
