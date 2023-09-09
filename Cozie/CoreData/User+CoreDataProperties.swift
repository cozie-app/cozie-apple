//
//  User+CoreDataProperties.swift
//  Cozie
//
//  Created by Alexandr Chmal on 04.04.23.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        let request = NSFetchRequest<User>(entityName: "User")
        request.fetchLimit = 1
        return request
    }

    @NSManaged public var experimentID: String?
    @NSManaged public var participantID: String?
    @NSManaged public var passwordID: String?
    @NSManaged public var syncInfo: SyncInfo?

}

extension User : Identifiable {

}
