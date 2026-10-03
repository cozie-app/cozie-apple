//
//  HealthKitInteractorTests.swift
//  Cozie
//
//  Created by Tesoro on 2026/9/10.
//
import Testing
import HealthKit
@testable import Cozie

@Suite("HealthKitInteractor")
struct HealthKitInteractorTests {

    @Test("Two Apple Watches of the same model get different keys")
    func sameModelDifferentIdentifierProducesDifferentKeys() {
        let watch1 = HKDevice(name: "Apple Watch",
                               manufacturer: "Apple Inc.",
                               model: "Watch7,1",
                               hardwareVersion: nil,
                               firmwareVersion: nil,
                               softwareVersion: nil,
                               localIdentifier: "AAAAAA-1111-1111-1111-111111111111",
                               udiDeviceIdentifier: nil)

        let watch2 = HKDevice(name: "Apple Watch",
                               manufacturer: "Apple Inc.",
                               model: "Watch7,1",
                               hardwareVersion: nil,
                               firmwareVersion: nil,
                               softwareVersion: nil,
                               localIdentifier: "BBBBBB-2222-2222-2222-222222222222",
                               udiDeviceIdentifier: nil)

        let key1 = HealthKitInteractor.addPrefixForDataKey(key: "steps", device: watch1, dataPrefix: "ts")
        let key2 = HealthKitInteractor.addPrefixForDataKey(key: "steps", device: watch2, dataPrefix: "ts")

        #expect(key1 != key2)
    }

    @Test("Apple Watch and a third-party device get different keys")
    func differentManufacturersProduceDifferentKeys() {
        let appleWatch = HKDevice(name: "Apple Watch",
                                   manufacturer: "Apple Inc.",
                                   model: "Watch7,1",
                                   hardwareVersion: nil,
                                   firmwareVersion: nil,
                                   softwareVersion: nil,
                                   localIdentifier: "AAAAAA-1111",
                                   udiDeviceIdentifier: nil)

        let fitbit = HKDevice(name: "Fitbit",
                               manufacturer: "Fitbit",
                               model: "Versa",
                               hardwareVersion: nil,
                               firmwareVersion: nil,
                               softwareVersion: nil,
                               localIdentifier: "CCCCCC-3333",
                               udiDeviceIdentifier: nil)

        let key1 = HealthKitInteractor.addPrefixForDataKey(key: "steps", device: appleWatch, dataPrefix: "ts")
        let key2 = HealthKitInteractor.addPrefixForDataKey(key: "steps", device: fitbit, dataPrefix: "ts")

        #expect(key1 != key2)
    }

    @Test("iPhone-sourced data still uses the _phone suffix")
    func phoneDeviceStillUsesPhoneSuffix() {
        let iphone = HKDevice(name: "iPhone",
                               manufacturer: "Apple Inc.",
                               model: "iPhone",
                               hardwareVersion: nil,
                               firmwareVersion: nil,
                               softwareVersion: nil,
                               localIdentifier: nil,
                               udiDeviceIdentifier: nil)

        let key = HealthKitInteractor.addPrefixForDataKey(key: "steps", device: iphone, dataPrefix: "ts")

        #expect(key == "tssteps_phone")
    }
    
    @Test("Field name only contains alphanumeric characters and underscores")
    func fieldNameContainsOnlyAllowedCharacters() {
        let watch = HKDevice(name: "Apple Watch",
                              manufacturer: "Apple Inc.",
                              model: "Watch7,1",
                              hardwareVersion: nil,
                              firmwareVersion: nil,
                              softwareVersion: nil,
                              localIdentifier: "AAAAAA-1111",
                              udiDeviceIdentifier: nil)

        let key = HealthKitInteractor.addPrefixForDataKey(key: "steps", device: watch, dataPrefix: "ts")

        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        #expect(key.unicodeScalars.allSatisfy { allowedCharacters.contains($0) })
    }

    @Test("No device falls back to prefix + key only")
    func noDeviceReturnsPrefixPlusKey() {
        let key = HealthKitInteractor.addPrefixForDataKey(key: "steps", device: nil, dataPrefix: "ts")

        #expect(key == "tssteps")
    }
    @Test("Device suffix is a hash, not the raw local identifier")
    func deviceSuffixDoesNotExposeRawIdentifier() {
        let watch = HKDevice(name: "Apple Watch",
                              manufacturer: "Apple Inc.",
                              model: "Watch7,1",
                              hardwareVersion: nil,
                              firmwareVersion: nil,
                              softwareVersion: nil,
                              localIdentifier: "AAAAAA-1111",
                              udiDeviceIdentifier: nil)

        let key = HealthKitInteractor.addPrefixForDataKey(key: "steps", device: watch, dataPrefix: "ts")

        #expect(!key.lowercased().contains("aaaaaa"))
    }
}
