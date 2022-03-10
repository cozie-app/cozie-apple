//
//  HealthKitSetupAssistant.swift
//  Cozie
//
//  Created by Square Infosoft on 18/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
              let leanBodyMass = HKObjectType.quantityType(forIdentifier: .leanBodyMass),
              let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let restingHertRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
              let bodyTemperature = HKObjectType.quantityType(forIdentifier: .bodyTemperature),
              let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate),
              let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
              let distanceCycling = HKObjectType.quantityType(forIdentifier: .distanceCycling),
              let uvExposure = HKObjectType.quantityType(forIdentifier: .uvExposure),
              let flightClimbed = HKObjectType.quantityType(forIdentifier: .flightsClimbed),
              let time = HKObjectType.quantityType(forIdentifier: .appleStandTime),
              let noise = HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure),
              let headphoneAudio = HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure),
              let distanceSwimming = HKObjectType.quantityType(forIdentifier: .distanceSwimming),
              let distanceRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
              let vo2Max = HKObjectType.quantityType(forIdentifier: .vo2Max),
              let peakExpiratoryRate = HKObjectType.quantityType(forIdentifier: .peakExpiratoryFlowRate),
              let heartRateVariability = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
              let walkingHeartRate = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage),
              let bloodOxygen = HKObjectType.quantityType(forIdentifier: .oxygenSaturation),
              let bloodPressureSystolic = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
              let bloodPressureDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic),
              let basalBodyTemperature = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature) else {
                  completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = []
        
        let healthKitTypesToRead: Set<HKObjectType> = [bodyMass, bodyMassIndex, leanBodyMass, heartRate, restingHertRate, bodyTemperature, respiratoryRate, stepCount, distanceCycling, uvExposure, flightClimbed, time, noise, headphoneAudio, distanceSwimming, distanceRunning, vo2Max, peakExpiratoryRate, heartRateVariability, walkingHeartRate, bloodOxygen, bloodPressureSystolic, bloodPressureDiastolic, basalBodyTemperature]
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
}
