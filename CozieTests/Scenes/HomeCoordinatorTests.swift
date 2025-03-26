//
//  HomeCoordinatorTests.swift
//  Cozie
//
//  Created by Alexandr Chmal on 14.01.25.
//

import Testing
import UIKit
@testable import Cozie

@Suite("Test for HomeCoordinator", .serialized)
struct HomeCoordinatorTests {
    @Test func updateCutoffTimeIntervalFromLinkOrQRCode() async throws {
        let userInteractor = UserInteractorMock()
        let settingInteractor = SettingsInteractorMock()
        let sut = HomeCoordinator(tab: .data, session: Session(), userInteractor: userInteractor, settingsInteractor: settingInteractor, backendInteractor: BackendInteractorMock())
        let storage = CozieStorageMock()
        
        sut.prepareSource(info: InitModel.stubModel(), storage: storage)
        
        let cotoff = try #require(storage.cutoffTimeIntervalStub)
        #expect(cotoff == 3.0)
    }
    
    @Test func updateDistanceFilterFromLinkOrQRCode() async throws {
        let userInteractor = UserInteractorMock()
        let settingInteractor = SettingsInteractorMock()
        
        let sut = HomeCoordinator(tab: .data, session: Session(), userInteractor: userInteractor, settingsInteractor: settingInteractor, backendInteractor: BackendInteractorMock())
        
        let storage = CozieStorageMock()
        
        sut.prepareSource(info: InitModel.stubModel(), storage: storage)
        
        let cotOff = try #require(storage.distanceFilter())
        #expect(cotOff == 100.0)
    }
    
    @Test() func updateIdParticipantFromLinkOrQRCode() async throws {
        let userInteractorMock = UserInteractorMock()
        let settingInteractorMock = SettingsInteractorMock()
        let backendInteractorMock = BackendInteractorMock()
        
        let sut = HomeCoordinator(tab: .data, session: Session(), userInteractor: userInteractorMock, settingsInteractor: settingInteractorMock, backendInteractor: backendInteractorMock)
        
        let storage = CozieStorageMock()
        
        let linkStub = InitModel.stubModel()
        
        sut.prepareSource(info: InitModel.stubModel(), storage: storage)

        #expect(userInteractorMock.participantID == linkStub.idParticipant)
        #expect(userInteractorMock.experimentID == linkStub.idExperiment)
        #expect(userInteractorMock.password == linkStub.idPassword)
        
        #expect(settingInteractorMock.currentSettings?.wss_title == linkStub.wssTitle)
        #expect(settingInteractorMock.currentSettings?.wss_goal == linkStub.wssGoal)
        #expect(settingInteractorMock.currentSettings?.wss_time_out == linkStub.wssTimeOut)
        #expect(settingInteractorMock.currentSettings?.wss_reminder_enabled == linkStub.wssReminderEnabled)
        #expect(settingInteractorMock.currentSettings?.wss_participation_time_start == linkStub.wssParticipationTimeStart)
        #expect(settingInteractorMock.currentSettings?.wss_participation_time_end == linkStub.wssParticipationTimeEnd)
        #expect(settingInteractorMock.currentSettings?.wss_participation_days == linkStub.wssParticipationDays)
        #expect(settingInteractorMock.currentSettings?.wss_reminder_interval == linkStub.wssReminderInterval)
        #expect(settingInteractorMock.currentSettings?.pss_reminder_enabled == linkStub.pssReminderEnabled)
        #expect(settingInteractorMock.currentSettings?.pss_reminder_days == linkStub.pssReminderDays)
        #expect(settingInteractorMock.currentSettings?.pss_reminder_time == linkStub.pssReminderTime)
        
        #expect(backendInteractorMock.currentBackendSettings?.api_read_key == linkStub.apiReadKey)
        #expect(backendInteractorMock.currentBackendSettings?.api_read_url == linkStub.apiReadURL)
        #expect(backendInteractorMock.currentBackendSettings?.api_write_key == linkStub.apiWriteKey)
        #expect(backendInteractorMock.currentBackendSettings?.api_write_url == linkStub.apiWriteURL)
        
        #expect(backendInteractorMock.currentBackendSettings?.watch_survey_link == linkStub.apiWatchSurveyURL)
        #expect(backendInteractorMock.currentBackendSettings?.phone_survey_link == linkStub.apiPhoneSurveyURL)
    }
}

fileprivate extension InitModel {
    static func stubModel() -> InitModel {
        InitModel(idParticipant: "1",
                  idExperiment: "1",
                  wssTitle: "Ws Titlr",
                  wssGoal: 100,
                  wssTimeOut: 60,
                  wssReminderEnabled: true,
                  wssParticipationTimeStart: "9:00",
                  wssParticipationTimeEnd: "21:00",
                  wssParticipationDays: "M",
                  wssReminderInterval: 40,
                  pssReminderEnabled: true,
                  pssReminderDays: "M",
                  pssReminderTime: "10:00",
                  apiReadURL: "https://apiReadURL",
                  apiReadKey: "someRadKey",
                  apiWriteURL: "https://apiWriteURL",
                  apiWriteKey: "someWriteKet",
                  appOneSignalAppID: "TestAppOneSignalAppID",
                  idPassword: "pass",
                  apiWatchSurveyURL: "https://apiWatchSurveyURL",
                  apiPhoneSurveyURL: "https://apiPhoneSurveyURL",
                  cutoffTime: 3.0,
                  distanceFilter: 100.0)
    }
}

final class UserInteractorMock: UserInteractorProtocol {
    var currentUser: Cozie.User?
    
    var participantID: String? = nil
    var experimentID: String? = nil
    var password: String? = nil
    var prepareUserCallsCount = 0
    var prepareUserWithPassCallsCount = 0
    
    func prepareUser(participantID: String?, experimentID: String?, password: String?) {
        prepareUserCallsCount += 1
        self.password = password
        self.experimentID = experimentID
        self.participantID = participantID
    }
    
    func prepareUser(password: String) {
        prepareUserWithPassCallsCount += 1
        self.password = password
    }
}

class UserStub: User {
    convenience init(stub: Bool) {
            self.init()
        }
        
        override var experimentID: String? {
            get { "experimentID" }
            set {}
        }
        
        override var participantID: String? {
            get { "participantID" }
            set {}
        }
        
        override var passwordID: String? {
            get { "passwordID" }
            set {}
        }
    
    override var syncInfo: SyncInfo? {
        get { SyncInfoStub(stub: true) }
        set {}
    }
    
    override var summaryList: NSSet? {
        get { [] }
        set {}
    }
}

class SyncInfoStub: SyncInfo {
    convenience init (stub: Bool) {
        self.init()
    }
    
    override var date: String? {
        get { "01.01.2025" }
        set {}
    }
    
    override var invalidCount: String? {
        get { "1/100" }
        set {}
    }
    
    override var validCount: String? {
        get { "0" }
        set {}
    }
    
    override var user: User? {
        get { UserStub(stub: true) }
        set {}
    }
}
