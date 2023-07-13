//
//  BackendInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 11.04.23.
//

import Foundation
import CoreData

class BackendInteractor {
    let persistenceController = PersistenceController.shared
    let baseRepo = BaseRepository()
    let storage = CozieStorage()
    
    var currentBackendSettings: BackendInfo? {
        guard let settingsList = try? persistenceController.container.viewContext.fetch(BackendInfo.fetchRequest()),
              let settings = settingsList.first else { return nil }
        
        return settings
    }
    
    func prepereBackendData() {
        if let settingList = try? persistenceController.container.viewContext.fetch(BackendInfo.fetchRequest()), let _ = settingList.first {
            debugPrint(settingList)
        } else {
            let backend = BackendInfo(context: persistenceController.container.viewContext)
            backend.api_read_url = "https://at6x6b7v54hmoki6dlyew72csq0ihxrn.lambda-url.ap-southeast-1.on.aws"
            backend.api_read_key = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
            backend.api_write_url = "https://43cb5nnwe3mejojyftbuaow4640nsrnd.lambda-url.ap-southeast-1.on.aws"
            backend.api_write_key = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
            backend.one_sigmnal_id = "be00093b-ed75-4c2e-81af-d6b382587283"
            backend.participant_password = "1G8yOhPvMZ6m"
            backend.watch_survey_link = "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_weather_short.txt"
            backend.phone_survey_link = "https://docs.google.com/forms/d/e/1FAIpQLSchX6cIqgx7tupV_47o5sYVs5IvEBqhwTMGuRLCjGxqbh_gTA/viewform?usp=pp_url&entry.247006640=dev&entry.932499052=dev01"
            
            // save default link
            storage.saveWSLink(link: "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_weather_short.txt")
            
            try? persistenceController.container.viewContext.save()
        }
    }
    
    // MARK: - Load WatchSurvey JSON
    func loadExternalWatchSurveyJSON(completion: ((_ success: Bool) -> ())?) {
        if let backend = currentBackendSettings {
            baseRepo.getFileContent(url: backend.watch_survey_link ?? "", parameters: nil) { [weak self] result in
                
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
                            // remove previouse saved external
                            let request = WatchSurveyData.fetchRequest()
                            request.predicate = NSPredicate(format: "external == %d", true)
                            let surveysList = try self.persistenceController.container.viewContext.fetch(request)
                            
                            surveysList.forEach { modle in
                                self.persistenceController.container.viewContext.delete(modle)
                            }
                        }
                        
                        // Save new survey to core data
                        let watchSurvey = WatchSurveyData(context: self.persistenceController.container.viewContext)
                        watchSurvey.surveyID = surveyModel.surveyID
                        watchSurvey.surveyName = surveyModel.surveyName
                        watchSurvey.firstQuestionID = surveyModel.firstQuestionID
                        watchSurvey.external = true
                        
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
