//
//  WatchSurveyInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 26.04.23.
//

import Foundation
import CoreData

class WatchSurveyInteractor {
    let persistenceController = PersistenceController.shared
    let baseRepo = BaseRepository()
    let storage = CozieStorage.shared
    
    // MARK: - Load WatchSurvey JSON
    func loadSelectedWatchSurveyJSON(completion: ((_ success: Bool) -> ())?) {
        let selectedLink = storage.selectedWSLink()
        if !selectedLink.isEmpty {
            baseRepo.getFileContent(url: selectedLink, parameters: nil) { [weak self] result in
                
                guard let self = self else {
                    completion?(false)
                    return
                }
                
                switch result {
                case .success(let surveyListData):
                    do {
                        let surveyModel = try JSONDecoder().decode(WatchSurvey.self, from: surveyListData)
                        // set first question ID
                        surveyModel.firstQuestionID = surveyModel.survey.first?.questionID
                        try self.persistenceController.container.viewContext.performAndWait {
                            // remove previouse saved survey with same id
                            let request = WatchSurveyData.fetchRequest()
                            let surveysList = try self.persistenceController.container.viewContext.fetch(request)
                            
                            surveysList.forEach { modle in
                                // reset previouse selected
                                if modle.selected {
                                    modle.selected = false
                                }
                                // remove all internal
                                if !modle.external {
                                    self.persistenceController.container.viewContext.delete(modle)
                                }
                            }
                        }
                        
                        // Save new survey to core data
                        let watchSurvey = WatchSurveyData(context: self.persistenceController.container.viewContext)
                        watchSurvey.surveyID = surveyModel.surveyID
                        watchSurvey.surveyName = surveyModel.surveyName
                        watchSurvey.firstQuestionID = surveyModel.firstQuestionID
                        watchSurvey.selected = true
                        
                        surveyModel.survey.enumerated()
                            .forEach{ (index, survay) in
                                let surveyData = SurveyData(context: self.persistenceController.container.viewContext)
                                surveyData.watchSurvey = watchSurvey
                                surveyData.question = survay.question
                                surveyData.questionID = survay.questionID
                                surveyData.index = Int16(index)
                                survay.responseOptions.enumerated().forEach { (index, respObj) in
                                    let responseOptionData = ResponseOptionData(context: self.persistenceController.container.viewContext)
                                    responseOptionData.survay = surveyData
                                    responseOptionData.index = Int16(index)
                                    responseOptionData.text = respObj.text
                                    responseOptionData.nextQuestionID = respObj.nextQuestionID
                                    responseOptionData.icon = respObj.icon
                                    responseOptionData.useSfSymbols = respObj.useSfSymbols
                                    responseOptionData.sfSymbolsColor = respObj.sfSymbolsColor
                                }
                            }
                        
                        try self.persistenceController.container.viewContext.save()
                        completion?(true)
                    } catch let error {
                        debugPrint(error.localizedDescription)
                        completion?(false)
                    }
                case .failure(let error):
                    completion?(false)
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
}
