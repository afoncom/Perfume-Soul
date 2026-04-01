//
//  ProfileService.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import CoreData

protocol ProfileService {
    func addProfile(model: Profile)
    func fechProfile() async -> [Profile]
}

final class ProfileServiceImpl<ProfileStorage: DatabaseStorage> where ProfileStorage.DatabaseModel == Profile {
    private let profileStorage: ProfileStorage

    init(profileStorage: ProfileStorage) {
        self.profileStorage = profileStorage
    }
}

extension ProfileServiceImpl where ProfileStorage == DatabaseStorageImpl<Profile> {
    convenience init(container: NSPersistentContainer) {
        self.init(profileStorage: DatabaseStorageImpl<Profile>(container: container))
    }
}

extension ProfileServiceImpl: ProfileService {
    func addProfile(model: Profile) {
        profileStorage.saveModel(model: model)
    }
    
    func fechProfile() async -> [Profile] {
        await profileStorage.fechAll()
    }
}
