//
//  SurveyManager.swift
//  Cozie
//
//  Created by Alexandr Chmal on 25.05.23.
//

import Foundation


class SurveyManager {
    func update(surveyListData: Data, persistenceController: PersistenceController, selected: Bool, completion: ((Bool)->())? ) {
        do {
            let surveyModel = try JSONDecoder().decode(WatchSurvey.self, from: surveyListData)
            // set first question ID
            surveyModel.firstQuestionID = surveyModel.survey.first?.questionID
            Task {
                try await persistenceController.container.performBackgroundTask({ context in
                    context.automaticallyMergesChangesFromParent = true
                    // remove previouse saved external
                    let request = WatchSurveyData.fetchRequest()
                    if !selected {
                        request.predicate = NSPredicate(format: "external == %d", true)
                    }
                    
                    let surveysList = try context.fetch(request)
                    
                    surveysList.forEach { modle in
                        // reset previouse selected
                        if selected {
                            if modle.selected {
                                modle.selected = false
                            }
                            // remove all internal
                            if !modle.external {
                                context.delete(modle)
                            }
                        } else {
                            context.delete(modle)
                        }
                    }
                    
                    // Save new survey to core data
                    let watchSurvey = WatchSurveyData(context: context)
                    watchSurvey.surveyID = surveyModel.surveyID
                    watchSurvey.surveyName = surveyModel.surveyName
                    watchSurvey.firstQuestionID = surveyModel.firstQuestionID
                    
                    if selected  {
                        watchSurvey.selected = selected
                    } else {
                        watchSurvey.external = true
                    }
                    
                    surveyModel.survey.enumerated()
                        .forEach{ (index, survay) in
                            let surveyData = SurveyData(context: context)
                            surveyData.watchSurvey = watchSurvey
                            surveyData.question = survay.question
                            surveyData.questionID = survay.questionID
                            surveyData.index = Int16(index)
                            survay.responseOptions.enumerated().forEach { (index, respObj) in
                                let responseOptionData = ResponseOptionData(context: context)
                                responseOptionData.survay = surveyData
                                responseOptionData.index = Int16(index)
                                responseOptionData.text = respObj.text
                                responseOptionData.nextQuestionID = respObj.nextQuestionID
                                responseOptionData.icon = respObj.icon
                                responseOptionData.useSfSymbols = respObj.useSfSymbols
                                responseOptionData.sfSymbolsColor = respObj.sfSymbolsColor
                            }
                        }
                    
                    try context.save()
                    completion?(true)
                })
            }
        } catch let error {
            debugPrint(error.localizedDescription)
            completion?(false)
        }
    }
}
