//
//  HealthKitInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 13.04.23.
//

import Foundation
import HealthKit

class HealthKitInteractor {
    static let minInterval: Double = 60
    
    enum HeathDataKeys: String {
        case heartRateKey = "ts_heart_rate"
        case restingHeartRateKey = "ts_resting_heart_rate"
        case walkingHeartRateVariabilityKey = "ts_HRV"
        case environmentalAudioExposureKey = "ts_audio_exposure_environment"
        case headphoneAudioExposureKey = "ts_audio_exposure_headphones"
        case distanceWalkingRunningKey = "ts_walking_distance"
        case stepCountKey = "ts_step_count"
        case standTimeKey = "ts_stand_time"
        case oxygenSaturationKey = "ts_oxygen_saturation"
        case bodyMassKey = "ts_body_mass"
        case bodyMassIndexKey = "ts_BMI"
        case wristTemperatureKey = "ts_wrist_temperature"
    }
    
    private let healthStore = HKHealthStore()
    private let storage = CozieStorage.shared
    private let userIntaractor = UserInteractor()
    private let backendInteractor = BackendInteractor()
    private let service: BaseRepository = BaseRepository()
    static var sendDataInProgress = false
    
    let loggerInteractor = LoggerInteractor.shared
    var transmitTrigger = "background_task"
    
    let allTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                        HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,
                        HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)!,
                        HKObjectType.quantityType(forIdentifier: .stepCount)!,
                        HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                        //HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
                        //HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                        //HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
                        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                        HKObjectType.quantityType(forIdentifier: .appleStandTime)!])
    
    func requestHealthAuth(completion: ((_ succes: Bool)->())? = nil) {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: nil, read: allTypes) { success, error in
                if success {
                    debugPrint("success")
                }
                completion?(success)
            }
        } else {
            debugPrint("HealthData not available!")
        }
    }
    
    private func getLastDaySamples(for sampleType: HKSampleType,
                                          completion: @escaping ([HKQuantitySample], Error?) -> Swift.Void) {
        var lastSync = Date().timeIntervalSince1970
        let typeKey = healthKeyFor(simple: sampleType)
        // new
        let lastSavedSync = storage.healthLastSyncedTimeInterval(key: typeKey)
        //
        
        if lastSavedSync > 0 {
            lastSync = lastSavedSync
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date(timeIntervalSince1970: TimeInterval(lastSync)),
                end: Date(),
                options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                ascending: false)
        
        //testLog(trigger: "(HealthKit)Samples for -> (\(typeKey))", details: "Start time: (\(Date(timeIntervalSince1970: TimeInterval(lastSync))) End time: (\(Date()))", state: "info")
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
            
            guard let samples = samples as? [HKQuantitySample] else {
                completion([], error)
                return
            }
            // new
            var lastSyncInterval = 0.0
            samples.forEach { obj in
                let interval = obj.endDate.timeIntervalSince1970
                debugPrint("Interval for symple:\(interval)")
                if interval > lastSyncInterval {
                    lastSyncInterval = interval
                    debugPrint("Update interval for symple:\(interval)")
                }
            }
            if lastSyncInterval > 0 {
                self?.storage.healthUpdateTempLastSyncedTimeInterval(lastSyncInterval, key: typeKey)
            }
            //self?.testLog(trigger: "(HealthKit)Samples for -> (\(typeKey))", details: "Last sync interval: (\(lastSyncInterval))", state: "info")
            //
            
            completion(samples, nil)
        }
        
        healthStore.execute(sampleQuery)
    }
    
    private let healthDateFormattor: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()
    
    private func getDataObject(type: HKSampleType?, trigger: String, completion: @escaping ([HealthModel], [HKQuantitySample]) -> Void) {
        guard let type = type, let user = userIntaractor.currentUser else {
            debugPrint("\(String(describing: type)) Sample Type is no longer available in HealthKit or User not exist")
            completion([], [])
            return
        }

        let tag = Tags(idOnesignal: storage.playerID(), idParticipant: user.participantID ?? "", idPassword: user.passwordID ?? "")
        
        getLastDaySamples(for: type) { [weak self] (samples, error) in
            guard let self = self else { return }
            
            var healthModels: [HealthModel] = []
            
            if samples.count > 0 {
                let lastSunccesTimestamp = self.storage.healthLastSyncedTimeInterval(key: self.healthKeyFor(simple: type))
                
                let group = DispatchGroup()
                samples.forEach({
                    let sample = $0
    
                    group.enter()
                    self.convertToUnit(sample: $0, type: type) { value in
                        // reject value with start time less than last update time
                        if sample.startDate.timeIntervalSince1970 <= lastSunccesTimestamp {
                            
                            //self.testLog(trigger: trigger, details: "Reject value with start time:\(sample.startDate.timeIntervalSince1970) less than last update time:\(lastSunccesTimestamp)", state: "error")
                            group.leave()
                            return
                        }
                        
                        let currentDataString = self.healthDateFormattor.string(from: sample.startDate)

                        if let lastModel = healthModels.last {
                            // prevent value duplicates
                            if lastModel.time != currentDataString {
                                healthModels.append(HealthModel(time: self.healthDateFormattor.string(from: sample.startDate), measurement: user.experimentID ?? "", tags: tag, fields: HealthFilds(transmitTtrigger: trigger, healthKey: self.healthKeyFor(simple: type), healthValue: value ?? 0.0)))
//
//                                self.testLog(trigger: trigger, details: "Added simples with start date:\(sample.startDate.timeIntervalSince1970) last update time:\(lastSunccesTimestamp)", state: "info")
                            }
                        } else {
                            healthModels.append(HealthModel(time: self.healthDateFormattor.string(from: sample.startDate), measurement: user.experimentID ?? "", tags: tag, fields: HealthFilds(transmitTtrigger: trigger, healthKey: self.healthKeyFor(simple: type), healthValue: value ?? 0.0)))
                            
//                            self.testLog(trigger: trigger, details: "Added simples with start date:\(sample.startDate.timeIntervalSince1970) last update time:\(lastSunccesTimestamp)", state: "info")
                        }
                        group.leave()
                    }
                })
                
                group.notify(queue: DispatchQueue.global()) {
                    completion(healthModels, samples)
                }
                
            } else if let error = error {
                completion([], samples)
                debugPrint("error: \(error)")
            } else {
                completion([], samples)
            }
        }
    }
    
    private func healthKeyFor(simple: HKSampleType) -> String {
        switch simple {
        case HKSampleType.quantityType(forIdentifier: .heartRate):
            return HeathDataKeys.heartRateKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .restingHeartRate):
            return HeathDataKeys.restingHeartRateKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN):
            return HeathDataKeys.walkingHeartRateVariabilityKey.rawValue
        case HKSampleType.quantityType(forIdentifier: .headphoneAudioExposure):
            return HeathDataKeys.headphoneAudioExposureKey.rawValue
        case HKSampleType.quantityType(forIdentifier: .environmentalAudioExposure):
            return HeathDataKeys.environmentalAudioExposureKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning):
            return HeathDataKeys.distanceWalkingRunningKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .stepCount):
            return HeathDataKeys.stepCountKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .appleStandTime):
            return HeathDataKeys.standTimeKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .oxygenSaturation):
            return HeathDataKeys.oxygenSaturationKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .bodyMass):
            return HeathDataKeys.bodyMassKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .bodyMassIndex):
            return HeathDataKeys.bodyMassIndexKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .bodyTemperature):
            return HeathDataKeys.wristTemperatureKey.rawValue
        default:
            return ""
        }
    }
    
   private func convertToUnit(sample: HKQuantitySample, type: HKSampleType, completion: @escaping (Double?) -> Void) {
        
        var data: Double? = nil
        
        switch type {
        case HKSampleType.quantityType(forIdentifier: .environmentalAudioExposure),
            HKSampleType.quantityType(forIdentifier: .headphoneAudioExposure):
            data = sample.quantity.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
        case HKSampleType.quantityType(forIdentifier: .heartRate):
            data = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        case HKObjectType.quantityType(forIdentifier: .oxygenSaturation):
            data = sample.quantity.doubleValue(for: HKUnit(from: "%")) * 100
        case HKObjectType.quantityType(forIdentifier: .bodyMass),
            HKObjectType.quantityType(forIdentifier: .leanBodyMass):
            data = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
        case HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .flightsClimbed),
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            HKObjectType.quantityType(forIdentifier: .uvExposure):
            data = sample.quantity.doubleValue(for: HKUnit.count())
        case HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN):
            data = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
        case HKObjectType.quantityType(forIdentifier: .appleStandTime):
            data = sample.quantity.doubleValue(for: HKUnit.second())
        case HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage),
            HKObjectType.quantityType(forIdentifier: .restingHeartRate):
            data = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKObjectType.quantityType(forIdentifier: .distanceCycling):
            data = sample.quantity.doubleValue(for: HKUnit.meter())
        case HKObjectType.quantityType(forIdentifier: .basalBodyTemperature),
            HKObjectType.quantityType(forIdentifier: .bodyTemperature):
            data = sample.quantity.doubleValue(for: HKUnit.degreeCelsius())
        case HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic):
            data = sample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
        case HKObjectType.quantityType(forIdentifier: .peakExpiratoryFlowRate):
            data = sample.quantity.doubleValue(for: HKUnit(from: "L/min"))
        case HKObjectType.quantityType(forIdentifier: .vo2Max):
            data = sample.quantity.doubleValue(for: HKUnit(from: "ml/kg*min"))
        case HKObjectType.quantityType(forIdentifier: .dietaryWater):
            data = sample.quantity.doubleValue(for: HKUnit(from: "ml"))
        default:
            break
        }
        completion(data)
    }
    
    func getAllRequestedData(trigger: String = CommunicationKeys.syncBackgroundTaskTrigger.rawValue, completion: ((_ models: [HealthModel])->())?) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            var list: [HealthModel] = []
            
            let group = DispatchGroup()
            for type in self.allTypes {
                group.enter()
                self.getDataObject(type: type, trigger: trigger) { infos, simples in
                    list.append(contentsOf: infos)
                    group.leave()
                }
            }
            
            group.notify(queue: DispatchQueue.global()) {
                completion?(list)
            }
        }
    }
    
    func sendData(trigger: String = CommunicationKeys.syncBackgroundTaskTrigger.rawValue, timeout: Double? = nil, completion: ((_ succces: Bool)->())?) {
        
//        testLog(trigger: trigger, details: "Sending HealthKit data started", state: "triggered")
        
        // prevent data from being sent if a previous send has not completed
        if HealthKitInteractor.sendDataInProgress {
            completion?(false)
//            testLog(trigger: trigger, details: "Sending HealthKit data suspended (previous send has not completed)", state: "error")
            return
        }
        
        // check if the timeout has expired
        var sendTimeout = BackgroundUpdateManager.minimumTimeInterval
        if let customTimeout = timeout {
            sendTimeout = customTimeout
        }
        
        if ((Date().timeIntervalSince1970 - storage.healthLastSyncedTimeInterval()) - sendTimeout) < 0 {
            HealthKitInteractor.sendDataInProgress = false
            completion?(false)
//            testLog(trigger: trigger, details: "Minimum time interval not reached", state: "error")
            return
        }
        
        HealthKitInteractor.sendDataInProgress = true
        
        self.requestHealthAuth { [weak self]  success in
            
            guard let self else { return }
            
            if !success, !HealthKitInteractor.sendDataInProgress {
                HealthKitInteractor.sendDataInProgress = false
                completion?(success)
//                self.testLog(trigger: trigger, details: "(HealthKit) Permission not granted or sending data in progress", state: "error")
                return
            }
            
            self.getAllRequestedData(trigger: trigger) { models in
                if let backend = self.backendInteractor.currentBackendSettings, !models.isEmpty {
                    do {
                        let bodyJson = try JSONEncoder().encode(models)
                        
                        // log data
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .withoutEscapingSlashes
                        let json = try? encoder.encode(models)
                        if let json {
                            self.loggerInteractor.logInfo(action: "", info: String(data: json, encoding: .utf8) ?? "")
                        }
                        
                        self.service.post(url: backend.api_write_url ?? "", body: bodyJson, key: backend.api_write_url ?? "") { result in
                            switch result {
                            case .success(_):
                                let lastUpdateDate = Date()
                                self.storage.healthUpdateLastSyncedTimeInterval(lastUpdateDate.timeIntervalSince1970)
                                
                                self.allTypes.forEach { obj in
                                    self.storage.healthUpdateFromTempLastSyncedTimeInterval(key: self.healthKeyFor(simple: obj))
                                }
                                
                                HealthKitInteractor.sendDataInProgress = false
                                //self.testLog(trigger: trigger, details: "(HealthKit)Data sent -> date:\(lastUpdateDate)", state: "success")
                                completion?(true)
                                
                            case .failure(let error):
                                HealthKitInteractor.sendDataInProgress = false
                                debugPrint(error.localizedDescription)
//                                self.testLog(trigger: trigger, details: "(HealthKit)Service error: \(error.localizedDescription)", state: "error")
                                completion?(false)
                            }
                        }
                    } catch let error {
                        HealthKitInteractor.sendDataInProgress = false
                        debugPrint(error.localizedDescription)
//                        self.testLog(trigger: trigger, details: "(HealthKit)Encoding error: \(error.localizedDescription)", state: "error")
                        completion?(false)
                    }
                } else {
                    HealthKitInteractor.sendDataInProgress = false
                    completion?(false)
                    debugPrint("Backend not configured or empty data!")
//                    if self.backendInteractor.currentBackendSettings == nil {
//                        self.testLog(trigger: trigger, details: "Backend not configured!", state: "info")
//                    } else if models.isEmpty {
//                        self.testLog(trigger: trigger, details: "Empty HealthKit data!", state: "info")
//                    } else {
//                        self.testLog(trigger: trigger, details: "Backend not configured or empty HealthKit data!", state: "info")
//                    }
                }
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
//        "si_health_kit_state": "\(state)",
//        "si_health_kit_details": "\(details)"
//        }
//        """
//        LoggerInteractor.shared.logInfo(action: "", info: str)
//    }
}

