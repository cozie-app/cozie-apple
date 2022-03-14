//
//  ProfileDataStore.swift
//  Cozie
//
//  Created by Square Infosoft on 18/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import HealthKit

final class ProfileDataStore {
    
    static let healthStore = HKHealthStore()
    static var backgroundQuery: [HKQuery]?
    
    static private func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: 1,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                          completion(nil, error)
                          return
                      }
                completion(mostRecentSample, nil)
            }
        }
        healthStore.execute(sampleQuery)
    }
    
    static private func getData(type: HKSampleType?, completion:@escaping(Double?) ->  Void) {
        guard let type = type else {
            print("\(String(describing: type)) Sample Type is no longer available in HealthKit")
            return
        }
        var data: Double? = nil
        
        self.getMostRecentSample(for: type) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    print("error: \(error)")
                }
                return
            }
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
                data = sample.quantity.doubleValue(for: HKUnit(from: "count/s"))
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
            default:
                break
            }
            if #available(iOS 14.0, *) {
                switch type {
                case HKSampleType.quantityType(forIdentifier: .walkingSpeed):
                    data = sample.quantity.doubleValue(for: HKUnit(from: "km/hr"))
                case HKSampleType.quantityType(forIdentifier: .sixMinuteWalkTestDistance), HKSampleType.quantityType(forIdentifier: .walkingStepLength):
                    data = sample.quantity.doubleValue(for: HKUnit.meter())
                case HKSampleType.quantityType(forIdentifier: .walkingAsymmetryPercentage), HKSampleType.quantityType(forIdentifier: .walkingDoubleSupportPercentage):
                    data = sample.quantity.doubleValue(for: HKUnit.percent())
                case HKSampleType.quantityType(forIdentifier: .stairAscentSpeed), HKSampleType.quantityType(forIdentifier: .stairDescentSpeed):
                    data = sample.quantity.doubleValue(for: HKUnit(from: "m/s"))
                default:
                    break
                }
            }
            if #available(iOS 15.0, *) {
                switch type {
                case HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness):
                    data = sample.quantity.doubleValue(for: HKUnit.percent())
                default:
                    break
                }
            }
            completion(data)
        }
    }
}

extension ProfileDataStore {
    
//    static func getList() {
//        var results: [Double] = []
//        self.getSamples(for: heartRate) { (samples, error) in
//            guard let samples = samples else {
//
//                if let error = error {
//                    print("error: \(error)")
//                }
//                return
//            }
//            samples.forEach { sample in
//                results.append(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
//            }
//            print(results)
//        }
//    }

    static private func getSamples(for sampleType: HKSampleType,
                                   completion: @escaping ([HKQuantitySample]?, Error?) -> Swift.Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let someDateTime = formatter.date(from: "2020/11/30 22:31")
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: someDateTime,
                                                              end: Date(),
                                                              options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: 20,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples as? [HKQuantitySample] else {
                          completion(nil, error)
                          return
                      }
                completion(mostRecentSample, nil)
            }
        }
        healthStore.execute(sampleQuery)
    }
    
    static func setUpBackgroundDeliveryForDataTypes() {
        let types = self.dataTypesToRead()
        for type in types {
            guard let sampleType = type as? HKSampleType else { print("ERROR: \(type) is not an HKSampleType"); continue }
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, error) in
                debugPrint("observer query update handler called for type \(type), error: \(String(describing: error))")
                self.queryForUpdates(type: type)
                completionHandler()
            }
            self.backgroundQuery?.append(query)
            if let query = self.backgroundQuery?.last {
                healthStore.execute(query)
                healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { (success, error) in
                    debugPrint("enableBackgroundDeliveryForType handler called for \(type) - success: \(success), error: \(String(describing: error))")
                }
            } else {
                self.queryForUpdates(type: type)
            }
        }
    }
    
    static private func queryForUpdates(type: HKObjectType) {
        // TODO: stop query after receive data 4 times a day
        // if let query = self.backgroundQuery {
        //     healthStore.stop(query)
        // }
        switch type {
        case HKObjectType.quantityType(forIdentifier: .bodyMass)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .bodyMass)) { bodyMass in
                if let bodyMass = bodyMass {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentBodyMass.rawValue, value: bodyMass)
                    Utilities.sendHealthData(data: ["body mass":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentBodyMass.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .bodyMassIndex)) { bodyMassIndex in
                if let bodyMassIndex = bodyMassIndex {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentBodyMassIndex.rawValue, value: bodyMassIndex)
                    Utilities.sendHealthData(data: ["BMI":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentBodyMassIndex.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .leanBodyMass)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .leanBodyMass)) { leanBodyMass in
                if let leanBodyMass = leanBodyMass {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentLeanBodyMass.rawValue, value: leanBodyMass)
                    Utilities.sendHealthData(data: ["leanBodyMass":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentLeanBodyMass.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .heartRate)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .heartRate)) { heartRate in
                if let heartRate = heartRate {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentHeartRate.rawValue, value: heartRate)
                    Utilities.sendHealthData(data: ["heartRate2":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentHeartRate.rawValue) as? Double ?? 0) "])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .restingHeartRate)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .restingHeartRate)) { restingHeartRate in
                if let restingHeartRate = restingHeartRate {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentRestingHeartRate.rawValue, value: restingHeartRate)
                    Utilities.sendHealthData(data: ["restingHeartRate":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentRestingHeartRate.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .bodyTemperature)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .bodyTemperature)) { bodyTemperature in
                if let bodyTemperature = bodyTemperature {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentBodyTemperature.rawValue, value: bodyTemperature)
                    Utilities.sendHealthData(data: ["bodyTemperature":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentBodyTemperature.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .respiratoryRate)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .respiratoryRate)) { respiratoryRate in
                if let respiratoryRate = respiratoryRate {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentRespiratoryRate.rawValue, value: respiratoryRate)
                    Utilities.sendHealthData(data: ["respiratoryRate":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentRespiratoryRate.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .stepCount)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .stepCount)) { stepCount in
                if let stepCount = stepCount {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentStepCount.rawValue, value: stepCount)
                    Utilities.sendHealthData(data: ["stepCount":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentStepCount.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .distanceCycling)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .distanceCycling)) { distanceCycling in
                if let distanceCycling = distanceCycling {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentDistanceCycling.rawValue, value: distanceCycling)
                    Utilities.sendHealthData(data: ["cyclingDistance":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentDistanceCycling.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .uvExposure)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .uvExposure)) { uvExposure in
                if let uvExposure = uvExposure {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentUVExposure.rawValue, value: uvExposure)
                    Utilities.sendHealthData(data: ["UVexposure":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentUVExposure.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .flightsClimbed)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .flightsClimbed)) { flightsClimbed in
                if let flightsClimbed = flightsClimbed {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentFlightsClimbed.rawValue, value: flightsClimbed)
                    Utilities.sendHealthData(data: ["flightsclimbed":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentFlightsClimbed.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .appleStandTime)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .appleStandTime)) { appleStandTime in
                if let appleStandTime = appleStandTime {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentAppleStandTime.rawValue, value: appleStandTime)
                    Utilities.sendHealthData(data: ["standTime":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentAppleStandTime.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .environmentalAudioExposure)) { noise in
                if let noise = noise {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentNoise.rawValue, value: noise)
                    Utilities.sendHealthData(data: ["hearingEnvironmentalExposure":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentNoise.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .headphoneAudioExposure)) { headphoneAudioExposure in
                if let headphoneAudioExposure = headphoneAudioExposure {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentHeadphoneAudioExposure.rawValue, value: headphoneAudioExposure)
                    Utilities.sendHealthData(data: ["hearingHeadhponeExposure":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentHeadphoneAudioExposure.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .distanceSwimming)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .distanceSwimming)) { distanceSwimming in
                if let distanceSwimming = distanceSwimming {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentDistanceSwimming.rawValue, value: distanceSwimming)
                    Utilities.sendHealthData(data: ["swimmingDistance":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentDistanceSwimming.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)) { distanceWalkingRunning in
                if let distanceWalkingRunning = distanceWalkingRunning {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentDistanceWalkingRunning.rawValue, value: distanceWalkingRunning)
                    Utilities.sendHealthData(data: ["walkingDistance":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentDistanceWalkingRunning.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .vo2Max)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .vo2Max)) { vo2Max in
                if let vo2Max = vo2Max {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentVo2Max.rawValue, value: vo2Max)
                    Utilities.sendHealthData(data: ["vo2max":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentVo2Max.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .peakExpiratoryFlowRate)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .peakExpiratoryFlowRate)) { peakExpiratoryFlowRate in
                if let peakExpiratoryFlowRate = peakExpiratoryFlowRate {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentPeakExpiratoryFlowRate.rawValue, value: peakExpiratoryFlowRate)
                    Utilities.sendHealthData(data: ["peakExpiratoryFlowRate":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentPeakExpiratoryFlowRate.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)) { heartRateVariabilitySDNN in
                if let heartRateVariabilitySDNN = heartRateVariabilitySDNN {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentHeartRateVariabilitySDNN.rawValue, value: heartRateVariabilitySDNN)
                    Utilities.sendHealthData(data: ["heartRateVariabilitySDNN":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentHeartRateVariabilitySDNN.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .walkingHeartRateAverage)) { walkingHeartRateAverage in
                if let walkingHeartRateAverage = walkingHeartRateAverage {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentWalkingHeartRateAverage.rawValue, value: walkingHeartRateAverage)
                    Utilities.sendHealthData(data:["walkingHeartRateAverage":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentWalkingHeartRateAverage.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .oxygenSaturation)) { bloodOxygen in
                if let bloodOxygen = bloodOxygen {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentBloodOxygen.rawValue, value: bloodOxygen)
                    Utilities.sendHealthData(data: ["oxygenSaturation":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentBloodOxygen.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)) { bloodPressureSystolic in
                if let bloodPressureSystolic = bloodPressureSystolic {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentBloodPressureSystolic.rawValue, value: bloodPressureSystolic)
                    Utilities.sendHealthData(data: ["bloodPressureSystolic":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentBloodPressureSystolic.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)) { bloodPressureDiastolic in
                if let bloodPressureDiastolic = bloodPressureDiastolic {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentBloodPressureDiastolic.rawValue, value: bloodPressureDiastolic)
                    Utilities.sendHealthData(data: ["bloodPressureDiastolic":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentBloodPressureDiastolic.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .basalBodyTemperature)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .basalBodyTemperature)) { basalBodyTemperature in
                if let basalBodyTemperature = basalBodyTemperature {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentBasalBodyTemperature.rawValue, value: basalBodyTemperature)
                    Utilities.sendHealthData(data: ["basalBodyTemperature":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentBasalBodyTemperature.rawValue) as? Double ?? 0)"])
                }
            }
        case HKObjectType.quantityType(forIdentifier: .dietaryWater)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .dietaryWater)) { dietaryWater in
                if let dietaryWater = dietaryWater {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentDietaryWater.rawValue, value: dietaryWater)
                    Utilities.sendHealthData(data: ["dietaryWater":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentDietaryWater.rawValue) as? Double ?? 0)"])
                }
            }
        case is HKWorkoutType:
            debugPrint("HKWorkoutType")
        default: debugPrint("Unhandled HKObjectType: \(type)")
        }
        
        if #available(iOS 14.0, *) {
            switch type {
            case HKObjectType.quantityType(forIdentifier: .walkingSpeed)!:
                self.getData(type: HKSampleType.quantityType(forIdentifier: .walkingSpeed)) { walkingSpeed in
                    if let walkingSpeed = walkingSpeed {
                        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentWalkingSpeed.rawValue, value: walkingSpeed)
                        Utilities.sendHealthData(data: ["walkingSpeed":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentWalkingSpeed.rawValue) as? Double ?? 0)"])
                    }
                }
            case HKObjectType.quantityType(forIdentifier: .walkingStepLength)!:
                self.getData(type: HKSampleType.quantityType(forIdentifier: .walkingStepLength)) { walkingStepLength in
                    if let walkingStepLength = walkingStepLength {
                        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentWalkingStepLength.rawValue, value: walkingStepLength)
                        Utilities.sendHealthData(data: ["walkingStepLength":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentWalkingStepLength.rawValue) as? Double ?? 0)"])
                    }
                }
            case HKObjectType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)!:
                self.getData(type: HKSampleType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)) { sixMinuteWalkTestDistance in
                    if let sixMinuteWalkTestDistance = sixMinuteWalkTestDistance {
                        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentSixMinuteWalkTestDistance.rawValue, value: sixMinuteWalkTestDistance)
                        Utilities.sendHealthData(data: ["sixMinuteWalkTestDistance":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentSixMinuteWalkTestDistance.rawValue) as? Double ?? 0)"])
                    }
                }
            case HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!:
                self.getData(type: HKSampleType.quantityType(forIdentifier: .walkingAsymmetryPercentage)) { walkingAsymmetryPercentage in
                    if let walkingAsymmetryPercentage = walkingAsymmetryPercentage {
                        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentWalkingAsymmetryPercentage.rawValue, value: walkingAsymmetryPercentage)
                        Utilities.sendHealthData(data: ["walkingAsymmetryPercentage":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentWalkingAsymmetryPercentage.rawValue) as? Double ?? 0)"])
                    }
                }
            case HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!:
                self.getData(type: HKSampleType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)) { walkingDoubleSupportPercentage in
                    if let walkingDoubleSupportPercentage = walkingDoubleSupportPercentage {
                        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentWalkingDoubleSupportPercentage.rawValue, value: walkingDoubleSupportPercentage)
                        Utilities.sendHealthData(data: ["walkingDoubleSupportPercentage":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentWalkingDoubleSupportPercentage.rawValue) as? Double ?? 0)"])
                    }
                }
            case HKObjectType.quantityType(forIdentifier: .stairAscentSpeed)!:
                self.getData(type: HKSampleType.quantityType(forIdentifier: .stairAscentSpeed)) { stairAscentSpeed in
                    if let stairAscentSpeed = stairAscentSpeed {
                        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentStairAscentSpeed.rawValue, value: stairAscentSpeed)
                        Utilities.sendHealthData(data: ["stairAscentSpeed":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentStairAscentSpeed.rawValue) as? Double ?? 0)"])
                    }
                }
            case HKObjectType.quantityType(forIdentifier: .stairDescentSpeed)!:
                self.getData(type: HKSampleType.quantityType(forIdentifier: .stairDescentSpeed)) { stairDescentSpeed in
                    if let stairDescentSpeed = stairDescentSpeed {
                        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentStairDescentSpeed.rawValue, value: stairDescentSpeed)
                        Utilities.sendHealthData(data: ["stairDescentSpeed":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentStairDescentSpeed.rawValue) as? Double ?? 0)"])
                    }
                }
            default: debugPrint("Unhandled HKObjectType: \(type)")
            }
        }
        
        if #available(iOS 15.0, *) {
            switch type {
            case HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)!:
                self.getData(type: HKSampleType.quantityType(forIdentifier: .appleWalkingSteadiness)) { appleWalkingSteadiness in
                    if let appleWalkingSteadiness = appleWalkingSteadiness {
                        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentAppleWalkingSteadiness.rawValue, value: appleWalkingSteadiness)
                        Utilities.sendHealthData(data: ["appleWalkingSteadiness":"\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.recentAppleWalkingSteadiness.rawValue) as? Double ?? 0)"])
                    }
                }
            default: debugPrint("Unhandled HKObjectType: \(type)")
            }
        }
    }
    
    static private func dataTypesToRead() -> Set<HKObjectType> {
        var set = Set(arrayLiteral:
                        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                      HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
                      HKObjectType.quantityType(forIdentifier: .leanBodyMass)!,
                      HKObjectType.quantityType(forIdentifier: .heartRate)!,
                      HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                      HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
                      HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
                      HKObjectType.quantityType(forIdentifier: .stepCount)!,
                      HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                      HKObjectType.quantityType(forIdentifier: .uvExposure)!,
                      HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
                      HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
                      HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,
                      HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)!,
                      HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
                      HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                      HKObjectType.quantityType(forIdentifier: .vo2Max)!,
                      HKObjectType.quantityType(forIdentifier: .peakExpiratoryFlowRate)!,
                      HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                      HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
                      HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                      HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
                      HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
                      HKObjectType.quantityType(forIdentifier: .basalBodyTemperature)!,
                      HKObjectType.quantityType(forIdentifier: .dietaryWater)!)
        
        if #available(iOS 14.0, *) {
            set.insert(HKObjectType.quantityType(forIdentifier: .walkingSpeed)!)
            set.insert(HKObjectType.quantityType(forIdentifier: .walkingStepLength)!)
            set.insert(HKObjectType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)!)
            set.insert(HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!)
            set.insert(HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!)
            set.insert(HKObjectType.quantityType(forIdentifier: .stairAscentSpeed)!)
            set.insert(HKObjectType.quantityType(forIdentifier: .stairDescentSpeed)!)
        }
        
        if #available(iOS 15.0, *) {
            set.insert(HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)!)
        }
        
        return set
    }
}
