//
//  WatchSurveyData+CoreDataProperties.swift
//  Cozie
//
//  Created by Alexandr Chmal on 26.04.23.
//
//

import Foundation
import CoreData


extension WatchSurveyData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchSurveyData> {
        return NSFetchRequest<WatchSurveyData>(entityName: "WatchSurveyData")
    }

    @NSManaged public var firstQuestionID: String?
    @NSManaged public var surveyID: String?
    @NSManaged public var surveyName: String?
    @NSManaged public var selected: Bool
    @NSManaged public var external: Bool
    @NSManaged public var survey: NSSet?

}

// MARK: Generated accessors for survey
extension WatchSurveyData {

    @objc(addSurveyObject:)
    @NSManaged public func addToSurvey(_ value: SurveyData)

    @objc(removeSurveyObject:)
    @NSManaged public func removeFromSurvey(_ value: SurveyData)

    @objc(addSurvey:)
    @NSManaged public func addToSurvey(_ values: NSSet)

    @objc(removeSurvey:)
    @NSManaged public func removeFromSurvey(_ values: NSSet)

}

extension WatchSurveyData : Identifiable {
    func toModel() -> WatchSurveyModelController {
        let surveyList = self.survey?
            .compactMap { $0 as? SurveyData }
            .sorted(by: { $0.index < $1.index })
            .map({ surveyData in
                return surveyData.toModel()
            })
               
        let watchSurvey = WatchSurveyModelController(surveyName: self.surveyName ?? "", surveyID: self.surveyID ?? "", survey: surveyList ?? [])
        watchSurvey.firstQuestionID = self.firstQuestionID ?? ""
        return watchSurvey
    }
}
