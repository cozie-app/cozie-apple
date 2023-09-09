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
    let surveyManager = SurveyManager()
    
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
                    self.surveyManager.update(surveyListData: surveyListData, persistenceController: self.persistenceController, selected: true, completion: completion)
                case .failure(let error):
                    completion?(false)
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Notification response
    func sendResponse(action: String,
                      userInteractor: UserInteractor = UserInteractor(),
                      backendInteractor: BackendInteractor = BackendInteractor(),
                      loggerInteractor: LoggerInteractor = LoggerInteractor.shared,
                      completion:((_ success: Bool)->())?) {
        guard let user = userInteractor.currentUser, let backend = backendInteractor.currentBackendSettings else {
            completion?(false)
            return
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: date)
        
        let tags = [WatchSurveyKeys.idOnesignal.rawValue: storage.playerID(),
                    WatchSurveyKeys.idParticipant.rawValue: user.participantID ?? "",
                    WatchSurveyKeys.idPassword.rawValue: user.passwordID ?? ""]
        
        let filds = [WatchSurveyKeys.actionButtonKey.rawValue: action,
                     WatchSurveyKeys.transmitTrigger.rawValue: WatchSurveyKeys.transmitTriggerPushValue.rawValue]
        
        let response: [String : Any] = [WatchSurveyKeys.postTime.rawValue: dateString,
                                        WatchSurveyKeys.measurement.rawValue: user.experimentID ?? "",
                                        WatchSurveyKeys.tags.rawValue: tags,
                                        WatchSurveyKeys.fields.rawValue: filds]

        do {
            let json = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            
            BaseRepository().post(url: backend.api_write_url ?? "", body: json, key: backend.api_write_key ?? "") { result in
                switch result {
                case .success(let data):
                    debugPrint(String(data: data, encoding: .utf8) ?? "somthing whent wrong!!!")
                    completion?(true)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    completion?(false)
                }
            }
            
            // log data
            let jsonToLog = try JSONSerialization.data(withJSONObject: response, options: .withoutEscapingSlashes)
            debugPrint(jsonToLog)
            loggerInteractor.logInfo(action: "", info: String(data: jsonToLog, encoding: .utf8) ?? "")
            
        } catch let error {
            completion?(false)
            debugPrint(error.localizedDescription)
        }
    }
}
