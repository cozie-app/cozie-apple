//
//  BackendViewModelTests.swift
//  Cozie
//
//  Created by Alexandr Chmal on 16.01.25.
//

import Testing
import Foundation
@testable import Cozie

@Suite("BackendViewModel tests", .serialized)
struct BackendViewModelTests {
    @Test func prepareDataForDefaultSurveysSection() async throws {
        let dbStorage = PersistenceController(inMemory: true)
        let hkInteractorMock = HealthKitInteractorMock()
        let backendMock = BackendInteractorMock()
        
        let infoStub = try #require(backendMock.currentBackendSettings as? StubBackendInfo)
        infoStub.watch_survey_link = "testwslinck"
        infoStub.phone_survey_link = "testPhonelinck"
        
        let sut = BackendViewModel(storage: CozieStorageMock(),
                                   backendInteractor: backendMock,
                                   settingsInteractor: SettingsInteractorMock(),
                                   userInteractor: UserInteractorMock(),
                                   dbStorage: dbStorage,
                                   comManager: WatchConnectivityManagerPhoneMock(),
                                   watchSurveyInteractor: WatchSurveyInteractor(),
                                   healthKitInteractor: hkInteractorMock)
        
        
       
        
        sut.prepareData(active: nil)
        
        #expect(hkInteractorMock.getAllRequestedDataCalledCount == 1)
        #expect(sut.section.first?.list.first?.subtitle == infoStub.watch_survey_link)
        #expect(sut.section.first?.list[1].subtitle == infoStub.phone_survey_link)
    }
    
    @Test func prepareDataForDefaultDataSection() async throws {
        let dbStorage = PersistenceController(inMemory: true)
        let hkInteractorMock = HealthKitInteractorMock()
        let backendMock = BackendInteractorMock()
        
        let storage = CozieStorageMock()
        storage.cutoffTimeIntervalStub = 5.0
        storage.distanceFilterStub = 70.0
        
        let sut = BackendViewModel(storage: storage,
                                   backendInteractor: backendMock,
                                   settingsInteractor: SettingsInteractorMock(),
                                   userInteractor: UserInteractorMock(),
                                   dbStorage: dbStorage,
                                   comManager: WatchConnectivityManagerPhoneMock(),
                                   watchSurveyInteractor: WatchSurveyInteractor(),
                                   healthKitInteractor: hkInteractorMock)
        
        sut.prepareData(active: nil)
        
        #expect(hkInteractorMock.getAllRequestedDataCalledCount == 1)
        #expect(sut.section[2].list.first?.subtitle == "\(storage.cutoffTimeIntervalStub ?? 0)")
        #expect(sut.section[2].list[1].subtitle == "\(storage.distanceFilterStub ?? 0)")
    }
    
    @Test func prepareDataForDefaultBackendSection() async throws {
        let dbStorage = PersistenceController(inMemory: true)
        let hkInteractorMock = HealthKitInteractorMock()
        let backendMock = BackendInteractorMock()
        
        let infoStub = try #require(backendMock.currentBackendSettings as? StubBackendInfo)

        infoStub.api_read_url = "api_read_url"
        infoStub.api_read_key = "api_read_key"
        infoStub.api_write_url = "api_write_url"
        infoStub.api_write_key = "api_write_key"
        infoStub.participant_password = "participant_password"
        
        let sut = BackendViewModel(storage: CozieStorageMock(),
                                   backendInteractor: backendMock,
                                   settingsInteractor: SettingsInteractorMock(),
                                   userInteractor: UserInteractorMock(),
                                   dbStorage: dbStorage,
                                   comManager: WatchConnectivityManagerPhoneMock(),
                                   watchSurveyInteractor: WatchSurveyInteractor(),
                                   healthKitInteractor: hkInteractorMock)
        
        sut.prepareData(active: nil)
        
        #expect(hkInteractorMock.getAllRequestedDataCalledCount == 1)
        #expect(sut.section[1].list.first?.subtitle == infoStub.api_read_url)
        #expect(sut.section[1].list[1].subtitle == infoStub.api_read_key)
        #expect(sut.section[1].list[2].subtitle == infoStub.api_write_url)
        #expect(sut.section[1].list[3].subtitle == infoStub.api_write_key)
        #expect(sut.section[1].list[4].subtitle == infoStub.participant_password)
    }
    
    @Test func updateValueForDistanceFilterAndMaxHealthCutoffInteval() async throws {
        let dbStorage = PersistenceController(inMemory: true)
        let hkInteractorMock = HealthKitInteractorMock()
        let backendMock = BackendInteractorMock()
        let storage = CozieStorageMock()
        
        let sut = BackendViewModel(storage: storage,
                                   backendInteractor: backendMock,
                                   settingsInteractor: SettingsInteractorMock(),
                                   userInteractor: UserInteractorMock(),
                                   dbStorage: dbStorage,
                                   comManager: WatchConnectivityManagerPhoneMock(),
                                   watchSurveyInteractor: WatchSurveyInteractor(),
                                   healthKitInteractor: hkInteractorMock)
        
        sut.updateValue(state: .distanceFilter, value: "10")
        sut.updateValue(state: .healthCutoffTime, value: "3")
        
        #expect(storage.distanceFilter() == 10)
        #expect(storage.maxHealthCutoffTimeInterval() == 3)
    }
    
    @Test func updateValueForBackendData() async throws {
        let dbStorage = PersistenceController(inMemory: true)
        let hkInteractorMock = HealthKitInteractorMock()
        let backendMock = BackendInteractorMock()
        let storage = CozieStorageMock()
        
        let infoStub = try #require(backendMock.currentBackendSettings as? StubBackendInfo)
        
        let sut = BackendViewModel(storage: storage,
                                   backendInteractor: backendMock,
                                   settingsInteractor: SettingsInteractorMock(),
                                   userInteractor: UserInteractorMock(),
                                   dbStorage: dbStorage,
                                   comManager: WatchConnectivityManagerPhoneMock(),
                                   watchSurveyInteractor: WatchSurveyInteractor(),
                                   healthKitInteractor: hkInteractorMock)
        
        let readURLStub = "readURL"
        sut.updateValue(state: .readURL, value: readURLStub)
        #expect(infoStub.api_read_url == readURLStub)
       
        let readKeyStub = "readKey"
        sut.updateValue(state: .readKey, value: readKeyStub)
        #expect(infoStub.api_read_key == readKeyStub)
        
        let writeKeyStub = "writeKey"
        sut.updateValue(state: .writeKey, value: writeKeyStub)
        #expect(infoStub.api_write_key == writeKeyStub)
        
        let writeURLStub = "https://writeURL"
        sut.updateValue(state: .writeURL, value: writeURLStub)
        #expect(infoStub.api_write_url == writeURLStub)
        
        let participantPasswordStub = "participantPassword"
        sut.updateValue(state: .participantPassword, value: participantPasswordStub)
        #expect(infoStub.participant_password == participantPasswordStub)
    }
    
    @Test func updateValueForWSPhoneSurvey() async throws {
        let dbStorage = PersistenceController(inMemory: true)
        let hkInteractorMock = HealthKitInteractorMock()
        let backendMock = BackendInteractorMock()
        let storage = CozieStorageMock()
        
        let infoStub = try #require(backendMock.currentBackendSettings as? StubBackendInfo)
        
        let sut = BackendViewModel(storage: storage,
                                   backendInteractor: backendMock,
                                   settingsInteractor: SettingsInteractorMock(),
                                   userInteractor: UserInteractorMock(),
                                   dbStorage: dbStorage,
                                   comManager: WatchConnectivityManagerPhoneMock(),
                                   watchSurveyInteractor: WatchSurveyInteractor(),
                                   healthKitInteractor: hkInteractorMock)
        
        let phoneSurveyLinkStub = "https://phoneSurveyLink"
        sut.updateValue(state: .phoneSurveyLink, value: phoneSurveyLinkStub)
        #expect(infoStub.phone_survey_link == phoneSurveyLinkStub)
       
        let watchsurveyLinkStub = "https://watchsurveyLink"
        sut.updateValue(state: .watchsurveyLink, value: watchsurveyLinkStub)
        #expect(infoStub.watch_survey_link == watchsurveyLinkStub)
    }
}

final class WatchSurveyInteractor: WatchSurveyInteractorProtocol {
    func loadSelectedWatchSurveyJSON(completion: ((String?, (any Error)?) -> ())?) {
        //
    }
}

final class WatchConnectivityManagerPhoneMock: WatchConnectivityManagerPhoneProtocol {
    func sendAll(data: Data, writeApiURL: String, writeApiKey: String, userID: String, expID: String, password: String, userOneSignalID: String, timeInterval: Int, healthCutoffTimeInterval: Double, completion: (((any Error)?) -> ())?) {
        //
    }
}

final class HealthKitInteractorMock: HealthKitInteractorProtocol {
    
    var getAllRequestedDataCalledCount = 0
    var getAllRequestedDataTrigger: String?
    
    func getAllRequestedData(trigger: String, completion: (([Cozie.HealthModel]) -> ())?) {
        getAllRequestedDataCalledCount += 1
        getAllRequestedDataTrigger = trigger
    }
    
    func sendData(trigger: String, timeout: Double?, healthCache: [Cozie.HealthModel]?, completion: ((Bool) -> ())?) {
        //
    }
}
