//
//  CDQuestionAnswer+CoreDataProperties.swift
//  
//
//  Created by Square Infosoft on 06/01/22.
//
//

import Foundation
import CoreData


extension CDQuestionAnswer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDQuestionAnswer> {
        return NSFetchRequest<CDQuestionAnswer>(entityName: "CDQuestionAnswer")
    }

    @NSManaged public var voteLog: Int64
    @NSManaged public var question: String?
    @NSManaged public var answer: String?
    @NSManaged public var toSurvey: CDSurveyDetails?

}
