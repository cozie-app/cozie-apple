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
        case notsynced, synced, /*timeout,*/ sendData, finished
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
    
    let categoryId = "cozie_push_action_category"
    let logFileName = "logs.txt"
    
    // MARK: Public
    var isFirstQuestion: Bool {
        return self.selectedOptions.count == 0
    }
    
    // MARK: Published
    @Published var questionsList: [ResponseOption]  = []
    @Published var questionsTitle: String = ""
    @Published var state: CozieAppState = .notsynced
    @Published var sendSurveyProgress: Bool = false
    var upadateLocationInProgress = false
    
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
            syncSurvey()
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
        
        watchSurveyInteractor.sendSurveyData(watchSurvey: watchSurvey, selectedOptions: selectedOptions, location: locationManager.currentLocation, time: (startTime, locationManager.lastUpdateDate), logsComplition: { /*[weak self]  in*/
            ///
        }, completion: { [weak self] success, error in
            if success {
                DispatchQueue.main.async {
                    self?.sendSurveyProgress = false
                    self?.state = .finished
                }
            } else {
                DispatchQueue.main.async {
                    self?.sendSurveyProgress = false
                    self?.state = .finished
                }
                if !success {
//                    self?.testLog(trigger: CommunicationKeys.syncWatchSurveyTrigger.rawValue, details: "Failed to send Survey data. Error details: \(error?.localizedDescription ?? "no details")")
                }
            }
        })
        
        storage.saveLastSurveySend()
        storage.updateSurveyCount()
        locationManager.completion = nil
    }
    
    func syncSurvey() {
        let list = storage.allNotSyncedSurveyList()
        if !list.isEmpty {
            let groupe = DispatchGroup()
            for data in list {
                groupe.enter()
                watchSurveyInteractor.pushSurveyHistoryData(watchSurvey: data) { success in
                    data.synced = success
                    groupe.leave()
                }
            }
            groupe.notify(queue: DispatchQueue.main) { [weak self] in
                let notSynced = list.filter({ $0.synced == false})
                self?.storage.updateNotSyncedSurvey(list: notSynced)
            }
        }
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
            state = .sendData
        }
    }
    
    func sendWatchSurvey() {
        sendSurveyProgress = true
        sendSurvey()
    }
    
    func backAction() {
        if !selectedOptions.isEmpty {
            
            if let previousSelected = selectedOptions.last , let prevSuvey = watchSurvey?.survey.first(where: { $0.questionID == previousSelected.sID }) {
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
    }
    
    func restart() {
        selectedOptions.removeAll()
        prepareWatchSurvey()
    }
    
    func updateLocation() {
        upadateLocationInProgress = true
        if let manager = locationManager.locationManager,
           manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
            locationManager.completion = { [weak self] in
                self?.upadateLocationInProgress = false
            }
        }
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
//        storage.seveLogs(logs: str)
//    }
}

extension WatchSurveyViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationState:\n \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        // transver file status
        if let transverFileStatus = message[CommunicationKeys.transverFileStatusKey.rawValue] as? Int {
            if transverFileStatus == FileTransferStatus.finished.rawValue {
                storage.clearLogs()
            }
            replyHandler([CommunicationKeys.resived.rawValue: true])
            return
        }
        
        replyHandler([CommunicationKeys.resived.rawValue: true])
        
        if let json = message[CommunicationKeys.jsonKey.rawValue] as? Data {
            storage.saveWatchSurveyJSON(data: json)
        }
        
        if let userID = message[CommunicationKeys.userIDKey.rawValue] as? String {
            // reset survey count
            if storage.userID() != userID {
                storage.resetSurveyCount()
                storage.clearLogs()
            }
            storage.saveUserID(userID: userID)
        }
        
        if let expID = message[CommunicationKeys.expIDKey.rawValue] as? String {
            // reset survey count
            if storage.expirimentID() != expID {
                storage.resetSurveyCount()
                storage.clearLogs()
            }
            storage.saveExpirimentID(expID: expID)
        }
        
        if let userOneSignalID = message[CommunicationKeys.userOneSignalIDKey.rawValue] as? String {
            storage.saveUserOneSignalID(userID: userOneSignalID)
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
        
        transferLoggFile()
        
        DispatchQueue.main.async { [weak self] in
            self?.prepareWatchSurvey()
        }
    }
    
    func transferLoggFile() {
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let filePathURL = filePath, FileManager.default.fileExists(atPath: filePathURL.appendingPathComponent(StorageManager.logFileName).relativePath) else {
            return
        }
        //debugPrint(try? String(contentsOf: filePathURL, encoding: .utf8))
        session.transferFile(filePathURL.appendingPathComponent(StorageManager.logFileName), metadata: nil)
    }
}
