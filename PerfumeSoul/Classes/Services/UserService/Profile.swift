//
//  Profile.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//


struct Profile: Equatable {
    let surname: String
    let name: String
}

extension Profile: DatabaseStorable {
    init?(storableModel: CDProfile) {
        self.surname = storableModel.surname ?? ""
        self.name = storableModel.name ?? ""
    }
}

extension CDProfile: CDModel {
    func update(by model: Profile) {
        self.surname = model.surname
        self.name = model.name
    }
}

