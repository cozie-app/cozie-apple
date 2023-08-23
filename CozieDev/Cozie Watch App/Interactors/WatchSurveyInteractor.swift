//
//  WatchSurveyInteractor.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import Foundation
import CoreLocation

typealias SelectedSurveyInfo = (sID: String, optin: ResponseOption)
typealias SelectedSurveyTime = (startTime: Date, locationTime: Date?)

class SurveyHistory: Codable {
    let id: String
    let jsonData: Data
    var synced: Bool = false
    var userInfo: String
    
    init(id: String, jsonData: Data, synced: Bool, userInfo: String) {
        self.jsonData = jsonData
        self.synced = synced
        self.id = id
        self.userInfo = userInfo
    }
}

class WatchSurveyInteractor {
    let healthInteractor: HealthKitInteractor = HealthKitInteractor(storage: StorageManager.shared, userData: StorageManager.shared, backendData: StorageManager.shared, loger: StorageManager.shared, dataPrefix: "ws")

    func sendSurveyData(watchSurvey: WatchSurvey?,
                        selectedOptions:[SelectedSurveyInfo],
                        location: CLLocation?,
                        time: SelectedSurveyTime,
                        storage: StorageManager = StorageManager.shared,
                        logsComplition:(()->())? = nil, completion:((_ success: Bool, _ error: Error?)->())?) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: date)
        
        let tags = [WatchSurveyKeys.idOnesignal.rawValue: storage.userOneSignalID(),
                    WatchSurveyKeys.idParticipant.rawValue: storage.userID(),
                    WatchSurveyKeys.idPassword.rawValue: storage.paswordID()]
        
        var fields: [String : Any] = [WatchSurveyKeys.wsSurveyCount.rawValue: storage.surveyCount(),
                                      WatchSurveyKeys.wsTimestampStart.rawValue: dateFormatter.string(from: time.startTime),
                                      WatchSurveyKeys.wsTimestampLocation.rawValue: time.locationTime == nil ? "" : dateFormatter.string(from: time.locationTime!),
                                      WatchSurveyKeys.wsLongitude.rawValue: location?.coordinate.longitude ?? 0.0,
                                      WatchSurveyKeys.wsLatitude.rawValue: location?.coordinate.latitude ?? 0.0,
                                      WatchSurveyKeys.wsAltitude.rawValue: location?.altitude ?? 0.0,
                                      WatchSurveyKeys.wsLocationFloor.rawValue: 0.0,
                                      WatchSurveyKeys.wsLocationAccuracyHorizontal.rawValue: location?.horizontalAccuracy ?? 0.0,
                                      WatchSurveyKeys.wsLocationAccuracyVertical.rawValue: location?.verticalAccuracy ?? 0.0,
                                      WatchSurveyKeys.wsLocationAcquisitionMethod.rawValue: "GPS",
                                      WatchSurveyKeys.wsLocationSourceDevice.rawValue: "Apple Watch",
                                      WatchSurveyKeys.transmitTrigger.rawValue: "watch_survey",
                                      WatchSurveyKeys.wssTitle.rawValue: watchSurvey?.surveyName ?? ""]
        
        for selected in selectedOptions {
            if selected.sID.isEmpty {
                continue
            }
            fields[selected.sID] = selected.optin.text
        }
        
        let survey: [String : Any] = [WatchSurveyKeys.postTime.rawValue: dateString,
                                      WatchSurveyKeys.measurement.rawValue: storage.expirimentID(),
                                      WatchSurveyKeys.tags.rawValue: tags,
                                      WatchSurveyKeys.fields.rawValue: fields]
        
        do {
            let json = try JSONSerialization.data(withJSONObject: survey, options: .prettyPrinted)
            let api = storage.watchSurveyAPI()
            
            let jsonToLog = try JSONSerialization.data(withJSONObject: survey, options: .withoutEscapingSlashes)
            debugPrint(jsonToLog)
            storage.seveLogs(logs: String(data: jsonToLog, encoding: .utf8) ?? "")
            logsComplition?()
            
            BaseRepository().post(url: api.url, body: json, key: api.key) { [weak self] result in
                switch result {
                case .success(let data):
                    debugPrint(String(data: data, encoding: .utf8) ?? "somthing whent wrong!!!")
                    //completion?(true, nil)
                    self?.healthInteractor.sendData(trigger: CommunicationKeys.syncWatchSurveyTrigger.rawValue, timeout: 0) { succces in
                        completion?(true, nil)
                    }
                case .failure(let error):
                    self?.saveNotSyncedSurvey(jsonData: json, userInfo: storage.userID() + storage.expirimentID())
                    debugPrint(error.localizedDescription)
                    completion?(false, error)
                }
            }
            
            // save logs
//            DispatchQueue.global().async { [weak self] in
//                do {
//                    let jsonToLog = try JSONSerialization.data(withJSONObject: survey, options: .withoutEscapingSlashes)
//                    debugPrint(jsonToLog)
//                    storage.seveLogs(logs: String(data: jsonToLog, encoding: .utf8) ?? "")
//                    logsComplition?()
//                } catch let error {
//                    debugPrint(error.localizedDescription)
//                    self?.testLog(trigger: CommunicationKeys.syncWatchSurveyTrigger.rawValue, details: "Failed to encoding and seve log for Survey data. Error details: \(error.localizedDescription)")
//                    logsComplition?()
//                }
//            }
        } catch let error {
//            self.testLog(trigger: CommunicationKeys.syncWatchSurveyTrigger.rawValue, details: "Failed to encoding and seve log for Survey data. Error details: \(error.localizedDescription)")
            logsComplition?()
            completion?(false, error)
            debugPrint(error.localizedDescription)
        }
    }
    
    func pushSurveyHistoryData(watchSurvey: SurveyHistory, storage: StorageManager = StorageManager.shared, completion:((_ success: Bool)->())?) {
        let api = storage.watchSurveyAPI()
        BaseRepository().post(url: api.url, body: watchSurvey.jsonData, key: api.key) { result in
            switch result {
            case .success(let data):
                debugPrint(String(data: data, encoding: .utf8) ?? "somthing whent wrong!!!")
                completion?(true)
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completion?(false)
            }
        }
    }
    
    // MARK: Save not synced Survey
    func saveNotSyncedSurvey(jsonData: Data, userInfo: String, storage: StorageManager = StorageManager.shared) {
        let history = SurveyHistory(id: UUID().uuidString, jsonData: jsonData, synced: false, userInfo: userInfo)
        storage.seveNotSyncedSurvey(history: history)
    }
    
    // MARK: Notification responce
    func sendResponce(action: String, storage: StorageManager = StorageManager.shared, completion:((_ success: Bool)->())?) {
        
        let tags = [WatchSurveyKeys.idOnesignal.rawValue: storage.userOneSignalID(),
                    WatchSurveyKeys.idParticipant.rawValue: storage.userID(),
                    WatchSurveyKeys.idPassword.rawValue: storage.paswordID()]
        
        let filds = [WatchSurveyKeys.actionButtonKey.rawValue: action,
                     WatchSurveyKeys.transmitTrigger.rawValue: WatchSurveyKeys.transmitTriggerPushValue.rawValue]
        
        let responce: [String : Any] = [WatchSurveyKeys.postTime.rawValue: formattedDate(),
                                        WatchSurveyKeys.measurement.rawValue: storage.expirimentID(),
                                        WatchSurveyKeys.tags.rawValue: tags,
                                        WatchSurveyKeys.fields.rawValue: filds]
        
        let api = storage.watchSurveyAPI()
        do {
            let json = try JSONSerialization.data(withJSONObject: responce, options: .prettyPrinted)
            
            BaseRepository().post(url: api.url, body: json, key: api.key) { result in
                switch result {
                case .success(let data):
                    debugPrint(String(data: data, encoding: .utf8) ?? "somthing whent wrong!!!")
                    completion?(true)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    completion?(false)
                }
            }
            
        } catch let error {
            completion?(false)
            debugPrint(error.localizedDescription)
        }
        
        // save logs
        DispatchQueue.global().async { /*[weak self] in*/
            do {
                let jsonToLog = try JSONSerialization.data(withJSONObject: responce, options: .withoutEscapingSlashes)
                debugPrint(jsonToLog)
                storage.seveLogs(logs: String(data: jsonToLog, encoding: .utf8) ?? "")
            } catch let error {
                debugPrint(error.localizedDescription)
//                self?.testLog(trigger: CommunicationKeys.syncWatchSurveyTrigger.rawValue, details: "Failed to encoding and seve log for Survey data. Error details: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Helper (private)
    
    private func formattedDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from: date)
    }
    
    // log test
//    private func testLog(trigger: String, details: String, state: String = "error") {
//        
//        let str =
//        """
//        {
//        "trigger": "\(trigger)",
//        "si_watch_survey_state": "\(state)",
//        "si_watch_survey_details": "\(details)"
//        }
//        """
//        StorageManager.shared.seveLogs(logs: str)
//    }
}
