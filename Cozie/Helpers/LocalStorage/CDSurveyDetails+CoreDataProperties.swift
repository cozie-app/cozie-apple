//
//  CDSurveyDetails+CoreDataProperties.swift
//  
//
//  Created by Square Infosoft on 06/01/22.
//
//

import Foundation
import CoreData


extension CDSurveyDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSurveyDetails> {
        return NSFetchRequest<CDSurveyDetails>(entityName: "CDSurveyDetails")
    }

    @NSManaged public var voteLog: Int64
    @NSManaged public var locationTimestamp: Date?
    @NSManaged public var startTimestamp: Date?
    @NSManaged public var endTimestamp: Date?
    @NSManaged public var participantID: String?
    @NSManaged public var experimentID: String?
    @NSManaged public var deviceUUID: String?
    @NSManaged public var latitude: Int64
    @NSManaged public var longitude: Int64
    @NSManaged public var body_mass: Int64
    @NSManaged public var heartRate: Int64
    @NSManaged public var isSync: Bool
    @NSManaged public var toQuestionAnswer: NSSet?

}

// MARK: Generated accessors for toQuestionAnswer
extension CDSurveyDetails {

    @objc(addToQuestionAnswerObject:)
    @NSManaged public func addToToQuestionAnswer(_ value: CDQuestionAnswer)

    @objc(removeToQuestionAnswerObject:)
    @NSManaged public func removeFromToQuestionAnswer(_ value: CDQuestionAnswer)

    @objc(addToQuestionAnswer:)
    @NSManaged public func addToToQuestionAnswer(_ values: NSSet)

    @objc(removeToQuestionAnswer:)
    @NSManaged public func removeFromToQuestionAnswer(_ values: NSSet)

}
