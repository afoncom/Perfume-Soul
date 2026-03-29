//
//  ProfileService.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import CoreData

protocol ProfileService {
    
}

final class ProfileServiceImpl<ProfileStorage: DatabaseStorage> where ProfileStorage.DatabaseModel == Profile {
    private let profileStorage: ProfileStorage
    init(container: NSPersistentContainer) {
        self.profileStorage = DatabaseStorageImpl<Profile>(container: container)
    }
}
