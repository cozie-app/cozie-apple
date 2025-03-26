//
//  SettingsInteractorTests.swift
//  Cozie
//
//  Created by Alexandr Chmal.
//

import Testing
import Foundation
@testable import Cozie

@Suite("SettingsInteractor tests")
struct SettingsInteractorTests {
    @Test func getCurretSettings() async throws {
        let dbStorageMock = DataBaseStorageMock()
        let backendInteractorMock = BackendInteractorMock()
        let loggerMock = LoggerMock()
        
        let testWssTitle = "Title"
        let testWssGoal: Int16 = 123
        
        dbStorageMock.settingsDataSpy?.wss_title = testWssTitle
        dbStorageMock.settingsDataSpy?.wss_goal = testWssGoal
        
        let sut = SettingsInteractor(dbStorage: dbStorageMock, backendInteractor: backendInteractorMock, loggerInteractor: loggerMock, apiRepository: ApiRepositoryMock())
        
        #expect(sut.currentSettings?.wss_title == testWssTitle)
        #expect(sut.currentSettings?.wss_goal == testWssGoal)
    }
    
    @Test func prepareDefaultSettings() async throws {
        let dbStorageMock = DataBaseStorageMock()
        let backendInteractorMock = BackendInteractorMock()
        let loggerMock = LoggerMock()
        
        dbStorageMock.settingsDataSpy = nil
        
        let sut = SettingsInteractor(dbStorage: dbStorageMock, backendInteractor: backendInteractorMock, loggerInteractor: loggerMock, apiRepository: ApiRepositoryMock())
        
        sut.prepareSettingsData()
        
        #expect(sut.currentSettings?.wss_title == Defaults.WSStitle)
        #expect(sut.currentSettings?.wss_goal == Defaults.WSSgoal)
        #expect(sut.currentSettings?.wss_time_out == Defaults.WSStimeOutTime)
        #expect(sut.currentSettings?.wss_reminder_interval == Defaults.WSSreminderInterval)
        #expect(sut.currentSettings?.wss_participation_days == Defaults.WSSparticipationDays)
        #expect(sut.currentSettings?.wss_participation_time_start == Defaults.WSSparticiaptionTimeStart)
        #expect(sut.currentSettings?.wss_participation_time_end == Defaults.WSSparticipationTimeEnd)
        #expect(sut.currentSettings?.pss_reminder_enabled == Defaults.PSSreminderEnabled)
        #expect(sut.currentSettings?.pss_reminder_days == Defaults.PSSreminderDays)
        #expect(sut.currentSettings?.pss_reminder_time == Defaults.PSSreminderTime)
    }
    
    @Test func prepareCustomSettings() async throws {
        let dbStorageMock = DataBaseStorageMock()
        let backendInteractorMock = BackendInteractorMock()
        let loggerMock = LoggerMock()
        
        let sut = SettingsInteractor(dbStorage: dbStorageMock, backendInteractor: backendInteractorMock, loggerInteractor: loggerMock, apiRepository: ApiRepositoryMock())
        // stubs
        let wssTitleStub = "wssTitle"
        let wssGoalStub: Int16 = 10
        let wssTimeoutStub: Int16 = 11
        let wssReminderIntervalStub: Int16 = 12
        let wssReminderEnabledStub = true
        let pssReminderEnabledStub = true
        let wssParticipationDaysStub = "M,T"
        let wssParticipationTimeStartStub = "10:00"
        let wssParticipationTimeEndStub = "21:00"
        
        let pssReminderDaysStub = "M,T,W"
        let pssReminderTimeStub = "09:00"
        
        sut.prepareSettingsData(wssTitle: wssTitleStub, wssGoal: wssGoalStub, wssTimeout: wssTimeoutStub, wssReminderEnabled: wssReminderEnabledStub, wssReminderInterval: wssReminderIntervalStub, wssParticipationDays: wssParticipationDaysStub, wssParticipationTimeStart: wssParticipationTimeStartStub, wssParticipationTimeEnd: wssParticipationTimeEndStub, pssReminderEnabled: pssReminderEnabledStub, pssReminderDays: pssReminderDaysStub, pssReminderTime: pssReminderTimeStub)
        
        #expect(sut.currentSettings?.wss_title == wssTitleStub)
        #expect(sut.currentSettings?.wss_goal == wssGoalStub)
        #expect(sut.currentSettings?.wss_time_out == wssTimeoutStub)
        #expect(sut.currentSettings?.wss_reminder_enabled == wssReminderEnabledStub)
        #expect(sut.currentSettings?.wss_reminder_interval == wssReminderIntervalStub)
        #expect(sut.currentSettings?.wss_participation_days == wssParticipationDaysStub)
        #expect(sut.currentSettings?.wss_participation_time_start == wssParticipationTimeStartStub)
        #expect(sut.currentSettings?.wss_participation_time_end == wssParticipationTimeEndStub)
        #expect(sut.currentSettings?.pss_reminder_enabled == pssReminderEnabledStub)
        #expect(sut.currentSettings?.pss_reminder_days == pssReminderDaysStub)
        #expect(sut.currentSettings?.pss_reminder_time == pssReminderTimeStub)
    }
}

final class LoggerMock: LoggerProtocol {
    func logInfo(action: String, info: String) {
        ///
    }
}

final class ApiRepositoryMock: ApiRepositoryProtocol {
    func get(url: String, parameters: [String : String], key: String, completion: @escaping (Result<Data, any Error>) -> Void) {
        ///
    }
    
    func post(url: String, body: Data, key: String, completion: @escaping (Result<Data, any Error>) -> Void) {
        ///
    }
}
