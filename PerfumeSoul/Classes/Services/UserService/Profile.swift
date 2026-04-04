//
//  Profile.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//


struct Profile: Equatable {
    let name: String
    let birthDate: String
    let birthTime: String
    let birthPlace: String
}

extension Profile: DatabaseStorable {
    init?(storableModel: CDProfile) {
        self.name = storableModel.name ?? ""
        self.birthDate = storableModel.birthDate ?? ""
        self.birthTime = storableModel.birthTime ?? ""
        self.birthPlace = storableModel.birthPlace ?? ""
    }
}

extension CDProfile: CDModel {
    func update(by model: Profile) {
        self.name = model.name
        self.birthDate = model.birthDate
        self.birthTime = model.birthTime
        self.birthPlace = model.birthPlace
    }
}

