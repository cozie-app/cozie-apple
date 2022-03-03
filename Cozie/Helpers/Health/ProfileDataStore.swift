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
    
    static func getData(type: HKSampleType?, completion:@escaping(Double?) ->  Void) {
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
            case HKSampleType.quantityType(forIdentifier: .environmentalAudioExposure):
                data = sample.quantity.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
            case HKSampleType.quantityType(forIdentifier: .heartRate):
                data = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            case HKObjectType.quantityType(forIdentifier: .oxygenSaturation):
                data = sample.quantity.doubleValue(for: HKUnit(from: "%")) * 100
//            case HKObjectType.quantityType(forIdentifier: .bodyMass):
//                data = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))//.count()
            default:
                break
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
        case HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .environmentalAudioExposure)) { noise in
                if let noise = noise {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentNoise.rawValue, value: noise)
                    Utilities.sendHealthData()
                }
            }
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .oxygenSaturation)) { bloodOxygen in
                if let bloodOxygen = bloodOxygen {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentBloodOxygen.rawValue, value: bloodOxygen)
                    Utilities.sendHealthData()
                }
            }
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!:
            self.getData(type: HKSampleType.quantityType(forIdentifier: .heartRate)) { heartRate in
                if let heartRate = heartRate {
                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentHeartRate.rawValue, value: heartRate)
                    Utilities.sendHealthData()
                }
            }
//        case HKObjectType.quantityType(forIdentifier: .bodyMass)!:
//            self.getData(type: HKSampleType.quantityType(forIdentifier: .bodyMass)) { bodyMass in
//                if let bodyMass = bodyMass {
//                    UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.recentBodyMass.rawValue, value: bodyMass)
//                    Utilities.sendHealthData()
//                }
//            }
        case is HKWorkoutType:
            debugPrint("HKWorkoutType")
        default: debugPrint("Unhandled HKObjectType: \(type)")
        }
    }
    
    static private func dataTypesToRead() -> Set<HKObjectType> {
        // TODO: manage
        return Set(arrayLiteral:
                    HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                   HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
                   HKObjectType.quantityType(forIdentifier: .leanBodyMass)!,
                   HKObjectType.quantityType(forIdentifier: .heartRate)!,
                   HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                   HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
                   HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
                   HKObjectType.quantityType(forIdentifier: .stepCount)!,
//                   HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
//                   HKObjectType.quantityType(forIdentifier: .walkingStepLength)!,
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
//                   HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
//                   HKObjectType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)!,
//                   HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
//                   HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!,
//                   HKObjectType.quantityType(forIdentifier: .stairAscentSpeed)!,
//                   HKObjectType.quantityType(forIdentifier: .stairDescentSpeed)!,
//                   HKObjectType.quantityType(forIdentifier: .workou)!,
                   HKObjectType.quantityType(forIdentifier: .basalBodyTemperature)!,
                   HKObjectType.quantityType(forIdentifier: .dietaryWater)!)
    }
}
