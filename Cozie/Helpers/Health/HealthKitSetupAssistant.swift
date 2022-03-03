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
        
        guard let bloodOxygen = HKObjectType.quantityType(forIdentifier: .oxygenSaturation),
              let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let noise = HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure),
              let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
              let leanBodyMass = HKObjectType.quantityType(forIdentifier: .leanBodyMass),
              let bodyTemperature = HKObjectType.quantityType(forIdentifier: .bodyTemperature),
              let basalBodyTemperature = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature),
              let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate),
              let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = []
        
        let healthKitTypesToRead: Set<HKObjectType> = [noise, heartRate, bloodOxygen, bodyMass, bodyMassIndex, leanBodyMass, bodyTemperature, basalBodyTemperature, respiratoryRate, stepCount]
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
}
