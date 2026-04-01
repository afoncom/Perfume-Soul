//
//  DatabaseStorable.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import CoreData

protocol DatabaseStorable: Equatable, Sendable {
    associatedtype StoringModel: CDModel where StoringModel.DataModel == Self

    init?(storableModel: StoringModel)
}

protocol CDModel: NSManagedObject {
    associatedtype DataModel: DatabaseStorable

    func update(by model: DataModel)
}

extension CDModel {
    init?(with context: NSManagedObjectContext?, model: DataModel) {
        guard let context = context else { return nil }
        self.init(context: context)
        update(by: model)
    }
}
