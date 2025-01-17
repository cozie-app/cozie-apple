//
//  WatchSurveyInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 26.04.23.
//

import Foundation
import CoreData

protocol SurveyManagerProtocol {
    func update(surveyListData: Data, storage: DataBaseStorageProtocol, selected: Bool, completion: ((_ title: String?, _ error: Error?)->())? )
    func asyncUpdate(surveyListData: Data, storage: DataBaseStorageProtocol, selected: Bool) async throws
}

protocol SurveyStorageProtocol {
    func selectedWSInfoLink() -> String
    func playerID() -> String
}

protocol WatchSurveyInteractorProtocol {
    func loadSelectedWatchSurveyJSON(completion: ((_ title: String?, _ error: Error?) -> ())?)
}

final class WatchSurveyInteractor: WatchSurveyInteractorProtocol {
    let persistenceController: PersistenceController
    let baseRepo: BaseRepository
    let storage: SurveyStorageProtocol
    let surveyManager: SurveyManagerProtocol
    
    init() {
        self.persistenceController = PersistenceController.shared
        self.baseRepo = BaseRepository()
        self.storage = CozieStorage.shared
        self.surveyManager = SurveyManager()
    }
    
    init(surveyManager: SurveyManagerProtocol, storage: SurveyStorageProtocol) {
        self.surveyManager = surveyManager
        self.storage = storage
        
        self.persistenceController = PersistenceController.shared
        self.baseRepo = BaseRepository()
    }
    
    deinit { debugPrint("\(WatchSurveyInteractor.self) - deinit") }
    
    // MARK: - Load WatchSurvey JSON
    // TODO: - Unit Tests
    func loadSelectedWatchSurveyJSON(completion: ((_ title: String?, _ error: Error?) -> ())?) {
        let selectedLink = storage.selectedWSInfoLink()
        if !selectedLink.isEmpty {
            baseRepo.getFileContent(url: selectedLink, parameters: nil) { [weak self] result in
                
                guard let self = self else {
                    completion?(nil ,WatchConnectivityManagerPhone.WatchConnectivityManagerError.surveyJSONError)
                    return
                }
                
                switch result {
                case .success(let surveyListData):
                    self.surveyManager.update(surveyListData: surveyListData, storage: self.persistenceController, selected: true, completion: completion)
                case .failure(let error):
                    completion?(nil, WatchConnectivityManagerPhone.WatchConnectivityManagerError.surveyJSONError)
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Notification response
    // TODO: - Unit Tests
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
        dateFormatter.dateFormat = DateFormat.defaultFormat
        let dateString = dateFormatter.string(from: date)
        
        let tags = [WatchSurveyKeys.idOnesignal.rawValue: storage.playerID(),
                    WatchSurveyKeys.idParticipant.rawValue: user.participantID ?? "",
                    WatchSurveyKeys.idPassword.rawValue: user.passwordID ?? ""]
        
        let fields = [WatchSurveyKeys.actionButtonKey.rawValue: action,
                     WatchSurveyKeys.transmitTrigger.rawValue: WatchSurveyKeys.transmitTriggerPushValue.rawValue]

        let response: [String : Any] = [WatchSurveyKeys.postTime.rawValue: dateString,
                                        WatchSurveyKeys.measurement.rawValue: user.experimentID ?? "",
                                        WatchSurveyKeys.tags.rawValue: tags,
                                        WatchSurveyKeys.fields.rawValue: fields]
        do {
            let json = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            
            baseRepo.post(url: backend.api_write_url ?? "", body: json, key: backend.api_write_key ?? "") { result in
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
