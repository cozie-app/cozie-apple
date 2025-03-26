//
//  WatchSurveyViewModel.swift
//  Cozie
//
//  Created by Denis on 23.03.2023.
//

import Foundation

class WatchSurveyViewModel: ObservableObject {
    let syncInteractor = SyncInteractor()
    let backendInteractor = BackendInteractor()
    let loggerInteractor = LoggerInteractor.shared
    let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), logger: LoggerInteractor.shared)
    
    @Published var loading: Bool = false
    @Published var dataSynced: Bool = false
    
    var fileDataURL: URL? = nil
    var errorString: String = ""

    func updateData(sendHealthData: Bool = false, completion: @escaping () -> Void) {
        if !loading {
            loading = true
            syncInteractor.syncSummaryData(completion: { [weak self] error in
                DispatchQueue.main.async {
                    self?.loading = false
                    self?.dataSynced = error == nil
                }
            })
            if sendHealthData {
                healthKitInteractor.sendData(trigger: CommunicationKeys.syncDataTrigger.rawValue, timeout: HealthKitInteractor.minInterval, completion: nil)
            }
        }
    }
    
    func phoneSurveyLink() -> String? {
        return backendInteractor.currentBackendSettings?.phone_survey_link
    }
    // TODO: - Unit Tests
    func loadData(completion: ((_ success: Bool) -> ())?) {
        loggerInteractor.loggedInfo { url, error in
            if let error = error {
                self.errorString = error
                completion?(false)
            } else {
                self.errorString = ""
                self.fileDataURL = url
                completion?(true)
            }
        }
    }
}
