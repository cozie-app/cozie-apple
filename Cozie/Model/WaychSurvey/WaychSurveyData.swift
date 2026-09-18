//
//  WaychSurveyData.swift
//  Cozie
//
//  Created by Alexandr Chmal on 17.04.23.
//

import Foundation

// MARK: - WatchSurvey
// TODO: - Unit Tests
class WatchSurveyModelController: Codable {
    var surveyName, surveyID: String
    var firstQuestionID: String? = nil
    var survey: [Survey]

    enum CodingKeys: String, CodingKey {
        case surveyName = "survey_name"
        case surveyID = "survey_id"
        case survey
        case firstQuestionID
    }

    init(surveyName: String, surveyID: String, survey: [Survey]) {
        self.surveyName = surveyName
        self.surveyID = surveyID
        self.survey = survey
    }
}

// MARK: - Survey
// TODO: - Unit Tests
enum SurveyQuestionType: String, Codable {
    case singleSelect = "single_select"
    case multiSelect = "multi_select"
    case text
}

class Survey: Codable, Identifiable {
    
    var id: String {
        return questionID
    }
    
    var question, questionID: String
    var questionType: SurveyQuestionType
    var nextQuestionID: String?
    var responseOptions: [ResponseOption]

    enum CodingKeys: String, CodingKey {
        case question
        case questionID = "question_id"
        case questionType = "question_type"
        case nextQuestionID = "next_question_id"
        case responseOptions = "response_options"
    }

    init(question: String, questionID: String, questionType: SurveyQuestionType = .singleSelect, nextQuestionID: String? = nil, responseOptions: [ResponseOption]) {
        self.question = question
        self.questionID = questionID
        self.questionType = questionType
        self.nextQuestionID = nextQuestionID
        self.responseOptions = responseOptions
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        question = try values.decode(String.self, forKey: .question)
        questionID = try values.decode(String.self, forKey: .questionID)
        questionType = try values.decodeIfPresent(SurveyQuestionType.self, forKey: .questionType) ?? .singleSelect
        nextQuestionID = try values.decodeIfPresent(String.self, forKey: .nextQuestionID)
        responseOptions = try values.decode([ResponseOption].self, forKey: .responseOptions)
    }
}

// MARK: - ResponseOption
// TODO: - Unit Tests
class ResponseOption: Codable, Identifiable {
    var id: String {
        return uuid.uuidString // text + icon
    }
    let uuid = UUID()
    
    var text, icon, iconBackgroundColor: String
    var useSfSymbols: Bool
    var sfSymbolsColor, nextQuestionID: String
    var exclusive: Bool

    enum CodingKeys: String, CodingKey {
        case text, icon
        case iconBackgroundColor = "icon_background_color"
        case useSfSymbols = "use_sf_symbols"
        case sfSymbolsColor = "sf_symbols_color"
        case nextQuestionID = "next_question_id"
        case exclusive
    }

    init(text: String, icon: String, iconBackgroundColor:String, useSfSymbols: Bool, sfSymbolsColor: String, nextQuestionID: String, exclusive: Bool = false) {
        self.text = text
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.useSfSymbols = useSfSymbols
        self.sfSymbolsColor = sfSymbolsColor
        self.nextQuestionID = nextQuestionID
        self.exclusive = exclusive
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        text = try values.decode(String.self, forKey: .text)
        icon = try values.decode(String.self, forKey: .icon)
        iconBackgroundColor = try values.decode(String.self, forKey: .iconBackgroundColor)
        useSfSymbols = try values.decode(Bool.self, forKey: .useSfSymbols)
        sfSymbolsColor = try values.decode(String.self, forKey: .sfSymbolsColor)
        nextQuestionID = try values.decodeIfPresent(String.self, forKey: .nextQuestionID) ?? ""
        exclusive = try values.decodeIfPresent(Bool.self, forKey: .exclusive) ?? false
    }
}
