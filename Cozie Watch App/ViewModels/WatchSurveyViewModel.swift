//
//  WatchSurveyViewModel.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 18.04.23.
//

import SwiftUI
import WatchConnectivity
import Combine
import WatchKit

class WatchSurveyViewModel: NSObject, ObservableObject {
    // Uncomment for preview tests
    /*static var test = {
        let model = WatchSurveyViewModel()
        model.questionsTitle = "Currently, the end of watch survey questions might not shown depending on the Apple Watch model and font size settings in watchOS. We would like to make the following changes"
        model.questionsList = [ResponseOption(text: "Test 1", icon: "12", iconBackgroundColor: "", useSfSymbols: true, sfSymbolsColor: "", nextQuestionID: ""),
                               ResponseOption(text: "Test 2", icon: "23", iconBackgroundColor: "", useSfSymbols: true, sfSymbolsColor: "", nextQuestionID: ""),
                               ResponseOption(text: "Test 3", icon: "34", iconBackgroundColor: "", useSfSymbols: true, sfSymbolsColor: "", nextQuestionID: ""),
                               ResponseOption(text: "Test 4", icon: "45", iconBackgroundColor: "", useSfSymbols: true, sfSymbolsColor: "", nextQuestionID: "")]
        return model
    }()*/
    
    enum CozieAppState: Int {
        case notsynced, synced, /*timeout,*/ sendData, finished
    }
    
    enum CozieCacheState: Int {
        case nottrigered, inprogress, finished
    }
    
    // MARK: Private
    private let session = WCSession.default
    private let storage = StorageManager.shared
    private let locationManager: UpdateLocationProtocol = LocationManager()
    private let watchSurveyInteractor = WatchSurveyInteractor()
    
    private var selectedOptions: [(sID: String, optin: ResponseOption)] = []
    private var currentSurvey: Survey?
    private var watchSurvey: WatchSurveyModelController? = nil
    private var startTime = Date()
    
    let categoryId = "cozie_push_action_category"
    let logFileName = "logs.txt"
    
    // MARK: Public
    var isFirstQuestion: Bool {
        return (self.selectedOption(for: currentSurvey?.questionID ?? "") == 0) || (self.selectedOptions.count == 0)
    }
    
    // MARK: Published
    @Published var questionsList: [ResponseOption]  = []
    @Published var questionsTitle: String = ""
    @Published var state: CozieAppState = .notsynced
    @Published var sendSurveyProgress: Bool = false
    
    private(set) var questionID: String = ""
    
    var cacheHealthState = CurrentValueSubject<CozieCacheState, Never>(.finished)
    
    var upadateLocationInProgress = false
    
    private var healthCache: [HealthModel]?
    private var bag = Set<AnyCancellable>()
    
    // MARK: Private func
    private func loadWatchSurvey(data: Data) {
        do {
            let wSurvey = try JSONDecoder().decode(WatchSurveyModelController.self, from: data)
            watchSurvey = wSurvey
            if let question = wSurvey.survey.first(where: { $0.questionID == (wSurvey.firstQuestionID ?? "failed") }) {
                // questionID has a side effect of questionsTitle !!!
                questionID = question.questionID
                
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
            
            cacheHealthState.send(.inprogress)
            watchSurveyInteractor.healthDataPreload(trigger: CommunicationKeys.syncWatchSurveyTrigger.rawValue) { [weak self] models in
                if self?.cacheHealthState.value == .inprogress {
                    self?.healthCache = models
                    self?.cacheHealthState.send(.finished)
                }
            }
            
            // Uncomment for test
//            Task {
//                try await Task.sleep(nanoseconds: 10_000_000_000)
//                self.healthCache = []
//                self.cacheHealthState.send(.finished)
//            }
            
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
        if cacheHealthState.value == .inprogress {
            // clear bag
            bag = Set<AnyCancellable>()
            
            // bind HealfData state
            cacheHealthState.sink { [weak self] value in
                guard let self = self else { return }
                
                switch value {
                case .finished:
                    debugPrint("HealthData finished pre-cache")
                    triggerSendSurvey()
                default:
                    debugPrint("HealthData error pre-cache")
                }
            }
            .store(in: &bag)
        } else if cacheHealthState.value == .finished, healthCache != nil {
            triggerSendSurvey()
        } else {
            triggerSendSurvey()
        }
        
        storage.saveLastSurveySend()
        storage.updateSurveyCount()
    }
    
    private func triggerSendSurvey() {
        watchSurveyInteractor.sendSurveyData(watchSurvey: watchSurvey, selectedOptions: selectedOptions, location: locationManager.currentLocation, time: (startTime, locationManager.currentLocation?.timestamp), healthCache: healthCache, logsComplition: { }, completion: { [weak self] success, error in
            self?.resetCachedHealthData()
            
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
    }
    
    // MARK: reset pre-cache HealthData
    private func resetCachedHealthData() {
        healthCache = nil
        cacheHealthState.send(.finished)
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
    func prepareLocationAndConnectivityManager() {
        locationManager.updateLocation(completion: nil)
        
        if WCSession.isSupported(), !session.isReachable {
            session.delegate = self
            session.activate()
            prepareWatchSurvey()
        }
    }
    
    func selectedOption(for questionID: String) -> Int? {
        return selectedOptions.firstIndex(where: { $0.sID == questionID })
    }
    
    func isOptinSelected(option: ResponseOption) -> Bool {
        return selectedOptions.contains(where: {$0.optin.id == option.id})
    }
    
    func selectOptions(option: ResponseOption) {
        // haptic indicator of button presses
        WKInterfaceDevice.current().play(.click)
        
        // remove previouse selected option
        if let indextoDelete = selectedOption(for: currentSurvey?.questionID ?? "") {
            selectedOptions[indextoDelete] = (currentSurvey?.questionID ?? "", option)
        } else {
            selectedOptions.append((currentSurvey?.questionID ?? "", option))
        }
        
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
            // Return to sync state and show the last selected survey
            if state == .sendData{
                state = .synced
                return
            }
            
            WKInterfaceDevice.current().play(.click)
            
            // Return to the previous selected option from the selected option
            if let currentSurveyIndex = selectedOption(for: currentSurvey?.questionID ?? ""), currentSurveyIndex > 0 {
                let prewSurveyIndex = currentSurveyIndex-1
                if let prevSuvey = watchSurvey?.survey.first(where: { $0.questionID == selectedOptions[prewSurveyIndex].sID }) {
                    questionsTitle = prevSuvey.question
                    questionsList = prevSuvey.responseOptions
                    currentSurvey = prevSuvey
                }
            } else {
                // Back to previous selected option
                let current = selectedOptions.last
                if let prevSuvey = watchSurvey?.survey.first(where: { $0.questionID == current?.sID ?? "" }) {
                    questionsTitle = prevSuvey.question
                    questionsList = prevSuvey.responseOptions
                    currentSurvey = prevSuvey
                }
            }
        }
    }
    
    func resetAction() {
        backAction()
    }
    
    func restart() {
        WKInterfaceDevice.current().play(.click)
        locationManager.updateLocation(completion: nil)
        
        selectedOptions.removeAll()
        prepareWatchSurvey()
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
        
        // transfer file status
        if let transferFileStatus = message[CommunicationKeys.transferFileStatusKey.rawValue] as? Int {
            if transferFileStatus == FileTransferStatus.finished.rawValue {
                storage.clearLogs()
            }
            replyHandler([CommunicationKeys.received.rawValue: true])
            return
        }
        
        replyHandler([CommunicationKeys.received.rawValue: true])
        
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
        
        if let maxTimeInterval = message[CommunicationKeys.healthCutoffTimeInterval.rawValue] as? Double {
            storage.saveHealthMaxCutoffTimeinterval(maxTimeInterval)
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
