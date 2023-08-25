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
    typealias SleepData = (sleepKey: String, startDate: Date, value: Double)
    
    enum HeathDataKeys: String {
        case heartRateKey = "_heart_rate"
        case restingHeartRateKey = "_resting_heart_rate"
        case walkingHeartRateVariabilityKey = "_HRV"
        case environmentalAudioExposureKey = "_audio_exposure_environment"
        case headphoneAudioExposureKey = "_audio_exposure_headphones"
        case distanceWalkingRunningKey = "_walking_distance"
        case stepCountKey = "_step_count"
        case standTimeKey = "_stand_time"
        case oxygenSaturationKey = "_oxygen_saturation"
        case bodyMassKey = "_body_mass"
        case bodyMassIndexKey = "_BMI"
        // Wrist Temperature
        case wristTemperatureKey = "_wrist_temperature"
        
        // Sleep Analysis Keys:
        case sleepAnalysisKey = "_sleep_analysis"
        case sleepInBed = "_sleep_in_bed"
        case sleepAwake = "_sleep_awake"
        case sleepDeep = "_sleep_deep"
        case sleepCore = "_sleep_core"
        case sleepREM = "_sleep_REM"
        case sleepUnspecified = "_sleep_unspecified"
    }
    
    private let healthStore = HKHealthStore()
    private let storage: CozieStorageProtocol
    private let userData: UserDataProtocol
    private let backendData: BackendDataProtocol
    private let service: BaseRepository = BaseRepository()
    static var sendDataInProgress = false
    
    let logger: LoggerProtocol
    var transmitTrigger = "background_task"
    private let dataPrefix: String
    
    let allTypesiPhone = [HKObjectType.quantityType(forIdentifier: .heartRate)!,
                     HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                     HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,
                     HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)!,
                     HKObjectType.quantityType(forIdentifier: .stepCount)!,
                     HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                     HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                     HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                     HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                     HKObjectType.quantityType(forIdentifier: .appleStandTime)!]
    
    let allWatchTypes = [HKObjectType.quantityType(forIdentifier: .heartRate)!,
                     HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                     HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,
                     HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)!,
                     HKObjectType.quantityType(forIdentifier: .stepCount)!,
                     HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                     HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                     HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                     HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                     HKObjectType.quantityType(forIdentifier: .appleStandTime)!]
    
    let allTypes: Set<HKSampleType>
    
    init(storage: CozieStorageProtocol, userData: UserDataProtocol, backendData: BackendDataProtocol, loger: LoggerProtocol, transmitTrigger: String = "background_task", dataPrefix: String = "ts") {
        self.storage = storage
        self.userData = userData
        self.backendData = backendData
        self.logger = loger
        self.dataPrefix = dataPrefix
        self.transmitTrigger = transmitTrigger
#if os(iOS)
        if #available(iOS 16, *) {
            var setTypes = Set(allTypesiPhone)
            setTypes.insert(HKQuantityType(HKQuantityTypeIdentifier.appleSleepingWristTemperature))
            allTypes = setTypes
        } else {
            allTypes = Set(allTypesiPhone)
        }
#else
        if #available(watchOS 9, *), Self.isWatchUltraOr9() {
            var setTypes = Set(allWatchTypes)
            setTypes.insert(HKQuantityType(HKQuantityTypeIdentifier.appleSleepingWristTemperature))
            allTypes = setTypes
        } else {
            allTypes = Set(allWatchTypes)
        }
#endif
    }
    
    static func isWatchUltraOr9() -> Bool {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let version = String(cString: &machine, encoding: String.Encoding.utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if version.isEmpty {
            return false
        }
        // test
        if version == "x86_64" {
            return true
        }
        
        if version.contains("Watch6,") {
            let lastVN = version.replacingOccurrences(of: "Watch6,", with: "")
            let vn = Int(lastVN) ?? 0
            let firstVNForWOS8 = 14
            if vn > firstVNForWOS8 {
                return true
            }
        }
        return false
    }
    
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
                                   completion: @escaping ([HKQuantitySample], [SleepData], Error?) -> Swift.Void) {
        var lastSync = Date().timeIntervalSince1970
        let typeKey = healthKeyFor(simple: sampleType)
        
        // save last sync time for each data
        let lastSavedSync = storage.healthLastSyncedTimeInterval(key: typeKey)
        
        if lastSavedSync > 0 {
            lastSync = lastSavedSync
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date(timeIntervalSince1970: TimeInterval(lastSync)),
                                                    end: Date(),
                                                    options: .strictEndDate)
        if typeKey == HeathDataKeys.sleepAnalysisKey.rawValue {
            print(TimeInterval(lastSync))
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
            // Sleep Analysis
            if typeKey == HeathDataKeys.sleepAnalysisKey.rawValue {
                guard let sleepSamples = samples as? [HKCategorySample], let self = self else {
                    completion([], [], error)
                    return
                }
                
                var lastSyncInterval = 0.0
                var sleepData: [SleepData] = []
                for sleepSample in sleepSamples {
                    let sleepKey = self.keyForSleepAnalysis(value: sleepSample.value)
                    if !sleepKey.isEmpty {
                        let lastInterval = sleepSample.endDate.timeIntervalSince1970
                        if lastSyncInterval < lastInterval {
                            lastSyncInterval = lastInterval
                        }
                        if lastInterval > lastSync {
                            sleepData.append((sleepKey, sleepSample.startDate, sleepSample.startDate.distance(to: sleepSample.endDate)/60))
                        }
                    }
                }
                
                if lastSyncInterval > 0, !sleepData.isEmpty {
                    self.storage.healthUpdateTempLastSyncedTimeInterval(lastSyncInterval, key: typeKey)
                }
                
                completion([], sleepData, nil)
            } else {
                guard let samples = samples as? [HKQuantitySample] else {
                    completion([], [], error)
                    return
                }

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
                
                completion(samples, [], nil)
            }
        }
        
        healthStore.execute(sampleQuery)
    }
    
    private let healthDateFormattor: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()
    
    private func getDataObject(type: HKSampleType?, trigger: String, completion: @escaping ([HealthModel], [HKQuantitySample]) -> Void) {
        guard let type = type, let user = userData.userInfo else {
            debugPrint("\(String(describing: type)) Sample Type is no longer available in HealthKit or User not exist")
            completion([], [])
            return
        }
        
        let tag = Tags(idOnesignal: storage.playerID(), idParticipant: user.participantID, idPassword: user.passwordID)
        
        getLastDaySamples(for: type) { [weak self] (samples, sleepData, error) in
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
                            
                            // self.testLog(trigger: trigger, details: "Reject value with start time:\(sample.startDate.timeIntervalSince1970) less than last update time:\(lastSunccesTimestamp)", state: "error")
                            group.leave()
                            return
                        }
                        
                        let currentDataString = self.healthDateFormattor.string(from: sample.startDate)
                        
                        if let lastModel = healthModels.last {
                            // prevent value duplicates
                            if lastModel.time != currentDataString {
                                healthModels.append(HealthModel(time: self.healthDateFormattor.string(from: sample.startDate), measurement: user.experimentID, tags: tag, fields: HealthFilds(transmitTtrigger: trigger, healthKey: self.addPrefixForDataKey(key: self.healthKeyFor(simple: type)), healthValue: value ?? 0.0)))
                                //
                                // self.testLog(trigger: trigger, details: "Added simples with start date:\(sample.startDate.timeIntervalSince1970) last update time:\(lastSunccesTimestamp)", state: "info")
                            }
                        } else {
                            healthModels.append(HealthModel(time: self.healthDateFormattor.string(from: sample.startDate), measurement: user.experimentID, tags: tag, fields: HealthFilds(transmitTtrigger: trigger, healthKey: self.addPrefixForDataKey(key: self.healthKeyFor(simple: type)), healthValue: value ?? 0.0)))
                            
                            // self.testLog(trigger: trigger, details: "Added simples with start date:\(sample.startDate.timeIntervalSince1970) last update time:\(lastSunccesTimestamp)", state: "info")
                        }
                        group.leave()
                    }
                })
                
                group.notify(queue: DispatchQueue.global()) {
                    completion(healthModels, samples)
                }
                
            } else if sleepData.count > 0 {
                sleepData.forEach { (sleepKey, startDate, value) in
                    healthModels.append(HealthModel(time: self.healthDateFormattor.string(from: startDate), measurement: user.experimentID, tags: tag, fields: HealthFilds(transmitTtrigger: trigger, healthKey: self.addPrefixForDataKey(key: sleepKey), healthValue: value)))
                }
                completion(healthModels, samples)
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
        case HKObjectType.categoryType(forIdentifier: .sleepAnalysis):
            return HeathDataKeys.sleepAnalysisKey.rawValue
        case HKObjectType.quantityType(forIdentifier: .appleSleepingWristTemperature):
            return HeathDataKeys.wristTemperatureKey.rawValue
        default:
            return ""
        }
    }
    
    private func keyForSleepAnalysis(value: Int) -> String {
        switch value {
        case HKCategoryValueSleepAnalysis.inBed.rawValue:
            return HeathDataKeys.sleepInBed.rawValue
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            return HeathDataKeys.sleepAwake.rawValue
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            return HeathDataKeys.sleepREM.rawValue
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            return HeathDataKeys.sleepCore.rawValue
        case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
            return HeathDataKeys.sleepUnspecified.rawValue
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            return HeathDataKeys.sleepDeep.rawValue
        default:
            return ""
        }
    }
    
    private func addPrefixForDataKey(key: String) -> String {
        return dataPrefix + key
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
        case HKObjectType.quantityType(forIdentifier: .appleSleepingWristTemperature):
            data = sample.quantity.doubleValue(for: HKUnit.degreeCelsius())
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
        
        // testLog(trigger: trigger, details: "WS:Sending HealthKit data started", state: "triggered")
        
        // prevent data from being sent if a previous send has not completed
        if HealthKitInteractor.sendDataInProgress {
            completion?(false)
            // testLog(trigger: trigger, details: "WS:Sending HealthKit data suspended (previous send has not completed)", state: "error")
            return
        }
        
        // check if the timeout has expired
        var sendTimeout: Double = 25 * 60 // 25 minutes by default
        if let customTimeout = timeout {
            sendTimeout = customTimeout
        }
        
        if ((Date().timeIntervalSince1970 - storage.healthLastSyncedTimeInterval()) - sendTimeout) < 0 {
            HealthKitInteractor.sendDataInProgress = false
            completion?(false)
            // testLog(trigger: trigger, details: "WS:Minimum time interval not reached", state: "error")
            return
        }
        
        HealthKitInteractor.sendDataInProgress = true
        
        self.requestHealthAuth { [weak self]  success in
            
            guard let self else { return }
            
            if !success, !HealthKitInteractor.sendDataInProgress {
                HealthKitInteractor.sendDataInProgress = false
                completion?(success)
                // self.testLog(trigger: trigger, details: "WS: (HealthKit) Permission not granted or sending data in progress", state: "error")
                return
            }
            
            self.getAllRequestedData(trigger: trigger) { models in
                if let writeInfo = self.backendData.apiWriteInfo, !models.isEmpty {
                    do {
                        let bodyJson = try JSONEncoder().encode(models)
                        
                        // log data
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .withoutEscapingSlashes
                        let json = try? encoder.encode(models)
                        if let json {
                            self.logger.logInfo(action: "", info: String(data: json, encoding: .utf8) ?? "")
                        }
                        
                        self.service.post(url: writeInfo.wUrl, body: bodyJson, key: writeInfo.wKey) { result in
                            switch result {
                            case .success(_):
                                let lastUpdateDate = Date()
                                self.storage.healthUpdateLastSyncedTimeInterval(lastUpdateDate.timeIntervalSince1970)
                                
                                self.allTypes.forEach { obj in
                                    self.storage.healthUpdateFromTempLastSyncedTimeInterval(key: self.healthKeyFor(simple: obj))
                                }
                                
                                HealthKitInteractor.sendDataInProgress = false
                                // self.testLog(trigger: trigger, details: "WS: (HealthKit)Data sent -> date:\(lastUpdateDate)", state: "success")
                                completion?(true)
                                
                            case .failure(let error):
                                HealthKitInteractor.sendDataInProgress = false
                                debugPrint(error.localizedDescription)
                                // self.testLog(trigger: trigger, details: "WS:(HealthKit)Service error: \(error.localizedDescription)", state: "error")
                                completion?(false)
                            }
                        }
                    } catch let error {
                        HealthKitInteractor.sendDataInProgress = false
                        debugPrint(error.localizedDescription)
                        // self.testLog(trigger: trigger, details: "WS: (HealthKit)Encoding error: \(error.localizedDescription)", state: "error")
                        completion?(false)
                    }
                } else {
                    HealthKitInteractor.sendDataInProgress = false
                    
                    debugPrint("Backend not configured or empty data!")
                    if models.isEmpty {
                        // self.testLog(trigger: trigger, details: "WS: Empty HealthKit data!", state: "info")
                    } else {
                        // self.testLog(trigger: trigger, details: "WS: Backend not configured or empty HealthKit data!", state: "info")
                    }
                    completion?(false)
                }
            }
        }
    }
    
    // log test
//    private func testLog(trigger: String, details: String, state: String = "error") {
//        if dataPrefix == "ts" {
//            return
//        }
//
//        let str =
//        """
//        {
//        "trigger": "\(trigger)",
//        "si_health_kit_state": "\(state)",
//        "si_health_kit_details": "\(details)"
//        }
//        """
//        logger.logInfo(action: "", info: str)
//    }
}

