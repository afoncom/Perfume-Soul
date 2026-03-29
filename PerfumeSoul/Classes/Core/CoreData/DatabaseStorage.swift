//
//  DatabaseStorage.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//
import CoreData

protocol DatabaseStorage {
    associatedtype DatabaseModel: DatabaseStorable
    func saveModel(model:  DatabaseModel)
//    func delete(model: DatabaseModel)
    func fechAll() -> [DatabaseModel]
}

final class DatabaseStorageImpl <DatabaseModel: DatabaseStorable> {
    typealias StoringModel = DatabaseModel.StoringModel     // What?
    
    private let container: NSPersistentContainer
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    private func savedContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
                context.rollback()
            }
        }
    }
}

extension DatabaseStorageImpl {
    func saveModel(model:  DatabaseModel) {
        let context = container.newBackgroundContext()
        context.perform {
            let storingModel = StoringModel(context: context)
            storingModel.update(by: model)
            self.savedContext(context: context)    //What?
        }
    }
    
//    func delete(model: DatabaseModel) {
//        
//    }
    
    func fechAll() async -> [DatabaseModel] {
        let context = container.newBackgroundContext()
        return await context.perform {
            let fetchRequest = StoringModel.fetchRequest() as? NSFetchRequest<StoringModel>
            guard let fetchRequest else { return [] }
            do {
                let storingModel = try context.fetch(fetchRequest)
                return storingModel.compactMap { DatabaseModel(storableModel: $0) }
            } catch let error {
                return []
            }
        }
    }
}
