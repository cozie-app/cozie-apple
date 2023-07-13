//
//  WatchSurveyViewModel.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 18.04.23.
//

import SwiftUI
import WatchConnectivity

class WatchSurveyViewModel: NSObject, ObservableObject {
    
    enum CozieAppState: Int {
        case notsynced, synced, /*timeout,*/ finished
    }
    
    // MARK: Private
    private let session = WCSession.default
    private let storage = StorageManager.shared
    private let locationManager = LocationManager()
    private let watchSurveyInteractor = WatchSurveyInteractor()
    
    private var selectedOptions: [(sID: String, optin: ResponseOption)] = []
    private var currentSurvey: Survey?
    private var watchSurvey: WatchSurvey? = nil
    private var startTime = Date()
    
    // MARK: Published
    @Published var questionsList: [ResponseOption]  = []
    @Published var questionsTitle: String = ""
    @Published var state: CozieAppState = .notsynced
    
    // MARK: Private func
    private func loadWatchSurvey(data: Data) {
        do {
            let wSurvey = try JSONDecoder().decode(WatchSurvey.self, from: data)
            watchSurvey = wSurvey
            if let question = wSurvey.survey.first(where: { $0.questionID == (wSurvey.firstQuestionID ?? "failed") }) {
                questionsList = question.responseOptions
                questionsTitle = question.question
                currentSurvey = question
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func prepareWatchSurvey() {
        if !storage.dataSynced() {
            state = .notsynced
        } else {
            //            let lastUpdateInSconds = Int(Date().timeIntervalSince1970) - storage.lastSurveySendInterval()
            //            let timeInterval = storage.timeInterval()
            //            if storage.lastSurveySendInterval() > 0, timeInterval > 0, (lastUpdateInSconds - timeInterval) < 0 {
            //                state = .timeout
            //
            //            } else {
            state = .synced
            startTime = Date()
            // Uncomment to test
            //                let defaultURLJSON = Bundle.main.url(forResource: "DefaultWSJSON", withExtension: "json")
            //                if let url = defaultURLJSON {
            //                    do {
            //                        let data = try Data(contentsOf: url)
            //                        let wSurvey = try JSONDecoder().decode(WatchSurvey.self, from: data)
            //                        watchSurvey = wSurvey
            //                        questionsTitle = wSurvey.survey.first!.question
            //                        questionsList = wSurvey.survey.first!.responseOptions
            //                    } catch let error {
            //                        debugPrint(error.localizedDescription)
            //                    }
            //                }
            
            if let json = StorageManager.shared.watchatchSurveyJSON() {
                loadWatchSurvey(data: json)
            } else {
                fatalError("Incorrect State!!!")
            }
            //            }
        }
    }
    
    private func sendSurvey() {
        storage.saveLastSurveySend()
        storage.updateSurveyCount()
        watchSurveyInteractor.sendSurveyData(watchSurvey: watchSurvey, selectedOptions: selectedOptions, location: locationManager.currentLocation, time: (startTime, locationManager.lastUpdateDate)) { [weak self] in
            self?.sendLogsData()
        }
        locationManager.completion = nil
    }
    
    // MARK: Public func
    func prepare() {
        if let manager = locationManager.locationManager,
           manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else {
            locationManager.requestAuth()
        }
        
        if WCSession.isSupported(), !session.isReachable {
            session.delegate = self
            session.activate()
            prepareWatchSurvey()
        }
    }
    
    func selectOptions(option: ResponseOption) {
        
        selectedOptions.append((currentSurvey?.questionID ?? "", option))
        
        if let nextSuvey = watchSurvey?.survey.first(where: { $0.questionID == option.nextQuestionID}) {
            questionsTitle = nextSuvey.question
            questionsList = nextSuvey.responseOptions
            currentSurvey = nextSuvey
        } else {
            state = .finished
        }
    }
    
    func sendWatchSurvey() {
        if let manager = locationManager.locationManager,
           manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
            locationManager.completion = { [weak self] in
                guard let self = self else { return }
                self.sendSurvey()
            }
        } else {
            sendSurvey()
        }
    }
    
    func backAction() {
        if !selectedOptions.isEmpty {
            
            if let previousSelected = selectedOptions.last , let prevSuvey = watchSurvey?.survey.first(where: { $0.responseOptions.contains(where: { $0.id == previousSelected.optin.id })}) {
                questionsTitle = prevSuvey.question
                questionsList = prevSuvey.responseOptions
                currentSurvey = prevSuvey
            }
            
            selectedOptions.removeLast()
            state = .synced
        }
    }
    
    func resetAction() {
        backAction()
//        if !selectedOptions.isEmpty {
//            selectedOptions.removeAll()
//            if let watchSurveyObj = watchSurvey, let question = watchSurveyObj.survey.first(where: { $0.questionID == (watchSurveyObj.firstQuestionID ?? "failed") }) {
//                questionsTitle = question.question
//                questionsList = question.responseOptions
//                currentSurvey = question
//            }
//        }
    }
    
    func restart() {
        selectedOptions.removeAll()
        prepareWatchSurvey()
    }
}

// TODO: Refactor
extension WatchSurveyViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationState:\n \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        replyHandler([CommunicationKeys.resived.rawValue: true])
        
        if let json = message[CommunicationKeys.jsonKey.rawValue] as? Data {
            storage.saveWatchSurveyJSON(data: json)
        }
        
        if let userID = message[CommunicationKeys.userIDKey.rawValue] as? String {
            // reset survey count
            if storage.userID() != userID {
                storage.resetSurveyCount()
            }
            storage.saveUserID(userID: userID)
        }
        
        if let expID = message[CommunicationKeys.expIDKey.rawValue] as? String {
            // reset survey count
            if storage.expirimentID() != expID {
                storage.resetSurveyCount()
            }
            storage.saveExpirimentID(expID: expID)
        }
        
        if let password = message[CommunicationKeys.passwordIDKey.rawValue] as? String {
            storage.savePaswordID(passwordID: password)
        }
        
        if let url = message[CommunicationKeys.writeApiURL.rawValue] as? String,
           let key = message[CommunicationKeys.writeApiKey.rawValue] as? String {
            storage.saveWatchSurveyAPI(apiInfo: (url, key))
        }
        
        if let timeInterval = message[CommunicationKeys.timeInterval.rawValue] as? Int {
            storage.saveTimeInterval(interval: timeInterval)
        }
        
        sendLogsData()
        
        DispatchQueue.main.async { [weak self] in
            self?.prepareWatchSurvey()
        }
    }
    
    func sendLogsData() {
        let logs = storage.sevedLogs()
        if !logs.isEmpty {
            
            let param = [CommunicationKeys.wsLogs.rawValue: logs]
            session.sendMessage(param, replyHandler: { responce in
                debugPrint(responce)
                if let result = responce[CommunicationKeys.resived.rawValue] as? Bool, result {
                    self.storage.clearLogs()
                }
            }, errorHandler: { error in
                debugPrint(error)
            })
        }
    }
}
