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
    let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

    func authorizeHealthKit(completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {

        if !HKHealthStore.isHealthDataAvailable() {
            return
        }

        // Used to define the identifiers that create quantity type objects.
        let healthKitTypes: Set = [
            heartRateType,
            bodyMassType]
        // Requests permission to save and read the specified data types.
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (success, error) in
            completion(success, error)
        }

    }


    //returns the weight entry in Kilos or nil if no data
    func bodyMassKg(completion: @escaping ((_ bodyMass: Double?, _ date: Date?) -> Void)) {

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

    func queryHeartRate(completion: @escaping ((_ hr: [String: Int]?) -> Void)) {

        // We want data points from our current device
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])

        var tmpHearthRate: [String: Int] = [:]

        // It provides us with both the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed.
//        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        let query: HKSampleQuery = HKSampleQuery(sampleType: heartRateType, predicate: devicePredicate, limit: 10,
                sortDescriptors: [sortByDate]) { query, results, error in

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
