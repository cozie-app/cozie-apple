//
//  BackendViewModel.swift
//  Cozie
//
//  Created by Denis on 31.03.2023.
//

import Foundation
import CoreData

class BackendData: ObservableObject {
    let id: Int
    var title: String
    var subtitle: String
    
    init(id: Int, title: String, subtitle: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

class BackendViewModel: NSObject, ObservableObject {
    enum BackendState: Int {
        case readURL, readKey, writeURL, writeKey, oneSignalAppId, participantPassword, watchsurveyLink, phoneSurveyLink, clear
    }

    // State Property
    @Published var showingState: BackendState = .clear {
        didSet {
            updateState(state: showingState)
        }
    }
    
    @Published var list: [BackendData] = [BackendData(id: 0,
                                                      title: "API Read URL",
                                                      subtitle: "https://at6x6b7v54hmoki6dlyew72csq0ihxrn.lambda-url.ap-southeast-1.on.aws"),
                                          BackendData(id: 1,
                                                      title: "API Read Key",
                                                      subtitle: "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"),
                                          BackendData(id: 2,
                                                      title: "API Write URL",
                                                      subtitle: ""),
                                          BackendData(id: 3,
                                                      title: "API Write Key",
                                                      subtitle: ""),
                                          BackendData(id: 4,
                                                      title: "OneSignal App ID",
                                                      subtitle: ""),
                                          BackendData(id: 5,
                                                      title: "Participant Password",
                                                      subtitle: ""),
                                          BackendData(id: 6,
                                                      title: "Watch Survey Link",
                                                      subtitle: ""),
                                          BackendData(id: 7,
                                                      title: "Phone Survey Link",
                                                      subtitle: "")]
    
    private var backendState: BackendState = .clear
    let backendInteractor = BackendInteractor()
    let userIntaractor = UserInteractor()
    let persistenceController = PersistenceController.shared
    let comManager = WatchConnectivityManagerPhone.shared
    let setitngsInteractor = SettingsInteractor()
    let watchSurveyInteractor = WatchSurveyInteractor()
    let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), loger: LoggerInteractor.shared)

    @Published var loading: Bool = false
    
    @Published var showError: Bool = false
    var errorString: String = ""

    // MARK: Prepare Data
    func prepareData() {
        let tempData = list
        tempData.enumerated().forEach { (index, data) in
            data.subtitle = dataFor(state: BackendState(rawValue: index) ?? .clear)
        }
        list = tempData
        
        sendHKInfo()
    }
    
    // MARK: - State Property Reaction
    func updateState(state: BackendState) {
        if state != .clear {
            backendState = .clear
        } else {
            backendState = state
        }
    }
    
    // MARK: Update backend values
    func updateValue(state: BackendState, value: String) {
        guard let backend = backendInteractor.currentBackendSettings else { return }
        switch state {
        case .readURL:
            backend.api_read_url = value
        case .readKey:
            backend.api_read_key = value
        case .writeURL:
            backend.api_write_url = value
        case .writeKey:
            backend.api_write_key = value
        case .oneSignalAppId:
            backend.one_signal_id = value
        case .participantPassword:
            backend.participant_password = value
            userIntaractor.currentUser?.passwordID = value
        case .watchsurveyLink:
            backend.watch_survey_link = value
        case .phoneSurveyLink:
            backend.phone_survey_link = value
        case .clear:
            break
        }
        
        try? persistenceController.container.viewContext.save()
    }
    
    func dataFor(state: BackendState) -> String {
        guard let backend = backendInteractor.currentBackendSettings else { return "" }
        switch state {
        case .readURL:
            return backend.api_read_url ?? ""
        case .readKey:
            return backend.api_read_key ?? ""
        case .writeURL:
            return backend.api_write_url ?? ""
        case .writeKey:
            return backend.api_write_key ?? ""
        case .oneSignalAppId:
            return backend.one_signal_id ?? ""
        case .participantPassword:
            return backend.participant_password ?? ""
        case .watchsurveyLink:
            return backend.watch_survey_link ?? ""
        case .phoneSurveyLink:
            return backend.phone_survey_link ?? ""
        case .clear:
            return ""
        }
    }
    
    func loadWatchSurveyJSON(completion: ((_ success: Bool)->())?) {
        if !loading {
            loading = true
            backendInteractor.loadExternalWatchSurveyJSON { [weak self] success in
                guard let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    self.loading = false
                    if success {
                        self.errorString = ""
                    } else {
                        self.errorString = "Load watch survey JSON error."
                    }
                    completion?(success)
                }
            }
            
            // send health data
            healthKitInteractor.sendData(trigger: CommunicationKeys.syncBackendTrigger.rawValue, timeout: HealthKitInteractor.minInterval, completion: nil)
        }
    }
    
    // MARK: Sync watch survey
    func syncWatchData() {
        watchSurveyInteractor.loadSelectedWatchSurveyJSON { [weak self] success in
            guard let self = self else {
                return
            }
            if success {
                DispatchQueue.main.async {
                    do {
                        let request = WatchSurveyData.fetchRequest()
                        request.predicate = NSPredicate(format: "selected == %d", true)
                        let surveysList = try self.persistenceController.container.viewContext.fetch(request)
                        
                        if let survey = surveysList.first?.toModel(), let backend = self.backendInteractor.currentBackendSettings, let user = self.userIntaractor.currentUser, let settings = self.setitngsInteractor.currentSettings  {
                            let json = try JSONEncoder().encode(survey)
                            self.comManager.sendAll(data: json, writeApiURL: backend.api_write_url ?? "", writeApiKey: backend.api_write_key ?? "", userID: user.participantID ?? "", expID: user.experimentID ?? "", password: user.passwordID ?? "", userOneSignalID: backend.one_signal_id ?? "", timeInterval: Int(settings.wss_time_out))
                        }
                        
                    } catch let error {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // MARK: send HKInfo
    func sendHKInfo() {
        healthKitInteractor.getAllRequestedData(completion: nil)
    }
    
}
