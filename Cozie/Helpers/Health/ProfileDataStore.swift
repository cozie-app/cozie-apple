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
    static var backgroundQuery: HKQuery?
    
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
    
    static func getNoise(completion:@escaping(Double?) ->  Void) {
        guard let noice = HKSampleType.quantityType(forIdentifier: .environmentalAudioExposure) else {
            print("noice Sample Type is no longer available in HealthKit")
            return
        }
        var result: Double? = nil
        
        self.getMostRecentSample(for: noice) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    print("error: \(error)")
                }
                return
            }
            result = sample.quantity.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
            completion(result)
        }
    }
    
    static func getHeartRate(completion:@escaping(Double?) ->  Void) {
        
        guard let heartRate = HKSampleType.quantityType(forIdentifier: .heartRate) else {
          print("heartRate Sample Type is no longer available in HealthKit")
          return
        }
        var result: Double? = nil
        
        self.getMostRecentSample(for: heartRate) { (sample, error) in
          
          guard let sample = sample else {
          
            if let error = error {
                print("error: \(error)")
            }
            return
          }
            result = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(result)
        }
    }
    
    static func getBloodOxygen(completion:@escaping(Double?) ->  Void) {
        guard let bloodOxygen = HKSampleType.quantityType(forIdentifier: .oxygenSaturation) else {
          print("bloodOxygen Sample Type is no longer available in HealthKit")
          return
        }
        var blood: Double? = nil
        
        self.getMostRecentSample(for: bloodOxygen) { (sample, error) in
          
          guard let sample = sample else {
          
            if let error = error {
                print("error: \(error)")
            }
            return
          }
            blood = sample.quantity.doubleValue(for: HKUnit(from: "%/min")) //HKUnit(from: "%") * 100.0
            completion(blood)
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
    
    static private func setUpBackgroundDeliveryForDataTypes(types: Set<HKObjectType>) {
        for type in types {
            guard let sampleType = type as? HKSampleType else { print("ERROR: \(type) is not an HKSampleType"); continue }
            self.backgroundQuery = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, error) in
                debugPrint("observer query update handler called for type \(type), error: \(String(describing: error))")
                self.queryForUpdates(type: type)
                completionHandler()
            }
            if let query = self.backgroundQuery {
                healthStore.execute(query)
                healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { (success, error) in
                    debugPrint("enableBackgroundDeliveryForType handler called for \(type) - success: \(success), error: \(String(describing: error))")
                }
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
            debugPrint("HKQuantityTypeIdentifier environmentalAudioExposure")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!:
            debugPrint("HKQuantityTypeIdentifier oxygenSaturation")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!:
            debugPrint("HKQuantityTypeIdentifier heartRate")
        case is HKWorkoutType:
            debugPrint("HKWorkoutType")
        default: debugPrint("Unhandled HKObjectType: \(type)")
        }
    }
    
    static private func dataTypesToRead() -> Set<HKObjectType> {
        return Set(arrayLiteral:
                    HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                   HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
                   HKObjectType.workoutType())
    }
}

//self.setUpBackgroundDeliveryForDataTypes(types: dataTypesToRead())
