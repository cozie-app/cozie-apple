//
//  UserInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 03.04.23.
//

import Foundation
import CoreData

class UserInteractor {
    let persistenceController = PersistenceController.shared

    var currentUser: User? {
        guard let userList = try? persistenceController.container.viewContext.fetch(User.fetchRequest()),
                let user = userList.first else { return nil }
        
        return user
    }
    
    public func prepareUser(password: String = "1G8yOhPvMZ6m") {
        if let userList = try? persistenceController.container.viewContext.fetch(User.fetchRequest()), let _ = userList.first {
           debugPrint(userList)
        } else {
            let user = User(context: persistenceController.container.viewContext)
            user.participantID = "dev01"
            user.experimentID = "dev"
            user.passwordID = password
            try? persistenceController.container.viewContext.save()
        }
    }
    
}
 
