//
//  SurveyData+CoreDataProperties.swift
//  Cozie
//
//  Created by Alexandr Chmal on 24.04.23.
//
//

import Foundation
import CoreData


extension SurveyData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SurveyData> {
        return NSFetchRequest<SurveyData>(entityName: "SurveyData")
    }

    @NSManaged public var question: String?
    @NSManaged public var questionID: String?
    @NSManaged public var index: Int16
    @NSManaged public var responseOption: NSSet?
    @NSManaged public var watchSurvey: WatchSurveyData?

}

// MARK: Generated accessors for responseOption
extension SurveyData {

    @objc(addResponseOptionObject:)
    @NSManaged public func addToResponseOption(_ value: ResponseOptionData)

    @objc(removeResponseOptionObject:)
    @NSManaged public func removeFromResponseOption(_ value: ResponseOptionData)

    @objc(addResponseOption:)
    @NSManaged public func addToResponseOption(_ values: NSSet)

    @objc(removeResponseOption:)
    @NSManaged public func removeFromResponseOption(_ values: NSSet)

}

extension SurveyData : Identifiable {
    func toModel() -> Survey {
        let responseOptionList = self.responseOption?
            .compactMap { $0 as? ResponseOptionData }
            .sorted(by: { $0.index < $1.index })
            .map({ responseOptionData in
                return responseOptionData.toModel()
            })
               
        let survey = Survey(question: self.question ?? "", questionID: self.questionID ?? "", responseOptions: responseOptionList ?? [])
        return survey
    }
}
