//
//  User+CoreDataProperties.swift
//  Cozie
//
//  Created by Alexandr Chmal on 10.10.24.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var experimentID: String?
    @NSManaged public var participantID: String?
    @NSManaged public var passwordID: String?
    @NSManaged public var syncInfo: SyncInfo?
    @NSManaged public var summaryList: NSSet?

}

// MARK: Generated accessors for summaryList
extension User {

    @objc(addSummaryListObject:)
    @NSManaged public func addToSummaryList(_ value: SummaryInfoData)

    @objc(removeSummaryListObject:)
    @NSManaged public func removeFromSummaryList(_ value: SummaryInfoData)

    @objc(addSummaryList:)
    @NSManaged public func addToSummaryList(_ values: NSSet)

    @objc(removeSummaryList:)
    @NSManaged public func removeFromSummaryList(_ values: NSSet)

}

extension User : Identifiable {

}
