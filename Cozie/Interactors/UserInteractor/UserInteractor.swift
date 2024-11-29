//
//  UserInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 03.04.23.
//

import Foundation
import CoreData

class UserInteractor {
    // TO DO: Dependency Inversion + Test coverage
    let persistenceController = PersistenceController.shared
    
    // TO DO: async/await
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
            user.participantID = Defaults.generateParticipantID()
            user.experimentID = Defaults.experimentID
            user.passwordID = Defaults.generatePasswordID()
            try? persistenceController.container.viewContext.save()
        }
    }
    
    // 
    public func prepareUser(participantID: String?, experimentID: String?, password: String? = "1G8yOhPvMZ6m") {
        if let userList = try? persistenceController.container.viewContext.fetch(User.fetchRequest()), let user = userList.first {
            if let participantID {
                user.participantID = participantID
            }
            if let experimentID {
                user.experimentID = experimentID
            }
            if let password {
                user.passwordID = password
            }
            try? persistenceController.container.viewContext.save()
        } else {
            let user = User(context: persistenceController.container.viewContext)
            user.participantID = participantID ??  Defaults.generateParticipantID()
            user.experimentID = experimentID ?? Defaults.experimentID
            user.passwordID = password ?? Defaults.generatePasswordID()
            try? persistenceController.container.viewContext.save()
        }
    }
}

extension UserInteractor: UserDataProtocol {
    var userInfo: CUserInfo? {
        guard let user = self.currentUser else {
            return nil
        }
        
        return (user.participantID ?? "", user.passwordID ?? "", user.experimentID ?? "")
    }
}
 
