//
//  HealthKitInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 13.04.23.
//

import Foundation
import HealthKit

protocol HealthKitInteractorProtocol {
    func getAllRequestedData(trigger: String, completion: ((_ models: [HealthModel])->())?)
    func sendData(trigger: String, timeout: Double?, healthCache: [HealthModel]?, completion: ((_ success: Bool)->())?)
}

final class HealthKitInteractor: HealthKitInteractorProtocol {
    static let minInterval: Double = 60
    enum HealthValueType: Int {
        case workout, sleep, apnea
    }
    
    typealias HealthValue = (type: HealthValueType, key: String, startDate: Date, value: Double)
    
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
        
        // workaut
        case workout = "_workout"
        case workoutType = "_workout_type"
        case workoutDuration = "_workout_duration"
        case activeEnergyBurned = "_active_energy_burned"
        case moveTime = "_move_time"
        case exerciseTime = "_exercise_time"
        
        // Apnea
        case apneaEvent = "_sleep_apnea_duration_minutes"
        case apneaEventTrigger = "_sleep_apnea_duration_minutes_trigger"
        
        // Device:
        case watch = "_watch"
        case phone = "_phone"
    }

    
    private let healthStore = HKHealthStore()
    private let storage: CozieStorageProtocol
    private let userData: UserDataProtocol
    private let backendData: BackendDataProtocol
    private let service: BaseRepository = BaseRepository()
    let offlineMode = OfflineModeManager()
    
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
                          HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
                          //new
                          .workoutType(),
                          HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                          HKObjectType.quantityType(forIdentifier: .appleMoveTime)!,
                          HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!]
    
    let allWatchTypes = [HKObjectType.quantityType(forIdentifier: .heartRate)!,
                         HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                         HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,
                         HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)!,
                         HKObjectType.quantityType(forIdentifier: .stepCount)!,
                         HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                         HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                         HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                         HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                         HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
                         //new
                         .workoutType(),
                         HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                         HKObjectType.quantityType(forIdentifier: .appleMoveTime)!,
                         HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!]
    
    let allTypes: Set<HKSampleType>
    let lock = NSLock()

    init(storage: CozieStorageProtocol, userData: UserDataProtocol, backendData: BackendDataProtocol, logger: LoggerProtocol, transmitTrigger: String = "background_task", dataPrefix: String = "ts") {
        self.storage = storage
        self.userData = userData
        self.backendData = backendData
        self.logger = logger
        self.dataPrefix = dataPrefix
        self.transmitTrigger = transmitTrigger
#if os(iOS)
        if #available(iOS 16, *) {
            var setTypes = Set(allTypesiPhone)
            setTypes.insert(HKQuantityType(HKQuantityTypeIdentifier.appleSleepingWristTemperature))
            if #available(iOS 18, *) {
                setTypes.insert(HKCategoryType(.sleepApneaEvent))
            }
            allTypes = setTypes
        } else {
            allTypes = Set(allTypesiPhone)
        }
#else
        if #available(watchOS 9, *), Self.isWatchUltraOr9() {
            var setTypes = Set(allWatchTypes)
            setTypes.insert(HKQuantityType(HKQuantityTypeIdentifier.appleSleepingWristTemperature))
            if #available(watchOS 11, *) {
                setTypes.insert(HKCategoryType(.sleepApneaEvent))
            }
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
    
    // MARK: - Request Health Auth
    func requestHealthAuth(completion: ((_ success: Bool)->())? = nil) {
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
                                   completion: @escaping ([HKQuantitySample], [HealthValue], Error?) -> Swift.Void) {
        var lastSync = Date().timeIntervalSince1970
        let typeKey = healthKeyFor(simple: sampleType)
        
        // save last sync time for each data
        let lastSavedSync = storage.healthLastSyncedTimeInterval(key: typeKey, offline: offlineMode.isEnabled)
        let maxInterval: Double = storage.maxHealthCutOffInterval() * (60*60*24)
        
        if lastSavedSync > 0 {
            let interval = lastSync - lastSavedSync
            if interval < maxInterval {
                lastSync = lastSavedSync
            } else {
                lastSync = lastSync - maxInterval
            }
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
            if samples?.isEmpty ?? true {
                completion([], [], error)
                return
            }
            // Apnea Event
            if typeKey == HeathDataKeys.apneaEvent.rawValue {
                guard let apneaEventSamples = samples as? [HKCategorySample], let self = self else {
                    completion([], [], error)
                    return
                }
                
                var lastSyncInterval = 0.0
                apneaEventSamples.forEach { obj in
                    let interval = obj.endDate.timeIntervalSince1970
                    debugPrint("Interval for symple:\(interval)")
                    if interval > lastSyncInterval {
                        lastSyncInterval = interval
                        debugPrint("Update interval for symple:\(interval)")
                    }
                }
                if lastSyncInterval > 0 {
                    storage.healthUpdateTempLastSyncedTimeInterval(lastSyncInterval, key: typeKey, offline: offlineMode.isEnabled)
                }
                var apneaSamples: [HealthValue] = []
                apneaEventSamples.forEach { sample in
                    apneaSamples.append((.apnea, HeathDataKeys.apneaEvent.rawValue, sample.startDate, sample.startDate.distance(to: sample.endDate)/60))
                }
                
                completion([], apneaSamples, nil)
                return
            }
            // Sleep Analysis
            if typeKey == HeathDataKeys.sleepAnalysisKey.rawValue {
                guard let sleepSamples = samples as? [HKCategorySample], let self = self else {
                    completion([], [], error)
                    return
                }
                
                var lastSyncInterval = 0.0
                var sleepData: [HealthValue] = []
                for sleepSample in sleepSamples {
                    let sleepKey = self.keyForSleepAnalysis(value: sleepSample.value)
                    if !sleepKey.isEmpty {
                        let lastInterval = sleepSample.endDate.timeIntervalSince1970
                        if lastSyncInterval < lastInterval {
                            lastSyncInterval = lastInterval
                        }
                        if lastInterval > lastSync {
                            sleepData.append((.sleep, sleepKey, sleepSample.startDate, sleepSample.startDate.distance(to: sleepSample.endDate)/60))
                        }
                    }
                }
                
                if lastSyncInterval > 0, !sleepData.isEmpty {
                    self.storage.healthUpdateTempLastSyncedTimeInterval(lastSyncInterval, key: typeKey, offline: offlineMode.isEnabled)
                }
                
                completion([], sleepData, nil)
            } else if let samplesWorkout = samples as? [HKWorkout] {
                var lastSyncInterval = 0.0
                var workoutData: [HealthValue] = []
                for sampleWorkout in samplesWorkout {
                    if !typeKey.isEmpty {
                        let lastInterval = sampleWorkout.endDate.timeIntervalSince1970
                        if lastSyncInterval < lastInterval {
                            lastSyncInterval = lastInterval
                        }
                        if lastInterval > lastSync {
                            workoutData.append((.workout, HeathDataKeys.workoutType.rawValue, sampleWorkout.startDate, Double(sampleWorkout.workoutActivityType.rawValue)))
                            workoutData.append((.workout, HeathDataKeys.workoutDuration.rawValue, sampleWorkout.startDate, sampleWorkout.duration))
                        }
                    }
                }
                
                if lastSyncInterval > 0 {
                    self?.storage.healthUpdateTempLastSyncedTimeInterval(lastSyncInterval, key: typeKey, offline: self?.offlineMode.isEnabled ?? false)
                }
                
                completion([], workoutData, nil)
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
                    self?.storage.healthUpdateTempLastSyncedTimeInterval(lastSyncInterval, key: typeKey, offline: self?.offlineMode.isEnabled ?? false)
                }
                //self?.testLog(trigger: "(HealthKit)Samples for -> (\(typeKey))", details: "Last sync interval: (\(lastSyncInterval))", state: "info")
                //
                
                completion(samples, [], nil)
            }
        }
        
        healthStore.execute(sampleQuery)
    }
    // MARK: - Helfer
    private let healthDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.defaultFormat
        return dateFormatter
    }()
    
    // MARK: - Get HealthKit Data
    private func getDataObject(type: HKSampleType?, trigger: String, completion: @escaping ([HealthModel], [HKQuantitySample]) -> Void) {
        guard let type = type, let user = userData.userInfo else {
            debugPrint("\(String(describing: type)) Sample Type is no longer available in HealthKit or User not exist")
            completion([], [])
            return
        }
        
        let tag = Tags(idOnesignal: storage.playerID(), idParticipant: user.participantID, idPassword: user.passwordID)
        
        getLastDaySamples(for: type) { [weak self] (samples, healthData, error) in
            guard let self = self else {
                return
            }
            
            var healthModels: [HealthModel] = []
            
            if samples.count > 0 {
                let lastSuccessTimestamp = self.storage.healthLastSyncedTimeInterval(key: self.healthKeyFor(simple: type), offline: offlineMode.isEnabled)
                
                let group = DispatchGroup()
                let lock = NSLock()
                samples.forEach({
                    let sample = $0
                    
                    group.enter()
                    self.convertToUnit(sample: $0, type: type) { value in
                        // reject value with start time less than last update time
                        if sample.startDate.timeIntervalSince1970 <= lastSuccessTimestamp {
                            
                            // self.testLog(trigger: trigger, details: "Reject value with start time:\(sample.startDate.timeIntervalSince1970) less than last update time:\(lastSuccessTimestamp)", state: "error")
                            group.leave()
                            return
                        }
                        
                        let currentDataString = self.healthDateFormatter.string(from: sample.startDate)
                        
                        if let lastModel = healthModels.last {
                            // prevent value duplicates
                            if lastModel.time != currentDataString {
                                lock.lock()
                                healthModels.append(self.healthModel(type: type, sample: sample, user: user, tag: tag, currentDataString: currentDataString, trigger: trigger, value: value))
                                lock.unlock()
                                //
                                // self.testLog(trigger: trigger, details: "Added simples with start date:\(sample.startDate.timeIntervalSince1970) last update time:\(lastSuccessTimestamp)", state: "info")
                            }
                        } else {
                            lock.lock()
                            healthModels.append(self.healthModel(type: type, sample: sample, user: user, tag: tag, currentDataString: currentDataString, trigger: trigger, value: value))
                            lock.unlock()
                            // self.testLog(trigger: trigger, details: "Added simples with start date:\(sample.startDate.timeIntervalSince1970) last update time:\(lastSuccessTimestamp)", state: "info")
                        }
                        group.leave()
                    }
                })
                
                group.notify(queue: DispatchQueue.global()) {
                    completion(healthModels, samples)
                }
                
            } else if healthData.count > 0 {
                // Apnea event
                if healthData.first?.type == .apnea {
                    healthData.forEach { sample in
                        let customTrigger = self.addPrefixForDataKey(key: HeathDataKeys.apneaEventTrigger.rawValue)
                        
                        healthModels.append(HealthModel(time: self.healthDateFormatter.string(from: sample.startDate), measurement: user.experimentID, tags: tag, fields: HealthFields(transmitTrigger: customTrigger, healthKey: self.addPrefixForDataKey(key: sample.key), healthValue: sample.value)))
                    }
                    completion(healthModels, samples)
                    
                    // With units (steps, hr...)
                } else if healthData.first?.type == .workout {
                    healthData.forEach { (type, workoutKey, startDate, value) in
                        if workoutKey == HeathDataKeys.workoutType.rawValue {
                            healthModels.append(HealthModel(time: self.healthDateFormatter.string(from: startDate), measurement: user.experimentID, tags: tag, fields: HealthFields(transmitTrigger: trigger, healthKey: self.addPrefixForDataKey(key: workoutKey), healthValue: value, healthStringValue: HKWorkoutActivityType(rawValue: UInt(value))?.name ?? "")))
                        } else {
                            healthModels.append(HealthModel(time: self.healthDateFormatter.string(from: startDate), measurement: user.experimentID, tags: tag, fields: HealthFields(transmitTrigger: trigger, healthKey: self.addPrefixForDataKey(key: workoutKey), healthValue: value)))
                        }
                    }
                    completion(healthModels, samples)
                } else if healthData.first?.type == .sleep {
                    healthData.forEach { (type, sleepKey, startDate, value) in
                        healthModels.append(HealthModel(time: self.healthDateFormatter.string(from: startDate), measurement: user.experimentID, tags: tag, fields: HealthFields(transmitTrigger: trigger, healthKey: self.addPrefixForDataKey(key: sleepKey), healthValue: value)))
                    }
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
    
    private func healthModel(type: HKSampleType, sample: HKQuantitySample, user: CUserInfo, tag: Tags, currentDataString: String, trigger: String, value: Double?) -> HealthModel {

        if type == HKObjectType.quantityType(forIdentifier: .stepCount) || type == HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) {
            let endDataString = self.healthDateFormatter.string(from: sample.endDate)
            return HealthModel(time: currentDataString/*self.healthDateFormatter.string(from: sample.startDate)*/, measurement: user.experimentID, tags: tag, fields: HealthFields(transmitTrigger: trigger, healthKey: self.addPrefixForDataKey(key: self.healthKeyFor(simple: type), device: sample.device), healthValue: value ?? 0.0, /*startTime: currentDataString,*/ endTime: endDataString))
        } else {
            return HealthModel(time: currentDataString/*self.healthDateFormatter.string(from: sample.startDate)*/, measurement: user.experimentID, tags: tag, fields: HealthFields(transmitTrigger: trigger, healthKey: self.addPrefixForDataKey(key: self.healthKeyFor(simple: type)), healthValue: value ?? 0.0))
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
        case .workoutType():
            return HeathDataKeys.workout.rawValue
        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned):
            return HeathDataKeys.activeEnergyBurned.rawValue
        case HKObjectType.quantityType(forIdentifier: .appleMoveTime):
            return HeathDataKeys.moveTime.rawValue
        case HKObjectType.quantityType(forIdentifier: .appleExerciseTime):
            return HeathDataKeys.exerciseTime.rawValue
        default:
            return healthKeyForiOS18(simple: simple)
        }
    }
    
    private func healthKeyForiOS18(simple: HKSampleType) -> String {
#if os(iOS)
        if #available(iOS 18, *) {
            switch simple {
            case HKObjectType.categoryType(forIdentifier: .sleepApneaEvent):
                return HeathDataKeys.apneaEvent.rawValue
            default:
                return ""
            }
        } else {
            return ""
        }
#else
        if #available(watchOS 11, *), Self.isWatchUltraOr9() {
            switch simple {
            case HKObjectType.categoryType(forIdentifier: .sleepApneaEvent):
                return HeathDataKeys.apneaEvent.rawValue
            default:
                return ""
            }
        } else {
            return ""
        }
#endif
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
    
    private func addPrefixForDataKey(key: String, device: HKDevice? = nil) -> String {
        if let name = device?.model {
            return dataPrefix + key + (name.lowercased().contains("phone") ? HeathDataKeys.phone.rawValue : HeathDataKeys.watch.rawValue)
        }
        return dataPrefix + key
    }
    
    private func convertToUnit(sample: HKQuantitySample, type: HKSampleType, completion: @escaping (Double?) -> Void) {
        
        var data: Double? = nil
        // TO DO: chage to -> type.identifier
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
            //        case .workoutType():
            //            return HeathDataKeys.workout.rawValue
        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned):
            data = sample.quantity.doubleValue(for: .kilocalorie())
        case HKObjectType.quantityType(forIdentifier: .appleMoveTime):
            data = sample.quantity.doubleValue(for: .minute())
        case HKObjectType.quantityType(forIdentifier: .appleExerciseTime):
            data = sample.quantity.doubleValue(for: .minute())
        default:
            break
        }
        completion(data)
    }
    
    // MARK: - Update Sync And Log Date
    private func updateSyncAndLogDate() {
        let lastUpdateDate = Date()
        self.storage.healthUpdateLastSyncedTimeInterval(lastUpdateDate.timeIntervalSince1970, offline: self.offlineMode.isEnabled)
        
        self.allTypes.forEach { obj in
            self.storage.healthUpdateFromTempLastSyncedTimeInterval(key: self.healthKeyFor(simple: obj), offline: self.offlineMode.isEnabled)
        }
        
        updateLogDate(date: lastUpdateDate)
    }
    
    private func updateLogDate(date: Date) {
        // update offline date
        self.storage.healthUpdateLastSyncedTimeInterval(date.timeIntervalSince1970, offline: true)
        self.allTypes.forEach { obj in
            self.storage.healthUpdateFromTempLastSyncedTimeInterval(key: self.healthKeyFor(simple: obj), offline: true)
        }
    }
    // MARK: -
    
    private func filterLoggedData(models: [HealthModel]) -> [HealthModel] {
        let loggedTimeInterval = self.storage.healthLastSyncedTimeInterval(offline: true)
        let filteredData = models.filter { model in
            if let date = self.healthDateFormatter.date(from: model.time) {
                return date.timeIntervalSince1970 > loggedTimeInterval
            } else {
                return false
            }
        }
        
        return filteredData
    }
    
    private func logModelsIfNeeded(encoder: JSONEncoder, models: [HealthModel]) {
        let loggedData = filterLoggedData(models: models)
        if !loggedData.isEmpty {
            let json = try? encoder.encode(loggedData)
            if let json {
                self.logger.logInfo(action: "", info: String(data: json, encoding: .utf8) ?? "")
            }
        }
    }
    
    // MARK: - Get All Requested Data
    func getAllRequestedData(trigger: String = CommunicationKeys.syncBackgroundTaskTrigger.rawValue, completion: ((_ models: [HealthModel])->())?) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            var list: [HealthModel] = []
            
            let group = DispatchGroup()
            for type in self.allTypes {
                group.enter()
                debugPrint("\(type) enter")
                self.getDataObject(type: type, trigger: trigger) { infos, simples in
                    self.lock.lock()
                    list.append(contentsOf: infos)
                    debugPrint("\(type) leav")
                    group.leave()
                    self.lock.unlock()
                }
            }
            
            group.notify(queue: DispatchQueue.global()) {
                completion?(list)
            }
        }
    }
    
    // MARK: - Send And Log Date
    func sendData(trigger: String = CommunicationKeys.syncBackgroundTaskTrigger.rawValue, timeout: Double? = nil, healthCache: [HealthModel]? = nil, completion: ((_ success: Bool)->())?) {
        
        // testLog(trigger: trigger, details: "WS:Sending HealthKit data started", state: "triggered")
        
        // update offline status
        updateState()
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
        
        if ((Date().timeIntervalSince1970 - storage.healthLastSyncedTimeInterval(offline: offlineMode.isEnabled)) - sendTimeout) < 0 {
            HealthKitInteractor.sendDataInProgress = false
            completion?(false)
            // testLog(trigger: trigger, details: "WS:Minimum time interval not reached", state: "error")
            return
        }
        
        HealthKitInteractor.sendDataInProgress = true
        
        if let cache = healthCache {
            self.sendHealthKitData(models: cache, completion: completion)
        } else {
            self.requestHealthAuth { [weak self]  success in
                
                guard let self else { return }
                
                if !success, !HealthKitInteractor.sendDataInProgress {
                    HealthKitInteractor.sendDataInProgress = false
                    completion?(success)
                    // self.testLog(trigger: trigger, details: "WS: (HealthKit) Permission not granted or sending data in progress", state: "error")
                    return
                }
                
                self.getAllRequestedData(trigger: trigger) { models in
                    self.sendHealthKitData(models: models, completion: completion)
                }
            }
        }
    }
    
    func requestHealthData(trigger: String = CommunicationKeys.syncBackgroundTaskTrigger.rawValue, completion:((_ models: [HealthModel]?)->())?) {
        self.requestHealthAuth { [weak self]  success in
            
            guard let self else { return }
            
            if !success {
                completion?(nil)
            }
            
            self.getAllRequestedData(trigger: trigger) { models in
                completion?(models)
            }
        }
    }
    
    func sendHealthKitData(models: [HealthModel], completion: ((_ success: Bool)->())?) {
        if let writeInfo = self.backendData.apiWriteInfo, !models.isEmpty {
            do {
                let bodyJson = try JSONEncoder().encode(models)
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .withoutEscapingSlashes
                
                // log data
                // filtering of logged data
                if !self.offlineMode.isEnabled && self.storage.healthLastSyncedTimeInterval(offline: true) < self.storage.healthLastSyncedTimeInterval(offline: false) {
                    self.logModelsIfNeeded(encoder: encoder, models: models)
                } else {
                    // filtering of logged data
                    if self.storage.healthLastSyncedTimeInterval(offline: true) > self.storage.healthLastSyncedTimeInterval(offline: false) {
                        self.logModelsIfNeeded(encoder: encoder, models: models)
                    } else {
                        let json = try? encoder.encode(models)
                        if let json {
                            self.logger.logInfo(action: "", info: String(data: json, encoding: .utf8) ?? "")
                        }
                    }
                    // prevent request in offline mode
                    if self.offlineMode.isEnabled {
                        let lastUpdateDate = Date()
                        self.updateLogDate(date: lastUpdateDate)
                        
                        HealthKitInteractor.sendDataInProgress = false
                        // self.testLog(trigger: trigger, details: "WS:(HealthKit)Service error: \(error.localizedDescription)", state: "error")
                        completion?(false)
                        return
                    }
                }
                
                self.service.post(url: writeInfo.wUrl, body: bodyJson, key: writeInfo.wKey) { result in
                    switch result {
                    case .success(_):
                        self.updateSyncAndLogDate()
                        
                        HealthKitInteractor.sendDataInProgress = false
                        // self.testLog(trigger: trigger, details: "WS: (HealthKit)Data sent -> date:\(lastUpdateDate)", state: "success")
                        completion?(true)
                        
                    case .failure(let error):
                        self.updateLogDate(date: Date())
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
    
    func updateState() {
        if let info = backendData.apiWriteInfo {
            offlineMode.updateWith(apiInfo: info)
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

extension HKWorkoutActivityType {
    
    /*
     Simple mapping of available workout types to a human readable name.
     */
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"
            
            // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"
            
            // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Mixed Cardio"
        case .handCycling:                  return "Hand Cycling"
            
            // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"
            
            // Catch-all
        default:                            return "Other"
        }
    }
    
}

