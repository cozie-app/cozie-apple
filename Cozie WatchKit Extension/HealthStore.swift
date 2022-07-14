//
//  HealthStore.swift
//  Cozie WatchKit Extension
//
//  Created by Federico Tartarini on 6/8/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import HealthKit

class HealthStore {
    // https://stackoverflow.com/questions/45046974/how-to-get-the-most-recent-weight-entry-from-healthkit-data

    private let healthStore = HKHealthStore()
    private let bodyMassType = HKSampleType.quantityType(forIdentifier: .bodyMass)!
    private let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    private let basalEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
    private let noise = HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!
    let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

    func authorizeHealthKit(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {

        if !HKHealthStore.isHealthDataAvailable() {
            return
        }

        // Used to define the identifiers that create quantity type objects.
        let healthKitTypes: Set = [
            heartRateType,
            bodyMassType,
            basalEnergyType,
            noise
        ]
        // Requests permission to save and read the specified data types.
        healthStore.requestAuthorization(toShare: [], read: healthKitTypes) { (success, error) in
            completion(success, error)
        }

    }

    //returns an array of noise levels
    func noiseExposure(completion: @escaping (_ audioExposure: [String: Int]?) -> Void) {

        var tmpNoise: [String: Int] = [:]

        let query: HKSampleQuery = HKSampleQuery(sampleType: noise, predicate: nil, limit: 30,
                sortDescriptors: [sortByDate]) { (query, results, error) in
            if let results = results as? [HKQuantitySample] {

                for sample in results {

                    // date when the HR was sampled
                    let sampledDate = FormatDateISOString(date: sample.startDate)
                    tmpNoise[sampledDate] = Int(sample.quantity.doubleValue(for: HKUnit(from: "dBASPL")))
                }

                completion(tmpNoise)
                return
            }

            //no data
            completion(nil)
        }
        healthStore.execute(query)
    }

    //returns the weight entry in Kilos or nil if no data
    func bodyMassKg(completion: @escaping (_ bodyMass: Double?, _ date: Date?) -> Void) {

        let query = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: 1,
                sortDescriptors: [sortByDate]) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample {
                let bodyMassKg = result.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                completion(bodyMassKg, result.endDate)
                return
            }

            //no data
            completion(nil, nil)
        }
        healthStore.execute(query)
    }

    //returns the weight entry in Kilos or nil if no data
    func basalEnergy(completion: @escaping (_ basalEnergy: Double?, _ date: Date?) -> Void) {

        let query = HKSampleQuery(sampleType: basalEnergyType, predicate: nil, limit: 1,
                sortDescriptors: [sortByDate]) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample {
                let energy = result.quantity.doubleValue(for: HKUnit.init(from: .kilocalorie))
//                let energy = result.quantity.doubleValue(for: HKUnit.(from: HKUnit.kilocalorie()))
                completion(energy, result.endDate)
                return
            }

            //no data
            completion(nil, nil)
        }
        healthStore.execute(query)
    }

    // query heart rate
    func queryHeartRate(completion: @escaping (_ hr: [String: Int]?) -> Void) {

        // We want data points from our current device
//        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])

        var tmpHearthRate: [String: Int] = [:]

        // It provides us with both the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed.
//        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        let query: HKSampleQuery = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 30,
                sortDescriptors: [sortByDate]) { (query, results, error) in

            if let results = results as? [HKQuantitySample] {

                for sample in results {

                    // date when the HR was sampled
                    let sampledDate = FormatDateISOString(date: sample.startDate)
                    tmpHearthRate[sampledDate] = Int(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
                }

                completion(tmpHearthRate)
                return
            }

            completion(nil)
        }

        // optimize I am not waiting for this assignment hence it may be that the survey it is sent before these values are updated
        healthStore.execute(query)
    }

}
