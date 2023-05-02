//
//  HealthKitInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 13.04.23.
//

import Foundation
import HealthKit

class HealthKitInteractor {
    let healthStore = HKHealthStore()
    let syncKey = "last_sync_timestamp"
    
    let allTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                        HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,
                        HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)!,
                        HKObjectType.quantityType(forIdentifier: .stepCount)!,
                        HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                        HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
                        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                        HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
                        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
    
    func healthKitInit() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { success, error in
                if success {
                    debugPrint("success")
                }
            }
        } else {
            
        }
    }
    
    private func getLastDaySamples(for sampleType: HKSampleType,
                                          completion: @escaping ([HKQuantitySample], Error?) -> Swift.Void) {
        var lastSync = Date().timeIntervalSince1970 - 3600
        if let lastSavedSync = UserDefaults.standard.value(forKey: syncKey) as? Double {
            lastSync = lastSavedSync
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -1, to: Date(timeIntervalSince1970: TimeInterval(lastSync))),
                end: Date(),
                options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample] else {
                completion([], error)
                return
            }
            completion(samples, nil)
        }
        healthStore.execute(sampleQuery)
    }

    private func getDataObject(type: HKSampleType?, completion: @escaping ([String: Double], [HKQuantitySample]) -> Void) {
        guard let type = type else {
            print("\(String(describing: type)) Sample Type is no longer available in HealthKit")
            return
        }

        getLastDaySamples(for: type) { (samples, error) in

            var dataObj: [String: Double] = [:]

            let group = DispatchGroup()
            if samples.count > 0 {
                samples.forEach({

//                    if let syncedData = UserDefaults.shared.getValue(for: "syncedData\(String(describing: type))") as? [String], syncedData.contains($0.uuid.uuidString) {
//                        return
//                    }

                    let sample = $0
                    group.enter()
//                    fetchData(sample: $0, type: type) { value in
//                        //dataObj[FormatDateISOString(date: sample.startDate)] = value
//                        group.leave()
//                    }
                })
                group.notify(queue: .main) {
                    completion(dataObj, samples)
                }
            } else if let error = error {
                print("error: \(error)")
            }
        }
    }
    
    static private func fetchData(sample: HKQuantitySample, type: HKSampleType, completion: @escaping (Double?) -> Void) {
        
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
    
}

