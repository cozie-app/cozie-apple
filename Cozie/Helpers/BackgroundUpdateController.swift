//
//  BackgroundUpdateController.swift
//  TestBGUpdate
//
//  Created by Alexandr Chmal on 31.07.2022.
//

import Foundation
import BackgroundTasks
import HealthKit
import UIKit

// MARK: - SoundData

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

class BackgroundUpdateController {
    enum ExecutionStatus: Int {
        case inprogress = 1, end  = 0
    }
    private let processingRecordsKey = "cozy.app.records.processing"
    private let updateStatusKey = "cozy.app.processing.status"
    private let processingID = "app.cozy.dataprocesssing"
    
    private let refreshID = "app.cozy.datarefresh"
    private let minimumTimeInterval: Double = 25 * 60
    
    // HKHealthStore
    private let healthStore = HKHealthStore()
    private let noise = HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!
    private let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    private let service: HealthRepositoryType
    
    init(service: HealthRepositoryType) {
        self.service = service
    }
    
    var lastProcessingEvent: Double? = nil
    var startTimeStamp: Double = 0
    
    func setStartTemeRangeIfNeeded() {
        UserDefaults.standard.setValue(ExecutionStatus.end.rawValue, forKey: updateStatusKey)
        if UserDefaults.standard.value(forKey: processingRecordsKey) == nil {
            UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: self.processingRecordsKey)
        }
    }
    
    //    func test() {
    //        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - minimumTimeInterval*2, forKey: processingRecordsKey)
    //        lastProcessingEvent = UserDefaults.standard.value(forKey: processingRecordsKey) as? Double
    //    }
    
    func registerBackgroundRefresh() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshID, using: nil) { task in
            self.hendleBgProcessing(task: task, work: nil)
        }
        if let eventTimeInterval = UserDefaults.standard.value(forKey: processingRecordsKey) as? Double {
            lastProcessingEvent = eventTimeInterval
        }
    }
    
    func registerBackgroundProcessing(work: (()->())? = nil ) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: processingID, using: nil) { task in
            self.hendleBgProcessing(task: task, work: work)
        }
        if let eventTimeInterval = UserDefaults.standard.value(forKey: processingRecordsKey) as? Double {
            lastProcessingEvent = eventTimeInterval
        }
    }
    
    func scheduleBgTaskRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: minimumTimeInterval)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch let error {
            print("Error: " + error.localizedDescription)
        }
    }
    
    func scheduleBgProcessing() {
        let request = BGProcessingTaskRequest(identifier: processingID)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch let error {
            print("Error: " + error.localizedDescription)
        }
    }
    
    private func hendleBgProcessing(task: BGTask, work: (()->())? = nil ) {
        
        task.expirationHandler = {
            print("Expiration Processing Handler Accured!")
        }
        // preventing double data sending
        if let lastUpdate = lastProcessingEvent {
            
            // use process status to detect execution
            let status = UserDefaults.standard.value(forKey: updateStatusKey) as? Int ?? ExecutionStatus.end.rawValue
            let interval = Date().timeIntervalSince1970 - lastUpdate
            
            // check upload date not fit to requirements
            // we should send data once per 30 min
            if interval < minimumTimeInterval
                || status == ExecutionStatus.inprogress.rawValue {
                
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
            return
        }
        
        HealthKitSetupAssistant.authorizeHealthKit {[weak self] (success, error) in
            guard success else {
                task.setTaskCompleted(success: true)
                return
            }
            
            var succeeCount = 0
            let groupe = DispatchGroup()
            groupe.enter()
            
            self?.noiseExposure { [weak self] audioExposure in
                guard  let audioExposure = audioExposure, let self = self else {
                    groupe.leave()
                    return
                }
                do {
                    let retrivedSounData = BGUpdateData(soundPressure: audioExposure, heartRate: nil, timestampStart: GetDateTimeISOString(), idParticipant: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", idDevice: UIDevice.current.identifierForVendor?.uuidString ?? "", idExperiment: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", timestampEnd: GetDateTimeISOString())
                    
                    let soundData = try JSONEncoder().encode(retrivedSounData)
                    
                    self.service.sendHealthInfo(data: soundData, completion: { result in
                        switch result {
                        case .success(_):
                            succeeCount += 1
                            groupe.leave()
                        default:
                            groupe.leave()
                            break
                        }
                    })
                } catch let error {
                    print(error.localizedDescription)
                    groupe.leave()
                }
            }
            
            groupe.enter()
            self?.heartRate { [weak self] heartRateInfo in
                guard  let heartRateInfo = heartRateInfo, let self = self else {
                    groupe.leave()
                    return
                }
                do {
                    let retrivedHeartRateData = BGUpdateData(soundPressure: nil, heartRate: heartRateInfo, timestampStart: GetDateTimeISOString(), idParticipant: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", idDevice: UIDevice.current.identifierForVendor?.uuidString ?? "", idExperiment: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", timestampEnd: GetDateTimeISOString())
                    
                    let heartRateData = try JSONEncoder().encode(retrivedHeartRateData)
                    
                    self.service.sendHealthInfo(data: heartRateData, completion: { result in
                        switch result {
                        case .success(_):
                            succeeCount += 1
                            groupe.leave()
                        default:
                            groupe.leave()
                            break
                        }
                    })
                } catch let error {
                    print(error.localizedDescription)
                    groupe.leave()
                }
            }
            groupe.notify(queue: .main) { [weak self] in
                if succeeCount > 0, let self = self {
                    let lastEventDate = Date().timeIntervalSince1970
                    self.lastProcessingEvent = lastEventDate
                    UserDefaults.standard.setValue(ExecutionStatus.end.rawValue, forKey: self.updateStatusKey)
                    UserDefaults.standard.setValue(lastEventDate, forKey: self.processingRecordsKey)
                }
                task.setTaskCompleted(success: true)
                
                // shceedule next processing
                if task is BGProcessingTask {
                    self?.scheduleBgProcessing()
                } else {
                    self?.scheduleBgTaskRefresh()
                }
            }
        }
    }
}

// MARK: - Get an array of noise levels

extension  BackgroundUpdateController {
    
    func noiseExposure(completion: @escaping (_ audioExposure: [String: Double]?) -> Void) {
        let endDate = Date()
        
        lastProcessingEvent = UserDefaults.standard.value(forKey: processingRecordsKey) as? Double
        
        if lastProcessingEvent == nil {
            debugPrint("fatal error")
            fatalError()
        }
        
        let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let startDate = Date.init(timeIntervalSince1970: lastProcessingEvent ?? 0)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end:  endDate, options: .strictEndDate)
        var noiseData: [String: Double] = [:]
        
        let query: HKSampleQuery = HKSampleQuery(sampleType: noise, predicate: predicate, limit: HKObjectQueryNoLimit,
                                                 sortDescriptors: [sortByDate]) { (query, results, error) in
            
            if let results = results as? [HKQuantitySample], results.count > 0 {
                
                for sample in results {
                    let sampledDate = FormatDateISOString(date: sample.startDate)
                    noiseData[sampledDate] = sample.quantity.doubleValue(for: HKUnit(from: "dBASPL"))
                }
            }
            completion(noiseData)
        }
        
        healthStore.execute(query)
    }
    
    func heartRate(completion: @escaping (_ heartRateInfo: [String: Double]?) -> Void) {
        let endDate = Date()
        
        lastProcessingEvent = UserDefaults.standard.value(forKey: processingRecordsKey) as? Double
        if lastProcessingEvent == nil {
            debugPrint("fatal error")
            fatalError()
        }
        
        let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let startDate = Date.init(timeIntervalSince1970: lastProcessingEvent ?? 0)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)

        var heatrRate: [String: Double] = [:]

        let query: HKSampleQuery = HKSampleQuery(sampleType: heartRate, predicate: predicate, limit: HKObjectQueryNoLimit,
                                                 sortDescriptors: [sortByDate]) { (query, results, error) in
            if let results = results as? [HKQuantitySample] {
                
                for sample in results {
                    let sampledDate = FormatDateISOString(date: sample.startDate)
                    heatrRate[sampledDate] = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
                
                completion(heatrRate)
                return
            }
            
            // no data
            completion(nil)
        }
        healthStore.execute(query)
    }
}
