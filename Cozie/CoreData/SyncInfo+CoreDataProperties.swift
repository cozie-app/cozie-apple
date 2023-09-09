//
//  SyncInfo+CoreDataProperties.swift
//  Cozie
//
//  Created by Alexandr Chmal on 04.04.23.
//
//

import Foundation
import CoreData


extension SyncInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SyncInfo> {
        let request = NSFetchRequest<SyncInfo>(entityName: "SyncInfo")
        request.fetchLimit = 1
        return request
    }

    @NSManaged public var date: String?
    @NSManaged public var invalidCount: String?
    @NSManaged public var validCount: String?
    @NSManaged public var user: User?

}

extension SyncInfo : Identifiable {

}
