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
        container.loadPersistentStores { _, error in
            guard let error else { return }
            print(error.localizedDescription)
        }
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
