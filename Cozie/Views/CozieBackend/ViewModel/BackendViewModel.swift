//
//  BackendViewModel.swift
//  Cozie
//
//  Created by Denis on 31.03.2023.
//

import Foundation
import CoreData
import Combine

/// Generate data for TableView section
final class BackendSection: Identifiable {
    let id: Int
    var list: [BackendData]
    
    init(id: Int, list: [BackendData]) {
        self.id = id
        self.list = list
    }
    
    static var defaulDataSection = BackendSection(id: BackendViewModel.BackendSectionType.data.rawValue,
                                                  list: [BackendData(id: BackendViewModel.BackendState.healthCutoffTime.rawValue,
                                                                     title: "HealthKit Cutoff Time",
                                                                     subtitle: ""),
                                                         BackendData(id: BackendViewModel.BackendState.distanceFilter.rawValue,
                                                                                                title: "Distance Filter",
                                                                                                subtitle: "")])
    
    static var defaulBackendSection = BackendSection(id: BackendViewModel.BackendSectionType.backend.rawValue,
                                                     list: [BackendData(id: BackendViewModel.BackendState.readURL.rawValue,
                                                                        title: "API Read URL",
                                                                        subtitle: "https://at6x6b7v54hmoki6dlyew72csq0ihxrn.lambda-url.ap-southeast-1.on.aws"),
                                                            BackendData(id: BackendViewModel.BackendState.readKey.rawValue,
                                                                        title: "API Read Key",
                                                                        subtitle: "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"),
                                                            BackendData(id: BackendViewModel.BackendState.writeURL.rawValue,
                                                                        title: "API Write URL",
                                                                        subtitle: ""),
                                                            BackendData(id: BackendViewModel.BackendState.writeKey.rawValue,
                                                                        title: "API Write Key",
                                                                        subtitle: ""),
                                                            BackendData(id: BackendViewModel.BackendState.participantPassword.rawValue,
                                                                        title: "Participant Password",
                                                                        subtitle: "")])
    
    static var defaulSurveysSection = BackendSection(id: BackendViewModel.BackendSectionType.surveys.rawValue,
                                                     list: [BackendData(id: BackendViewModel.BackendState.watchsurveyLink.rawValue,
                                                                        title: "Watch Survey Link",
                                                                        subtitle: ""),
                                                            BackendData(id: BackendViewModel.BackendState.phoneSurveyLink.rawValue,
                                                                        title: "Phone Survey Link",
                                                                        subtitle: "")])
}

/// Cell data presentation.
class BackendData: Identifiable {
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
        case readURL, readKey, writeURL, writeKey, participantPassword, watchsurveyLink, phoneSurveyLink, healthCutoffTime, distanceFilter, clear
    }
    
    enum BackendSectionType: Int {
        case surveys, data, backend
    }
    
    // State Property
    @Published var showingState: BackendState = .clear {
        didSet {
            updateState(state: showingState)
        }
    }
    @Published var section: [BackendSection] = [BackendSection.defaulSurveysSection,
                                                BackendSection.defaulBackendSection,
                                                BackendSection.defaulDataSection]
    
    let storage: CozieStorageProtocol & WSStorageProtocol
    private var backendState: BackendState = .clear
    
    let backendInteractor: BackendInteractorProtocol
    let setitngsInteractor: SettingsInteractorProtocol
    let userIntaractor: UserInteractorProtocol
    
    let dbStorage: DataBaseStorageProtocol
    let comManager: WatchConnectivityManagerPhoneProtocol
    
    let watchSurveyInteractor: WatchSurveyInteractorProtocol
    let healthKitInteractor: HealthKitInteractorProtocol
    
    @Published var loading: Bool = false
    @Published var showError: Bool = false
    
    var errorString: String = ""
    private var subscriptions = Set<AnyCancellable>()
    
    /// Init Ingection
    /// - Parameters:
    ///    - storage: User storage
    ///    - backendInteractor: Interactor for backend data.
    ///    - setitngsInteractor: Interactor for settings data.
    init(storage: CozieStorageProtocol & WSStorageProtocol,
         backendInteractor: BackendInteractorProtocol = BackendInteractor(),
         setitngsInteractor: SettingsInteractorProtocol = SettingsInteractor(),
         userIntaractor: UserInteractorProtocol = UserInteractor(),
         dbStorage: DataBaseStorageProtocol = PersistenceController.shared,
         comManager: WatchConnectivityManagerPhoneProtocol = WatchConnectivityManagerPhone.shared,
         watchSurveyInteractor: WatchSurveyInteractorProtocol = WatchSurveyInteractor(),
         healthKitInteractor: HealthKitInteractorProtocol = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), loger: LoggerInteractor.shared)) {
        
        self.storage = storage
        self.backendInteractor = backendInteractor
        self.setitngsInteractor = setitngsInteractor
        self.userIntaractor = userIntaractor
        self.dbStorage = dbStorage
        self.comManager = comManager
        self.watchSurveyInteractor = watchSurveyInteractor
        self.healthKitInteractor = healthKitInteractor

    }
    // MARK: Prepare Data
    func prepareData(active: ((_ progress: Bool)->())?) {
        let updatedList = section
        updatedList
            .flatMap{ $0.list }
            .forEach { $0.subtitle = dataFor(state: BackendState(rawValue: $0.id) ?? .clear)}
        
        section = updatedList
        sendHKInfo()
        
        $loading.sink { progress in
            active?(progress)
        }
        .store(in: &subscriptions)
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
    /// Use this function to update backend data.
    /// - Parameters:
    ///    - state: BackendState type.
    ///    - value: string value from testField.
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
        case .participantPassword:
            backend.participant_password = value
            userIntaractor.currentUser?.passwordID = value
        case .watchsurveyLink:
            // Load watch summary if ws link was edited
            if backend.watch_survey_link != value {
                backend.watch_survey_link = value
                loadWatchSurveyJSON(completion: nil)
            }
        case .phoneSurveyLink:
            backend.phone_survey_link = value
        case .healthCutoffTime:
            storage.saveMaxHealthCutoffTimeInterval(Double(value) ?? 3.0)
            break
        case .distanceFilter:
            guard let floatValue = Float(value) else { return }
            storage.setDistanceFilter(floatValue)
        case .clear:
            break
        }
        
        try? dbStorage.saveViewContext()
    }
    
    /// Get a string representation of the Backend tab values.
    ///
    /// - Parameters:
    ///     - state: BackendState
    ///
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
        case .participantPassword:
            return backend.participant_password ?? ""
        case .watchsurveyLink:
            return backend.watch_survey_link ?? ""
        case .phoneSurveyLink:
            return backend.phone_survey_link ?? ""
        case .healthCutoffTime:
            return "\(Int(storage.maxHealthCutoffTimeInterval()))"
        case .distanceFilter:
            return "\(Int(storage.distanceFilter()))"
        case .clear:
            return ""
        }
    }
    
    /// Use this function to download a watch survey.
    ///
    /// - Parameters:
    ///     - completion: return closure with load status
    ///
    ///  - Note: This function enables the loading indicator on the view.
    ///
    func loadWatchSurveyJSON(completion: ((_ success: Bool)->())?) {
        if !loading {
            loading = true
            backendInteractor.loadExternalWatchSurveyJSON { [weak self] loadError in
                guard let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    self.loading = false
                    if loadError == nil {
                        self.errorString = ""
                        completion?(true)
                    } else {
                        self.errorString = WatchConnectivityManagerPhone.WatchConnectivityManagerError.surveyJSONError.localizedDescription
                        Task { @MainActor in
                            try? await self.dbStorage.removeExternalSurvey()
                            completion?(false)
                        }
                    }
                }
            }
            
            // send health data
            healthKitInteractor.sendData(trigger: CommunicationKeys.syncBackendTrigger.rawValue,
                                         timeout: HealthKitInteractor.minInterval,
                                         healthCache: nil,
                                         completion: nil)
        }
    }
    
    // MARK: Sync watch survey
    
    /// Sync with watch
    func syncWatchData() {
        watchSurveyInteractor.loadSelectedWatchSurveyJSON { [weak self] title, loadError in
            guard let self = self else {
                return
            }
            if loadError == nil {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    do {
                        let request = WatchSurveyData.fetchRequest()
                        let selectedSurvey = try dbStorage.selectedWatchSurvey()
                        
                        if let survey = selectedSurvey?.toModel(),
                            let backend = self.backendInteractor.currentBackendSettings,
                            let user = self.userIntaractor.currentUser,
                            let settings = self.setitngsInteractor.currentSettings {
                            
                            let json = try JSONEncoder().encode(survey)
                            
                            self.comManager.sendAll(data: json, writeApiURL: backend.api_write_url ?? "", writeApiKey: backend.api_write_key ?? "", userID: user.participantID ?? "", expID: user.experimentID ?? "", password: user.passwordID ?? "", userOneSignalID: backend.one_signal_id ?? "", timeInterval: Int(settings.wss_time_out), healthCutoffTimeInterval: storage.maxHealthCutoffTimeInterval(), completion: nil)
                        }
                        
                    } catch let error {
                        debugPrint(error.localizedDescription)
                    }
                }
            } else {
                // error
                debugPrint(loadError?.localizedDescription ?? "error -> syncWatchData")
            }
        }
    }
    
    // MARK: send HKInfo
    /// Send health kit data to the server.
    func sendHKInfo() {
        healthKitInteractor.getAllRequestedData(trigger: CommunicationKeys.syncBackgroundTaskTrigger.rawValue, completion: nil)
    }
    
}
