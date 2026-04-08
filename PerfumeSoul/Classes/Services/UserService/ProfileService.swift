//
//  ProfileService.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import CoreData

protocol ProfileService {
    func saveProfile(_ profile: Profile)
    func fetchProfile() async -> Profile?
    func deleteProfile(_ profile: Profile) async
    func deleteAllProfiles() async
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
    func saveProfile(_ profile: Profile) {
        profileStorage.saveModel(model: profile)
    }
    
    func fetchProfile() async -> Profile? {
        (await profileStorage.fechAll()).first
    }
    
    func deleteProfile(_ profile: Profile) async {
        await profileStorage.delete(model: profile)
    }

    func deleteAllProfiles() async {
        await profileStorage.deleteAll()
    }
}
