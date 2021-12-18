//
//  ProfileDataStore.swift
//  Cozie
//
//  Created by Square Infosoft on 18/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import HealthKit

class ProfileDataStore {
    
    private func getMostRecentSample(for sampleType: HKSampleType,
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
        HKHealthStore().execute(sampleQuery)
    }
    
    func getNoise() -> Double? {
        guard let noice = HKSampleType.quantityType(forIdentifier: .environmentalAudioExposure) else {
            print("noice Sample Type is no longer available in HealthKit")
            return nil
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
        }
        return result
    }
    
    func getHeartRate() -> Double? {
        guard let heartRate = HKSampleType.quantityType(forIdentifier: .heartRate) else {
          print("heartRate Sample Type is no longer available in HealthKit")
          return nil
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
        }
        return result
    }
    
    func getBloodOxygen() -> Double? {
        guard let bloodOxygen = HKSampleType.quantityType(forIdentifier: .oxygenSaturation) else {
          print("bloodOxygen Sample Type is no longer available in HealthKit")
          return nil
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
        }
        return blood
    }
    
}
