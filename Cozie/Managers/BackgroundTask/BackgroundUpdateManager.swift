
import Foundation
import BackgroundTasks
import HealthKit
import UIKit

struct BGUpdateData: Codable {
    let soundPressure: [String: Double]?
    let heartRate: [String: Double]?
    let timestampStart, idParticipant, idDevice, idExperiment: String
    let timestampEnd: String
    
    enum CodingKeys: String, CodingKey {
        case soundPressure = "sound_pressure"
        case heartRate = "heart_rate"
        case timestampStart = "timestamp_start"
        case idParticipant = "id_participant"
        case idDevice = "id_device"
        case idExperiment = "id_experiment"
        case timestampEnd = "timestamp_end"
    }
}

class BackgroundUpdateManager {
    enum ExecutionStatus: Int {
        case inprogress = 1, end  = 0
    }
    private let updateStatusKey = "cozie.app.processing.status"
    
    private let processingID = "app.cozie.dataprocesssing"
    private let refreshID = "app.cozie.datarefresh"
    
    static let minimumTimeInterval: Double = 25 * 60
    
    // HKHealthStore
    private let healthStore = HKHealthStore()
    private let noise = HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!
    private let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    private let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), loger: LoggerInteractor.shared)
    private let storage = CozieStorage.shared
    
    var lastProcessingEvent: Double? = nil
    var startTimeStamp: Double = 0
    
    func registerBackgroundRefresh() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshID, using: nil) { task in
            self.hendleBgProcessing(task: task, work: nil)
        }
        healthKitInteractor.updateState()
        lastProcessingEvent = storage.healthLastSyncedTimeInterval(offline: healthKitInteractor.offlineMode.isEnabled)
    }
    
    func registerBackgroundProcessing(work: (()->())? = nil ) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: processingID, using: nil) { task in
            self.hendleBgProcessing(task: task, work: work)
        }
        healthKitInteractor.updateState()
        lastProcessingEvent = storage.healthLastSyncedTimeInterval(offline: healthKitInteractor.offlineMode.isEnabled)
    }
    
    func scheduleBgTaskRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: BackgroundUpdateManager.minimumTimeInterval)
        do {
            try BGTaskScheduler.shared.submit(request)
            debugPrint("For debug refreshID")
        } catch let error {
            debugPrint("Error: " + error.localizedDescription)
        }
    }
    
    func scheduleBgProcessing() {
        let request = BGProcessingTaskRequest(identifier: processingID)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true
        do {
            try BGTaskScheduler.shared.submit(request)
            debugPrint("For debug processingID")
        } catch let error {
            debugPrint("Error: " + error.localizedDescription)
        }
    }
    
    private func hendleBgProcessing(task: BGTask, work: (()->())? = nil ) {
        
        task.expirationHandler = { /*[weak self] in*/
            debugPrint("Expiration Processing Handler Accured!")
            //self?.testLog(details: "Expiration Processing Handler Accured!")
        }
        
        // update lastProcessingEvent
        healthKitInteractor.updateState()
        lastProcessingEvent = storage.healthLastSyncedTimeInterval(offline: healthKitInteractor.offlineMode.isEnabled)
        
        // preventing double data sending
        if let lastUpdate = lastProcessingEvent {
            
            // use process status to detect execution
            let status = UserDefaults.standard.value(forKey: updateStatusKey) as? Int ?? ExecutionStatus.end.rawValue
            let interval = Date().timeIntervalSince1970 - lastUpdate
            
            // check upload date not fit to requirements
            // we should send data once per 30 min
            if interval < BackgroundUpdateManager.minimumTimeInterval
                || status == ExecutionStatus.inprogress.rawValue {
                // testLog(details: "Minimum time interval not reached")
                // end processing task
                task.setTaskCompleted(success: true)
                
                // shceedule next processing
                if task is BGProcessingTask {
                    scheduleBgProcessing()
                } else {
                    scheduleBgTaskRefresh()
                }
                return
            } else {
                // change execution status
                UserDefaults.standard.setValue(ExecutionStatus.inprogress.rawValue, forKey: updateStatusKey)
            }
        } else {
            task.setTaskCompleted(success: true)
            //testLog(details: "Last processing event does not exist")
            return
        }
        
        healthKitInteractor.sendData { [weak self] success in
            guard success, let self = self else {
                //self?.testLog(details: "Failed to send HealthKit data!")
                UserDefaults.standard.setValue(ExecutionStatus.end.rawValue, forKey: self?.updateStatusKey ?? "")
                task.setTaskCompleted(success: true)
                
                // shceedule next processing
                if task is BGProcessingTask {
                    self?.scheduleBgProcessing()
                } else {
                    self?.scheduleBgTaskRefresh()
                }
                return
            }
            
            let lastEventDate = Date().timeIntervalSince1970
            self.lastProcessingEvent = lastEventDate
            
            self.storage.healthUpdateLastSyncedTimeInterval(lastEventDate, offline: healthKitInteractor.offlineMode.isEnabled)
            
            UserDefaults.standard.setValue(ExecutionStatus.end.rawValue, forKey: self.updateStatusKey)
            task.setTaskCompleted(success: true)
            
            // shceedule next processing
            if task is BGProcessingTask {
                self.scheduleBgProcessing()
            } else {
                self.scheduleBgTaskRefresh()
            }
        }
    }
    
    // log test
    //    private func testLog(details: String, state: String = "error") {
    //
    //        let str =
    //        """
    //        {
    //        "trigger": "background_task",
    //        "si_background_task_state": "\(state)",
    //        "si_background_task_details": "\(details)",
    //        }
    //        """
    //        LoggerInteractor.shared.logInfo(action: "", info: str)
    //    }
}
