//
//  WaychSurveyData.swift
//  Cozie
//
//  Created by Alexandr Chmal on 17.04.23.
//

import Foundation

// MARK: - WatchSurvey
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
class Survey: Codable, Identifiable {
    
    var id: String {
        return questionID
    }
    
    var question, questionID: String
    var responseOptions: [ResponseOption]

    enum CodingKeys: String, CodingKey {
        case question
        case questionID = "question_id"
        case responseOptions = "response_options"
    }

    init(question: String, questionID: String, responseOptions: [ResponseOption]) {
        self.question = question
        self.questionID = questionID
        self.responseOptions = responseOptions
    }
}

// MARK: - ResponseOption
class ResponseOption: Codable, Identifiable {
    var id: String {
        return text + icon
    }
    var text, icon, iconBackgroundColor: String
    var useSfSymbols: Bool
    var sfSymbolsColor, nextQuestionID: String

    enum CodingKeys: String, CodingKey {
        case text, icon
        case iconBackgroundColor = "icon_background_color"
        case useSfSymbols = "use_sf_symbols"
        case sfSymbolsColor = "sf_symbols_color"
        case nextQuestionID = "next_question_id"
    }

    init(text: String, icon: String, iconBackgroundColor:String, useSfSymbols: Bool, sfSymbolsColor: String, nextQuestionID: String) {
        self.text = text
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.useSfSymbols = useSfSymbols
        self.sfSymbolsColor = sfSymbolsColor
        self.nextQuestionID = nextQuestionID
    }
}

