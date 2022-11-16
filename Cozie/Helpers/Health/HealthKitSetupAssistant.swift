//
//  HealthKitSetupAssistant.swift
//  Cozie
//
//  Created by Square Infosoft on 18/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {

    private enum HealthKitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }

    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthKitSetupError.notAvailableOnDevice)
            return
        }

        guard let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
              let leanBodyMass = HKObjectType.quantityType(forIdentifier: .leanBodyMass),
              let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
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
              let basalBodyTemperature = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature),
              let dietaryWater = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            completion(false, HealthKitSetupError.dataTypeNotAvailable)
            return
        }

        let healthKitTypesToWrite: Set<HKSampleType> = []

        var healthKitTypesToRead: Set<HKObjectType> = [bodyMass, bodyMassIndex, leanBodyMass, heartRate, restingHeartRate, bodyTemperature, respiratoryRate, stepCount, distanceCycling, uvExposure, flightClimbed, time, noise, headphoneAudio, distanceSwimming, distanceRunning, vo2Max, peakExpiratoryRate, heartRateVariability, walkingHeartRate, bloodOxygen, bloodPressureSystolic, bloodPressureDiastolic, basalBodyTemperature, dietaryWater]

        if #available(iOS 14.0, *) {
            guard let walkingSpeed = HKObjectType.quantityType(forIdentifier: .walkingSpeed),
                  let walkingStepLength = HKObjectType.quantityType(forIdentifier: .walkingStepLength),
                  let sixMinuteWalkTestDistance = HKObjectType.quantityType(forIdentifier: .sixMinuteWalkTestDistance),
                  let walkingAsymmetryPercentage = HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage),
                  let walkingDoubleSupportPercentage = HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage),
                  let stairAscentSpeed = HKObjectType.quantityType(forIdentifier: .stairAscentSpeed),
                  let stairDescentSpeed = HKObjectType.quantityType(forIdentifier: .stairDescentSpeed) else {
                return
            }
            healthKitTypesToRead.insert(walkingSpeed)
            healthKitTypesToRead.insert(walkingStepLength)
            healthKitTypesToRead.insert(sixMinuteWalkTestDistance)
            healthKitTypesToRead.insert(walkingAsymmetryPercentage)
            healthKitTypesToRead.insert(walkingDoubleSupportPercentage)
            healthKitTypesToRead.insert(stairAscentSpeed)
            healthKitTypesToRead.insert(stairDescentSpeed)
        }

        if #available(iOS 15.0, *) {
            guard let appleWalkingSteadiness = HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness) else {
                return
            }
            healthKitTypesToRead.insert(appleWalkingSteadiness)
        }

        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
}
