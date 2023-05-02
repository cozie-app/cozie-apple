//
//  ResponseOptionData+CoreDataProperties.swift
//  Cozie
//
//  Created by Alexandr Chmal on 24.04.23.
//
//

import Foundation
import CoreData


extension ResponseOptionData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ResponseOptionData> {
        return NSFetchRequest<ResponseOptionData>(entityName: "ResponseOptionData")
    }

    @NSManaged public var icon: String?
    @NSManaged public var nextQuestionID: String?
    @NSManaged public var sfSymbolsColor: String?
    @NSManaged public var text: String?
    @NSManaged public var useSfSymbols: Bool
    @NSManaged public var index: Int16
    @NSManaged public var survay: SurveyData?

}

extension ResponseOptionData : Identifiable {
    func toModel() -> ResponseOption {
        let responseOption = ResponseOption(text: self.text ?? "", icon: self.icon ?? "", useSfSymbols: self.useSfSymbols, sfSymbolsColor: self.sfSymbolsColor ?? "", nextQuestionID: self.nextQuestionID ?? "")
        return responseOption
    }
}
