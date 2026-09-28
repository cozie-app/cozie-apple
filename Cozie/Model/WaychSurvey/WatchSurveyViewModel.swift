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
    @Published var syncProgress: Double = 0
    
    private var summarySyncing = false
    private var healthDataSyncing = false

    var fileDataURL: URL? = nil
    var errorString: String = ""

    func updateData(sendHealthData: Bool = false, completion: @escaping () -> Void) {
        if !loading {
            loading = true
            syncProgress = 0
            summarySyncing = true
            healthDataSyncing = sendHealthData

            syncInteractor.syncSummaryData(completion: { [weak self] error in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.summarySyncing = false
                    self.dataSynced = error == nil
                    self.finishSyncStepIfNeeded()
                }
            })
            if sendHealthData {
                healthKitInteractor.sendData(trigger: CommunicationKeys.syncDataTrigger.rawValue,
                                              timeout: HealthKitInteractor.minInterval,
                                              progress: { [weak self] fraction in
                    self?.syncProgress = fraction
                },
                                              completion: { [weak self] _ in
                    DispatchQueue.main.async {
                        guard let self else { return }
                        self.healthDataSyncing = false
                        self.finishSyncStepIfNeeded()
                    }
                })
            }
        }
    }

    private func finishSyncStepIfNeeded() {
        if !summarySyncing && !healthDataSyncing {
            loading = false
            syncProgress = 0
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
