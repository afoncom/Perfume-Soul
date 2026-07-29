//
//  CoreDataManager.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import CoreData

protocol CoreDataManager {
    func initContainer()
    func saveContext()
    var container: NSPersistentContainer { get }
}

final class CoreDataManagerImpl {
    let container = NSPersistentContainer(name: "PerfumeSoul")
}

extension CoreDataManagerImpl: CoreDataManager {
    func initContainer() {
        configureMigration()
        loadPersistentStores(allowingStoreRecreation: true)
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

extension CoreDataManagerImpl {
    private func configureMigration() {
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.shouldMigrateStoreAutomatically = true
        storeDescription?.shouldInferMappingModelAutomatically = true
    }

    private func loadPersistentStores(allowingStoreRecreation: Bool) {
        container.loadPersistentStores { _, error in
            guard let error else {
                return
            }

            guard allowingStoreRecreation else {
                fatalError("Failed to reload persistent store: \(String(describing: error))")
            }

            self.recreatePersistentStore(after: error)
        }
    }

    private func recreatePersistentStore(after loadError: any Error) {
        print("Failed to load persistent store: \(String(describing: loadError))")

        guard canRecreatePersistentStore(after: loadError) else {
            fatalError("Failed to load persistent store: \(String(describing: loadError))")
        }

        guard
            let storeDescription = container.persistentStoreDescriptions.first,
            let storeURL = storeDescription.url
        else {
            fatalError("Failed to find persistent store URL: \(String(describing: loadError))")
        }

        do {
            try quarantinePersistentStore(at: storeURL)
            try container.persistentStoreCoordinator.destroyPersistentStore(
                at: storeURL,
                ofType: storeDescription.type,
                options: storeDescription.options
            )
        } catch let destroyError {
            fatalError(
                "Failed to recreate persistent store. "
                + "Load error: \(String(describing: loadError)). "
                + "Destroy error: \(String(describing: destroyError))"
            )
        }

        loadPersistentStores(allowingStoreRecreation: false)
    }

    func canRecreatePersistentStore(after error: any Error) -> Bool {
        let nsError = error as NSError

        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? any Error {
            return canRecreatePersistentStore(after: underlyingError)
        }

        if
            nsError.domain == NSCocoaErrorDomain,
            [
                NSPersistentStoreIncompatibleVersionHashError,
                NSFileReadCorruptFileError
            ].contains(nsError.code)
        {
            return true
        }

        if nsError.domain == NSSQLiteErrorDomain, [11, 26].contains(nsError.code) {
            return true
        }

        return false
    }

    func quarantinePersistentStore(at storeURL: URL) throws {
        let fileManager = FileManager.default

        try persistentStoreFileURLs(for: storeURL).forEach { fileURL in
            let quarantineURL = fileURL.appendingPathExtension("quarantine")

            if fileManager.fileExists(atPath: quarantineURL.path) {
                try fileManager.removeItem(at: quarantineURL)
            }

            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.copyItem(at: fileURL, to: quarantineURL)
            }
        }
    }

    func persistentStoreFileURLs(for storeURL: URL) -> [URL] {
        [
            storeURL,
            URL(fileURLWithPath: storeURL.path + "-wal"),
            URL(fileURLWithPath: storeURL.path + "-shm")
        ]
    }
}
