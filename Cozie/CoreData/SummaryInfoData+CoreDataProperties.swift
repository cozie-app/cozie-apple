//
//  SummaryInfoData+CoreDataProperties.swift
//  Cozie
//
//  Created by Alexandr Chmal on 10.10.24.
//
//

import Foundation
import CoreData


extension SummaryInfoData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SummaryInfoData> {
        return NSFetchRequest<SummaryInfoData>(entityName: "SummaryInfoData")
    }

    @NSManaged public var label: String?
    @NSManaged public var data: String?
    @NSManaged public var index: Int16
    @NSManaged public var user: User?

}

extension SummaryInfoData : Identifiable {

}
